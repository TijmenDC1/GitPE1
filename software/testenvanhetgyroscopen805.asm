; *******************************************************************************
; MPU6050 Gyroscoop Test voor XC888
; dus aansluiten op poort i2c en de sda pin van de gyro aansluiten op de poorten die onder doel staan op lijn 8 ongeveer 
; SDA = P0.7, SCL = P0.3
; *******************************************************************************
sc_doel_pitch    EQU 30h
sc_doel_roll     EQU 31h
el_doel_plooien  EQU 32h
el_doel_draaien  EQU 33h
po_doel_knijpen  EQU 34h
po_doel_draaien  EQU 35h
                        
AD0_SC  BIT P3_data.4  ; Sensor Schouder
AD0_EL  BIT P3_data.5    ; Sensor Elleboog
AD0_PO  BIT P3_data.6    ; Sensor Pols
                                
ORG 0000H
    LJMP START
                        
ORG 0060H
START:
    MOV SP, #7FH
    PUSH syscon0
    MOV  syscon0, #004h    
    PUSH port_page
    MOV  port_page, #000h
    ; P0.0, P0.1, P0.2, P0.6 zijn LED's
    ; P0.3 en P0.7 zijn I2C
    MOV  p0_dir, #11111111B 
    ;P1.6 en P1.7 zijn blauwe LED P1.1 is AD0
    MOV  p1_dir, #11111111B 
    MOV p3_dir, #11111111B
    MOV p5_dir,#11111111B
                        
    POP  port_page
    POP  syscon0
                        
    ;Het probleem dat we hadden is dat er maar 2 MPU's konden aanspreken op 1 I2C bus
    ;1 ad0 bit we zetten nu dus via een output de sensor aan die we willen adresseren
    ;trekken alle AD0 pinnen laag zodat ze allemaal op 0xD0 luisteren
    ;SETB AD0_SC
    SETB AD0_EL
    ;SETB AD0_PO
                    
    LCALL initiic        ;Configureer P0.7 en P0.3 voor I2C include file
    LCALL inituart1                            
                            
    lcall	initdipswitch
	lcall	initlcd
    lcall	lcdlighton	;anders zien we niet veel
	lcall	initcolor	;lcd scherm klaar zetten
    ;mov r6,#00          ; Y-coördinaat
    ;mov r5,#00          ; X-coördinaat
    ;mov r4,#07h         ; Kleur 
    ;mov r3,#e0h
    ;mov r2,#00h         ; Achtergrond (Zwart)
    ;mov r1,#00h
    ;mov dptr,#msg1
    ;lcall coloroutmsga  ; JUISTE COMMANDO VOOR TFT!
    
    ;CLR AD0_SC 
    ;MPU6050 Wekken (Register 0x6B op 0 zetten)
    ;LCALL WEK_MPU     
    ;SETB AD0_SC     ;specifieke gyro terug uitzetten
    ;-------------------------------------------------
    CLR AD0_EL
    LCALL WEK_MPU
    SETB AD0_EL
    ;-------------------------------------------------
    ;CLR AD0_PO
    ;LCALL WEK_MPU
    ;SETB AD0_PO
    ;-------------------------------------------------
                        
MAIN_LOOP:
    
    LCALL LEES_MPU;  
    ;MOV A, #0FFH           ;Sync byte om te laten weten da er iets komt
    ;LCALL uart1outchar
    ;LCALL Printen1
    ;MOV A, sc_doel_pitch    
    ;LCALL uart1outchar
    ;LCALL Printen1a
    ;MOV A, sc_doel_roll     
    ;LCALL uart1outchar
    ;LCALL Printen2
    MOV A, el_doel_plooien  
    ;LCALL uart1outchar
    LCALL Printen2a
    ;MOV A, el_doel_draaien  
    ;LCALL uart1outchar
    ;MOV A, po_doel_knijpen  ;Byte 5 zal waarschijnlijk 0 blijfen omddat dit gebeurd met rotary encoder maar ovor zekerheid er bij gezet
    ;LCALL uart1outchar
    ;LCALL Printen3
    ;MOV A, po_doel_draaien  
    ;LCALL uart1outchar
    ;LCALL Printen3a
    LCALL delaya0k05s          
    SJMP MAIN_LOOP
    
    
 LEES_MPU:   ; de accelerommeters
    ;LEES SCHOUDER
    ;CLR AD0_SC            ;de gyro laag trekken die er aan hangt
    ;LCALL LEES_ACCEL    ;uitlezen van die zensor maar wel enkel x en y z moet niet
    ;MOV sc_doel_pitch, R0   ;R0 = X High
    ;MOV sc_doel_roll, R1    ;R1 = Y High
    ;SETB AD0_SC             ; Deactiveer 

    ;LES ELLEBOOG
    CLR AD0_EL              ;Activeer sensor 2
    LCALL LEES_ACCEL
    MOV a, R0
    MOV el_doel_plooien, A
    MOV A, R1
    MOV el_doel_draaien, A
    SETB AD0_EL

    ;LEES POLS
    ;CLR AD0_PO                    ;Activeer sensor 3
    ;LCALL LEES_ACCEL
    ;MOV A, R0
    ;MOV po_doel_draaien, A   ;Alleen X nodig voor draaien knijpen rotary
    ;SETB AD0_PO
    RET
                                    
LEES_ACCEL:
    LCALL iicstart
    MOV A, #0D0H            ;;MPU6050 schrijf-adres
    LCALL iicoutbyte
    MOV A, #3BH             ;Accel X  _H start adres dus 
    LCALL iicoutbyte
    LCALL iicstart
    MOV A, #0D1H            ;lees modus
    LCALL iicoutbyte
    
    LCALL iicinbyteack      ;Lees X_H
    MOV R0, A
    LCALL iicinbyteack      ;we lezen de low byre maar slagen niet op
    
    LCALL iicinbyteack      ;y waarde 
    MOV R1, A
    LCALL iicinbytenack     
    LCALL iicstop
    RET
WEK_MPU:
    LCALL iicstart
    MOV A, #0D0H
    LCALL iicoutbyte
    MOV A, #6BH             ; PWR_MGMT_1
    LCALL iicoutbyte
    MOV A, #00H             ; Wekken
    LCALL iicoutbyte
    LCALL iicstop
    RET
Printen1:
        mov	r6,#00		;coordinaten zetten
		mov	r5,#00
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen1a:
        mov	r6,#00		;coordinaten zetten
		mov	r5,#15
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen2:
        mov	r6,#10		;coordinaten zetten
		mov	r5,#00
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen2a:
        mov	r6,#10		;coordinaten zetten
		mov	r5,#15
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen3:
        mov	r6,#20		;coordinaten zetten
		mov	r5,#00
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen3a:
        mov	r6,#20		;coordinaten zetten
		mov	r5,#15
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret

;msg1:		db	0ch,"zie de al?",000h
;#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
#include "c:\colorxc0.inc"
#include "c:\UART1.inc"

