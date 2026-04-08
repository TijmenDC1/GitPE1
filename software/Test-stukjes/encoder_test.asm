;test programma voor de EC11 rotary encoder
;rood1: CW
;rood2: CCW
;geel1: knop
    org 0000h
    mov sp,#7fh
    ;er staat een pull-up op poort 2 dus het detecteert een 1 wanneer de pin naar de grond wordt getrokken
    lcall initftoetsen
    mov     p0_dir,#11111111b
    mov     p1_dir,#11111111b
    mov     p2_dir,#00000000b

;------------hoofdprogramma------------
main:
    jnb     IN1,checkR      ;met te klok
    jnb     IN2,checkL      ;tegen de klok in
    jnb     IN3,knop        ;de knop

    ljmp    main
;------------subroutines------------
checkR:
    
    clr     rood1
    mov     a,#1
    lcall   delayA0k05s
    setb    rood1
    ;ret
    ljmp    main

checkL:
    clr     rood2
    mov     a,#1
    lcall   delayA0k05s
    setb    rood2
    ;ret
    ljmp    main
knop:
        clr     geel1

terug:  jb      IN3,terug
        setb    geel1
        ;ret
        ljmp    main

#include "C:\xcez5T.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
END
