; VECTOR TABLE
  org $0000
    dc.l -1             ; Initial SP
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
    MOVE.l BIGVAL,d0
START2:
  SUB.l #1,d0
  CMP.l #0,d0
  BNE START2
  ; JMP OTHER

  ; MOVE.b #$FF,$EF00
  ; MOVE.b #$FF,$100000
  MOVE SMOLVAL,$100000
  ADD #1,SMOLVAL
  CMP #$7B,SMOLVAL
  BLT OTHER
  MOVE #'a',SMOLVAL
  BRA OTHER
  
  org $2000
OTHER:
    MOVE.l BIGVAL,d0
OTHER2:
    SUB.l #1,d0
    CMP.l #0,d0
    BNE OTHER2
    JMP START

  org $3000
SMOLVAL:
    dc 'a'
BIGVAL:
    dc.l 1000
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
