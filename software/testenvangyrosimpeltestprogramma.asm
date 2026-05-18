
AD0_EL  BIT P3_data.5    ; Sensor Elleboog
ORG 0000H
    LJMP START

ORG 0060H
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
    ;CLR  P0_data.0          ; Groen 1
    ;CLR  P0_data.1          ; Groen 2
    ;CLR  P0_data.2          ; Rood 1
    ;CLR  P0_data.6         ; Rood 2
    ;CLR  P1_data.6          ; Blauw 1
    ;CLR  P1_data.7           ; Blauw 2

    
MAIN_LOOP:
    CLR AD0_EL  ;enkel elleboog
    LCALL LEES_X_AS
    SETB AD0_EL             ;elleboog uit
    SETB rood1    ; Groen 1 uit
    SETB groen1    ; Groen 2 uit
    SETb geel1
   ; --- STAP 2: VERGELIJK DE WAARDE ---
    
    ; Check voor 90 graden (waarde > 60)
    MOV R2, A          
    CLR C               ; 
    SUBB A, #50       ;Trek 60
    JNC IS_90_GRADEN    ;Als waarde >= 60 spring naar 90 graden

    ; Check voor 45 graden (waarde > 30)
    MOV A, R2           
    CLR C
    SUBB A, #40
    JNC IS_45_GRADEN    ;Als waarde >= 30 pring naar 45 graden

    ;30 graden
    CLR geel1          
    SJMP VOLGENDE

IS_45_GRADEN:
    CLR groen1           
    SJMP VOLGENDE

IS_90_GRADEN:
    CLR rood1          

    ; De ruwe data van de accelerometer naar Poort 3 (als je daar LED's hebt)
volgende:
    
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

LEES_X_AS:
    ;Lees de Accelerometer x-as
    LCALL iicstart
    MOV A, #0D0H
    LCALL iicoutbyte
    MOV A, #3BH
    LCALL iicoutbyte
    LCALL iicstop

    LCALL iicstart
    MOV A, #0D1H
    LCALL iicoutbyte
    LCALL iicinbytenack
        
    LCALL iicstop
     LCALL Printen2a    
    ;SETB rood1    
    ;SETB groen1    
    ;SETB geel1    
        ; Rood 2 uit
    RET   
Printen2a:
        mov	r6,#10		;coordinaten zetten
		mov	r5,#15
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		lcall	coloroutbyte
        ret    

#include "c:\colorxc0.inc"
#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
END