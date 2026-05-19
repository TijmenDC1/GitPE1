;Eigen UART testprogramma (TX gedeelte)
;gebruikt 0.4 TXD en 0.5 RXD
;werkt op 9600 bps

;rood1: gaat even hoog om begin en einde van het sturen aan te geven


    org 0000h
    mov sp,#7fh
    mov p0_dir,#00010001b

    send_data   equ 10h ;data dat verstuurd moet worden
    delay       equ 12h ;delay waarde om de baudrate te bepalen

    ;9600 bps --> 104us
    mov     delay,#10

    
;------------hoofdprogramma------------
main:
    ;verstuurde data moet in de accu worden meegegeven
    mov     a,#00110011b
    lcall   sendbyte

    ;een lange delay om makkelijker te meten
    mov     a,#150   
    lcall   delay10usx

    ljmp main

;------------subroutine I------------
sendbyte:
    ;verstuur data in accu ergens in opslaan
    mov     send_data,a

    ;STARTBIT
    ;lijn wordt laag getrokken
    mov     a,delay
    clr     TXD

    clr     rood1       ;led start indicatie
    lcall   delay10usx
    setb    rood1

    ;DATA BITS
    ;8 bits sturen door ze elke keer in de carry te duwen
    mov     r1,#8
    lus0:
 
    mov     a,send_data ;data in de accu steken voor rrc en daarna terug plaatsen
    rrc     a           ;schuift LSB in de carry
    mov     send_data,a

    mov     TXD,c

    mov     a,delay
    lcall   delay10usx

    djnz    r1,lus0

    ;STOPBIT
    ;de lijn weer hoog zetten om stop de indiceren
    setb    TXD
    clr     rood1
    mov     a, delay
    lcall   delay10usx
    setb    rood1

ret

delay10usx:
; met de delay10us kan je geen waarde in de accu meegeven om een variabele periode in te stellen
; zoal de delayA0k05s (5ms x accu waarde)
; met deze functie kan je dat wel
    push    b
    mov     b,a

lusx:
    lcall   delay10us
    djnz    b,lusx

    pop     b
ret

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

