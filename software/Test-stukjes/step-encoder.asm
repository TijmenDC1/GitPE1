;test programma voor de rotary encoder met richting aangeving voor de stepper
;rood1: CW
;rood2: CCW
;geel1: knop
;groen1: richting indicatie (aan = rechts)
    org 0000h
    mov sp,#7fh
    ;er staat een pull-up op poort 2 dus het detecteert een 1 wanneer de pin naar de grond wordt getrokken
    lcall initftoetsen
    mov     p0_dir,#11111111b
    mov     p1_dir,#11111111b
    mov     p2_dir,#00000000b
    mov     p3_dir,#11111111b
    mov     p4_dir,#11111111b
    token   equ 10h

;------------hoofdprogramma------------
main:
    jnb     IN1,checkR      ;met te klok
    jnb     IN2,checkL      ;tegen de klok in
    jnb     IN3,knop        ;de knop

    ljmp    main
;------------subroutines------------
;pin A en B (CW en CCW) hebben allebij een waarde, als pin getecteerd wordt geeft het die waarde mee aan de token.
;als de token 2 keer hetzelfde is betekend het dat de richting wordt omgedraait
checkR:
    
    clr     rood1
    mov     a,#1
    lcall   delayA0k05s
    setb    rood1

    mov     a,token
    cjne    a,00h,verder1
    cpl     dir4
    clr     groen1

    verder1:
    mov     token,#00h
    lcall   stappen
    ljmp    main

checkL:
    clr     rood2
    mov     a,#1
    lcall   delayA0k05s
    setb    rood2

    mov     a,token
    cjne    a,01h,verder2
    cpl     dir4
    setb    groen1

    verder2:
    mov     token,#01h
    lcall   stappen
    ljmp    main
knop:
        clr     geel1

        terug:  jb      IN3,terug
        setb    geel1
        ljmp    main

stap:
    mov     a,#1
    cpl     step4       ;stap wordt gelezen bij rising edge
    clr     rood1       ;indicatie led voor de stap
    lcall   delay1ms    ;0,001s
    ;lcall   delayA0k05s ;0,05s
    cpl     step4
    setb    rood1
    lcall   delay1ms
    ret

stappen:
    mov     b,#10    
    count:
    lcall   stap
    djnz    b,count
    ret

#include "C:\xcez5T.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
END