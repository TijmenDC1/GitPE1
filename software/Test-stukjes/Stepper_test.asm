;programma om de stappenmoters te doen draaien
;aangesloten: rood1, geel1, step4
    org 0000h
    mov sp,#7fh

;    step4   BIT     P3_data.1
;    rood1   BIT     P0_data.2

    mov p0_dir,#11111111b
    mov p1_dir,#11111111b
    mov p3_dir,#11111111b
    mov p4_dir,#11111111b

    ;lcall   init
    clr     groen1
    
;------------hoofdprogramma------------
 main:
    mov     a,#10
    ;lcall   delayA0k05s ;0,05 seconden * 10

    clr     geel1
    lcall   stap
    lcall   stap
    lcall   stap
    lcall   stap
    lcall   stap
    setb    geel1
    
    ljmp    main

;------------subroutines------------
init:
    clr     step4    

    ret
stap:
    mov     a,#1
    cpl     step4       ;stap wordt gelezen bij rising edge
    clr     rood1       ;indicatie led voor de stap
    ;lcall   delayA0k05s ;0,05s
    lcall   delay1ms ;0,001s
    cpl     step4
    setb    rood1
    lcall   delay1ms
    ret

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
END        

