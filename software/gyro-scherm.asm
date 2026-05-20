sc_doel_pitch    EQU 30h
sc_doel_roll     EQU 31h
el_doel_plooien  EQU 32h
el_doel_draaien  EQU 33h
po_doel_knijpen  EQU 34h   ;0 momenteel maar voor uart zenden
po_doel_draaien  EQU 35h   ;0 momenteel maar voor uart zenden 

AD0_EL  BIT P3_data.5    ; Sensor Elleboog
AD0_SC  BIT P3_data.4  ; Sensor Schouder
ORG 0000H
;    MOV po_doel_knijpen, #0
;    MOV po_doel_draaien, #0
START:
    MOV SP, #7FH
    PUSH syscon0
    MOV  syscon0, #004h    ;
    PUSH port_page
    MOV  port_page, #000h
    
    ; P0.0, P0.1, P0.2, P0.6 zijn LED's
    ; P0.3 en P0.7 zijn I2C
    MOV  p0_dir, #11111111B 
    
    ;P1.6 en P1.7 zijn blauwe LED P1.1 is AD0
    MOV  p1_dir, #11111111B 
    MOV p3_dir, #11111111B
    
    POP  port_page
    POP  syscon0   
    lcall	initdipswitch  	
    lcall	lcdlighton	;anders zien we niet veel
	lcall	initcolor	;lcd scherm klaar zetten
    lcall	initlcd

    SETB AD0_EL     ;elleboog deactiveren
    LCALL initiic
    CLR  AD0_EL             ;Elleboog luistert 0xD0
    LCALL WEK_SENSOR
    SETB AD0_EL             ;Elterug naar 0xD2
    
    CLR AD0_SC 
    ;MPU6050 Wekken (Register 0x6B op 0 zetten)
    LCALL WEK_SENSOR     
    SETB AD0_SC     ;specifieke gyro terug uitzetten
    
;;;;;;;    LCALL inituart1

MAIN_LOOP:
    CLR AD0_EL  ;enkel elleboog
    LCALL LEES_ACCEL_1    
    SETB AD0_EL             ;elleboog uit         
    CLR AD0_SC
    LCALL LEES_ACCEL_2
    CLR AD0_SC
    ;LCALL send_uart
    ljmp MAIN_LOOP
    ; Wek de MPU6050
WEK_SENSOR:
    LCALL iicstart
    MOV A, #0D0H
    LCALL iicoutbyte
    MOV A, #6BH
    LCALL iicoutbyte
    MOV A, #00H
    LCALL iicoutbyte
    LCALL iicstop
    ret

LEES_ACCEL_1:
    LCALL iicstart
    MOV A, #0D0H            ;;MPU6050 schrijf-adres
    LCALL iicoutbyte
    MOV A, #3BH             ;Accel X  _H start adres dus 
    LCALL iicoutbyte
    LCALL iicstart
    MOV A, #0D1H            ;lees modus
    LCALL iicoutbyte
    
    LCALL iicinbyteack      ;Lees X_H
    LCALL Printen2a
    MOV el_doel_plooien, A
    LCALL iicinbyteack      ;we lezen de low byre maar slagen niet op
    
    LCALL iicinbyteack      ;y waarde 
    MOV el_doel_draaien, A
    LCALL Printen2
    LCALL iicinbytenack     
    LCALL iicstop
    RET   
LEES_ACCEL_2:
    LCALL iicstart
    MOV A, #0D0H            ;;MPU6050 schrijf-adres
    LCALL iicoutbyte
    MOV A, #3BH             ;Accel X  _H start adres dus 
    LCALL iicoutbyte
    LCALL iicstart
    MOV A, #0D1H            ;lees modus
    LCALL iicoutbyte
    
    LCALL iicinbyteack      ;Lees X_H
    LCALL Printen1a
    MOV sc_doel_pitch, A
    LCALL iicinbyteack      ;we lezen de low byre maar slagen niet op
    
    LCALL iicinbyteack      ;y waarde 
    MOV sc_doel_roll, A
    LCALL Printen1
    LCALL iicinbytenack     
    LCALL iicstop
    RET   
Printen2a:
        mov	r6,#00		;coordinaten zetten
		mov	r5,#00
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret    
Printen2:
        mov	r6,#00		;coordinaten zetten
		mov	r5,#50
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen1:
        mov	r6,#100		;coordinaten zetten
		mov	r5,#0
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
Printen1a:
        mov	r6,#100		;coordinaten zetten
		mov	r5,#50
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret
;Send_UART:
;    MOV A, #0FFH           ;Sync byte om te laten weten da er iets komt
;    LCALL uart1outchar
;    MOV A, sc_doel_pitch    
;    LCALL uart1outchar
;    MOV A, sc_doel_roll     
;    LCALL uart1outchar
;    MOV A, el_doel_plooien  
;    LCALL uart1outchar
;    MOV A, el_doel_draaien  
;    LCALL uart1outchar
;    MOV A, po_doel_knijpen  
;    LCALL uart1outchar
;    MOV A, po_doel_draaien  
;    LCALL uart1outchar
    
;    LCALL delaya0k05s          
;    RET

#include "c:\HEADERTIJMEN&LUCAS.inc"
#include "c:\colorxc0.inc"
;#include "c:\UART1.inc"
#include "c:\xcez5.inc"
END