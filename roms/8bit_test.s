; VECTOR TABLE
  org $0000
    dc.l $F000          ; Initial SP
    dc.l START          ; Initial PC
    dc.l ERR            ; Bus error
    dc.l ERR            ; Address error
    dc.l ERR            ; Illegal Instruction
    dc.l ERR            ; Divide by 0
    dc.l ERR            ; CHK Instruction
    dc.l ERR            ; TRAPV Instruction
    dc.l ERR            ; Privilege Violation
    dc.l ERR            ; Trace
    ; unassigned, reserved
  org $0060
    dc.l ERR            ; Spurious Interrupt
    dc.l IRQ1           ; Level 1
    dc.l IRQ2           ; Level 2
    dc.l IRQ3           ; Level 3
    dcb.l 4 IRQ_OTHER   ; Level 4~7
    dcb.l 16 ERR        ; Traps

  org $1000
START:
  JSR DELAY
  JSR DELAY
  JSR DELAY
START_LOOP:
  JSR DELAY
  MOVE.b SMOLVAL,$100000
  JSR DELAY
  MOVE.b SMOLVAL2,$100000

  ADD.b #1,SMOLVAL
  CMP.b #'z',SMOLVAL
  BLE NEXT
  MOVE.b #'a',SMOLVAL
NEXT:
  ADD.b #1,SMOLVAL2
  CMP.b #'Z',SMOLVAL2
  BLE END
  MOVE.b #'A',SMOLVAL2
END:
  BRA START_LOOP
  
  org $2000
BIGVAL:
    dc.l 10000
DELAY:
    MOVE.l BIGVAL,d0
DELAY_LOOP:
    SUB.l #1,d0
    CMP.l #0,d0
    BNE DELAY_LOOP
    RTS

  org $29E0
SMOLVAL:
    dc.b 'a'
  org $29E1
SMOLVAL2:
    dc.b 'A'

  org $3000
IRQ1:
    JMP IRQ1
IRQ2:
    JMP IRQ2
IRQ3:
    JMP IRQ3
IRQ_OTHER:
    JMP IRQ_OTHER
ERR:
    JMP ERR
