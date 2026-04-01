;test file PE1 voor alle leds met een patroon

    org 0000h
    mov sp,#7fh
    lcall inits


    led_1   bit p0_data.0 
    led_2   bit p0_data.1
    led_3   bit p0_data.2
    led_4   bit p0_data.6
    led_5   bit p1_data.6
    led_6   bit p1_data.7

    mov     p0_dir,#11111111b  
    mov     p1_dir,#01111111b


;------------hoofdprogramma------------
main:
    lcall   omtebeurt
    lcall   alles

    ljmp    main

;------------subroutines------------
inits:          ;alle leds uitzetten in het geval dat nog niet gebeurt is   
    setb    led_1
    setb    led_2
    setb    led_3
    setb    led_4
    setb    led_5
    setb    led_6 
    
    ret

omtebeurt:      ;leds 1 voor 1 aan en uit laten gaan
    mov     a,#2        ;1ms wachten

    clr     led_1       ;led aan   
    lcall   delayA0k05s ;wachten
    setb    led_1       ;led 1 uit 
    clr     led_2       ;en volgende led aan
; hetzelfde voor de rest
    lcall   delayA0k05s
    setb    led_2
    clr     led_3

    lcall   delayA0k05s
    setb    led_3
    clr     led_4

    lcall   delayA0k05s
    setb    led_4
    clr     led_5

    lcall   delayA0k05s
    setb    led_5
    clr     led_6

    lcall   delayA0k05s
    setb    led_6   

    ret

alles:  ;alle leds 3 keer laten blinken
    mov     b,#3        ;waarde naar b register schrijven voor loop

lus:
    clr     led_1
    clr     led_2
    clr     led_3
    clr     led_4
    clr     led_5
    clr     led_6

    lcall delayA0k05s

    setb    led_1
    setb    led_2
    setb    led_3
    setb    led_4
    setb    led_5
    setb    led_6
    djnz    b,lus

    ret

#include "c:\xcez5.inc"
        END
