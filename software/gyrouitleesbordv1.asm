
ORG 0000H
    LJMP START

ORG 0030H
Init:
    LCALL initsio        ; Initialiseer UART op 9600 baud
    LCALL initiic        ; Configureer P0.7 en P0.3 voor I2C     
    ;MPU6050 Wekken (Register 0x6B op 0 zetten)
    LCALL iicstart       
    MOV A, #0D0H         ; MPU6050 schrijf-adres
    LCALL iicoutbyte     
    MOV A, #6BH          ; register om aan te zetten
    LCALL iicoutbyte
    MOV A, #00H          ;  uit sleepmode halen maar ook temp sensor aan opzich geen probleem maar kan wel af door 00001000
    LCALL iicoutbyte
    LCALL iicstop        

MAIN:
   LCALL lees_accelerator

    MOV A, #FFH     ; synchronisatie bit die de ontvangende verwacht

    ;R2 = XH R3=YH R4= ZH
    Mov A, R2
    LCALL sendbyte
    Mov A, R3
    LCALL sendbyte
    Mov A, R4
    LCALL sendbyte



lees_accelerator:
;startreg van de accel (0x3B)
;enkel high bytes

    LCALL iicstart       
    MOV A, #0D0H         ;write
    LCALL iicoutbyte     
    MOV A, #3BH          ;Register XH eerste byte om te beginnen lezen
    LCALL iicoutbyte     
                    ;6bytes ontvangen enkel 3 opslaan
    LCALL iicstart       
    MOV A, #0D1H         ;Read
    LCALL iicoutbyte     

    ; 5 bytes met ack om volgende te vragen op het einde nack
    LCALL iicinbyteack   ;XH
    MOV R2, A
    LCALL iicinbyteack   ;XL niet opslaan

    LCALL iicinbyteack   
    MOV R3, A
    LCALL iicinbyteack   
    
    MOV R5, A
    LCALL iicinbyteack   ; Lees Z High
    MOV R6, A
    LCALL iicinbytenack  ;stuurt ook nog een byte maar slagen we niet op
    
    LCALL iicstop        ; [cite: 101]
    RET

#include "c:\xcez5.inc"
#include "