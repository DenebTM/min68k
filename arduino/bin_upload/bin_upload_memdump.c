// modified version of bin_upload which waits for a memory dump and exits
// afterwards

#include <asm-generic/ioctls.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

speed_t get_speed(int baud_rate) {
  switch (baud_rate) {
    case 600:
      return B600;
    case 1200:
      return B1200;
    case 2400:
      return B2400;
    case 4800:
      return B4800;
    case 9600:
      return B9600;
    case 19200:
      return B19200;
    case 38400:
      return B38400;
    case 57600:
      return B57600;
    case 115200:
      return B115200;

    default:
      return B0;
  }
}

int setup_serial(int serial_fd, int baud_rate) {
  struct termios tty;
  if (tcgetattr(serial_fd, &tty) != 0) {
    perror("tcgetattr");
    return -1;
  }

  // 8N1, no parity, no hardware flow control
  tty.c_cflag &= ~CSIZE;
  tty.c_cflag |= CS8;

  // no line buffering, no echo, no erasure, no new-line echo, no signal chars
  tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ECHONL | ISIG);

  // no software flow control
  tty.c_iflag &= ~(IXON | IXOFF | IXANY);
  // no special handling of any bytes
  tty.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL);

  // no special interpretation nor implicit conversion of any output bytes
  tty.c_oflag &= ~(OPOST | ONLCR);

  // `read` handling
  tty.c_cc[VMIN] = 1;  // wait for at least one character
  tty.c_cc[VTIME] = 0; // do not time out

  cfsetspeed(&tty, get_speed(baud_rate));

  if (tcsetattr(serial_fd, TCSANOW, &tty) != 0) {
    perror("tcsetattr");
    return -1;
  }

  usleep(10000);
  tcflush(serial_fd, TCIOFLUSH);

  // "wiggle" DTR to ensure the Arduino resets on connection
  int status;
  ioctl(serial_fd, TIOCMGET, &status);
  status ^= TIOCM_DTR;
  ioctl(serial_fd, TIOCMSET, &status);
  status ^= TIOCM_DTR;
  ioctl(serial_fd, TIOCMSET, &status);

  return 0;
}

int readline(char *buf, int fd) {
  // fputs("> ", stdout);
  fflush(stdout);

  int char_count = 0;
  char c;
  for (;;) {
    int err = read(fd, &c, 1);
    if (err < 0) {
      perror("readline");
      return err;
    }
    if (c == '\r') {
      // crlf -> lf
    } else if (c == '\n') {
      if (buf) {
        buf[char_count] = '\0';
      }
      fputc('\n', stdout);
      break;
    } else {
      if (buf) {
        buf[char_count++] = c;
      }
      fputc(c, stdout);
      fflush(stdout);
    }
  }

  fflush(stdout);
  return char_count;
}

int main(int argc, char *const argv[]) {
  if (argc < 2) {
    puts("Missing serial port name");
    return EXIT_FAILURE;
  }
  if (argc < 3) {
    puts("Missing baud rate");
    return EXIT_FAILURE;
  }
  if (argc < 4) {
    puts("Missing start address");
    return EXIT_FAILURE;
  }
  int clear = 0;
  if (argc >= 6) {
    clear = atoi(argv[5]);
  }
  int no_write = 0;
  if (argc >= 7) {
    no_write = atoi(argv[6]);
  }

  char infile_buf[1024];
  int infile_fd = STDIN_FILENO;
  if (argc >= 5) {
    infile_fd = open(argv[4], O_RDONLY);
  }

  uint16_t start_addr = (uint16_t)atoi(argv[3]);

  // setup serial port
  int baud_rate = atoi(argv[2]);
  char serial_buf[1025];
  int serial_fd = open(argv[1], O_RDWR);
  if (setup_serial(serial_fd, baud_rate) == -1) {
    return EXIT_FAILURE;
  }

  for (;;) {
    readline(serial_buf, serial_fd);
    if (strcmp(serial_buf, "Awaiting \"reset\"") == 0) {
      break;
    }
  }
  write(serial_fd, "reset\r\n", 7);
  for (;;) {
    readline(serial_buf, serial_fd);
    if (strcmp(serial_buf, "ready") == 0) {
      break;
    }
  }
  // puts("Got \"ready\"");

  if (no_write) {
    // puts("Not writing");
    goto end;
  }

  int first_iter = 1;
  // puts("Sending first data packet");

  if (clear) {
    first_iter = 0;
    write(serial_fd, "\x10", 1);
    for (;;) {
      readline(serial_buf, serial_fd);
      if (strcmp(serial_buf, "ok") == 0) {
        break;
      }
    }
  }

  // write out data via serial port
  uint16_t addr = start_addr;

  uint16_t count;
  while ((count = read(infile_fd, infile_buf, sizeof(infile_buf))) > 0) {
    if (!first_iter) {
      // puts("Sending next data packet");
      first_iter = 0;
    }

    uint8_t checksum = 0;
    for (int i = 0; i < count; i++) {
      checksum += infile_buf[i];
    }
    checksum = 255 - checksum;

    write(serial_fd, "\x00", 1);    // "command" 0: continue transmission
    write(serial_fd, &addr, 2);     // target address
    write(serial_fd, &count, 2);    // number of bytes to write to SRAM
    write(serial_fd, &checksum, 1); // checksum = 255 - (sum of written bytes)
    write(serial_fd, infile_buf, count);

    // wait for ok from arduino
    for (;;) {
      readline(serial_buf, serial_fd);

      if (strcmp(serial_buf, "ok") == 0) {
        break;
      } else if (strcmp(serial_buf, "err") == 0) {
        close(infile_fd);
        close(serial_fd);
        return EXIT_FAILURE;
      }
    }

    addr += count;
  }

end:
  write(serial_fd, "\xff", 1); // "command" 0xff: finish transmission

  static char buff[512 * 1024];
  for (;;) {
    readline(buff, serial_fd);
    if (strncmp(buff, "FFF0: ", 6) == 0) {
      break;
    }
  }

  close(infile_fd);
  close(serial_fd);
  return EXIT_SUCCESS;
}
