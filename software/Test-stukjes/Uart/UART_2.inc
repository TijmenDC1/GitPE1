;blinky van 1 seconde om timing uit te testen
    org 0000h
    mov sp,#7fh
    mov p0_dir,#00010001b

    
;------------hoofdprogramma------------
main:
    mov     a,#10
    lcall   delay10us
    clr     rood1
    clr     TXD

    lcall   delay10us
    setb    rood1
    setb    TXD
    lcall   sendbyte

    ljmp main

;------------subroutine I------------
sendbyte:
    ;de lijn laag trekken om communicatie te starten
    mov     a,#10
    lcall   delay10us

ret

;------------subroutine II------------
;------------subroutine III------------

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

