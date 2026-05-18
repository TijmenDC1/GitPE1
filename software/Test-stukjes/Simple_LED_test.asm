;een simpele test om te zien of de leds werken door ze allemaal te laten branden
    org 0000h

    mov sp,#7fh

    led_1   bit p0_data.0 
    led_2   bit p0_data.1
    led_3   bit p0_data.2
    led_4   bit p0_data.6
    led_5   bit p1_data.6
    led_6   bit p1_data.7

;-------inputs en zetten (1 out, 0 in)
    push    syscon0
    mov     syscon0,#004h
    push    port_page
    mov     port_page,#000h
    mov     p0_dir,#11111111b  
    mov     p1_dir,#11111111b
    pop    port_page
    pop    syscon0
    lcall   inits

;------------hoofdprogramma------------
main:

    ;clr     led_1
    ;clr     led_2
    ;clr     led_3
    ;clr     led_4
    ;clr     led_5
    ;clr     led_6

    lcall   blink
    ljmp    main

;------------subroutines------------
inits:           ;alle pinnen hoogzetten om standaard
    setb    led_1
    setb    led_3
    setb    led_6 
    
    ret

blink:  ;alle leds 3 keer laten blinken
    clr     led_1
    clr     led_2
    clr     led_3
    clr     led_4
    clr     led_5
    clr     led_6
    
    mov     a,#10
    lcall   delayA0k05s

    setb    led_1
    setb    led_2
    setb    led_3
    setb    led_4
    setb    led_5
    setb    led_6

    ret

#include "c:\xcez5.inc"
        END    
