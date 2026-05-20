;Ontvagende bord
; --- MOTOR PIN DEFINITIES ---
; Gewricht 1: Schouder
;M1P_STEP    BIT p0.0        ; Pitch stap (Omhoog/Omlaag)
;M1P_DIR     BIT p0.1
;M1R_STEP    BIT p0.2        ; Roll stap (Links/Rechts)
;M1R_DIR     BIT p0.3

; Gewricht 2: Elleboog
;M2P_STEP    BIT p0.4         ;plooien van de arm
;M2P_DIR     BIT p0.5
;M2R_STEP    BIT p0.6         ; draaien onderarm
;M2R_DIR     BIT p0.7

; Gewricht 3: Pols & Grijper
;M3P_STEP    BIT p3.0        ;pols draaien
;M3P_DIR     BIT p3.1
;M3R_STEP    BIT p3.2        ; Knijp motor
;M3R_DIR     BIT p3.3
step1   BIT     P1_data.3
step2   BIT     P1_data.5
step3   BIT     P3_data.7
step4   BIT     P3_data.1
step5   BIT     P4_data.5
step6   BIT     P4_data.7

;-------------------------------------------------
;-------          DIR        ---------------------
;-------------------------------------------------
dir1    BIT     P1_data.2
dir2    BIT     P1_data.4
dir3    BIT     P3_data.6
dir4    BIT     P3_data.0
dir5    BIT     P4_data.4
dir6    BIT     P4_data.6
;tijdelijke opslag
sc_data_tijdelijk equ 30h        ; Schouder (3 bytes: XH,YH,ZH)
el_data_tijdelijk equ 36h        ; Elleboog 
po_data_tijdelijk equ 3Ch        ; Pols

; Berekende hoek
sc_huidig_pitch    equ 50h     ;pitch
sc_huidig_roll     equ 51h        ;roll
el_huidig_plooien  equ 52h
el_huidig_draaien  equ 53h
po_huidig_knijpen  equ 54h
po_huidig_draaien    equ 55h

; DOEL
sc_doel_pitch     equ 56h
sc_doel_roll      equ 57h
el_doel_plooien   equ 58h
el_doel_draaien   equ 59h
po_doel_knijpen   equ 5Ah
po_doel_draaien   equ 5Bh

;momenteel laat deze automatisch de motor draaien omdat we de start hoek handmatig instellen ma het doel is dus dat deze de hoek binnen krijgt via de uart verbinding
;als je wilt lucas kan je misschien een s testen of hij ook meerdere motoren laat draaien heb ik nog niet kunnen doen is gewoon de start hoek handmatig instellen zoals bij el_doel_draaien is gebeurd de uart verbinding heb ik wel uitgezet


ORG 0000h

INIT:
    
    MOV SP, #7FH
    PUSH syscon0
    MOV  syscon0, #004h    ;
    PUSH port_page
    MOV  port_page, #000h            
    MOV p0_dir,#11111111b
    MOV p1_dir,#11111111b
    MOV p3_dir,#11111111b
    MOV p4_dir,#11111111b
    POP  port_page
    POP  syscon0   
    lcall	initdipswitch  	
    lcall	lcdlighton	;anders zien we niet veel
	lcall	initcolor	;lcd scherm klaar zetten
    lcall	initlcd

    MOV sc_huidig_pitch,    #0
    MOV sc_huidig_roll,     #0
    MOV el_huidig_plooien,  #0
    MOV el_huidig_draaien,  #0
    MOV po_huidig_knijpen,  #0
    MOV po_huidig_draaien,  #0 


    ; soort start hoek instellen
    MOV sc_doel_pitch, #0
    MOV sc_doel_roll, #0
    MOV el_doel_plooien, #0
    MOV el_doel_draaien, #200
    MOV po_doel_knijpen, #0
        MOV po_doel_draaien, #0       ; Pols doel: 10 graden

;===============================================================================
; HOOFDPROGRAMMA n
;===============================================================================

MAIN_LOOP:
    ;wacht op sync van uart 0xFF
    ;LCALL receivebyte       
    ;CJNE A, #0xFF, MAIN_LOOP 
    ;LCALL READ_PACKET ;leest de 6 bytes en zet deze in juiste doel
    
    ;LCALL READ_PACKET
    ;LCALL stuur_schouder
    LCALL stuur_elleboog
    mov A, el_doel_draaien
    LCALL PRINTEN1
    MOV A, el_huidig_draaien
    LCALL PRINTEN2
    mov A, el_huidig_draaien
    ;LCALL stuur_pols
    SJMP MAIN_LOOP


    
;===============================================================================
;READ_PACKET leest alle bytes van de nodige hoeken
;===============================================================================
READ_PACKET:
    LCALL receivebyte
    MOV sc_doel_pitch,a
    LCALL receivebyte
    MOV sc_doel_roll, a
    LCALL receivebyte
    MOV el_doel_plooien, a
    LCALL receivebyte
    MOV el_doel_draaien, a
    LCALL receivebyte
    MOV po_doel_knijpen, a
    LCALL receivebyte
    MOV po_doel_draaien,a 
    RET
     
; ==============================================================================
; FUNCTIE: STUUR_SCHOUDER (M1P & M1R)
; ==============================================================================
stuur_schouder:
M1P_berekenen:
    MOV A, sc_doel_pitch
    CLR C
    SUBB A, sc_huidig_pitch
    JZ M1R_berekenen        ; Als er geen verschil is naar de roll 

    ; Bepaal richting
    JNC M1P_UP              ;Doel > Huidig omhoog
M1P_DOWN:
    SETB dir1            ; omlaag
    CPL A                   ;two's complement en dan inc met 1
    INC  A
    SJMP M1P_START
M1P_UP:
    CLR DIR1             ;omhoog
M1P_START:
    MOV R5,a        ;Verschil in R4 voor de stappen-lus
M1P_PULSE:
    SETB STEP1           ; Start puls
    LCALL delay1ms         ;Wacht (snelheid)
    CLR STEP1            ; Eindig puls
    LCALL delay1ms
    DJNZ R5, M1P_PULSE       ; Herhaal tot B nul is
    MOV sc_huidig_pitch, sc_doel_pitch ; Werk stand bij

M1R_berekenen:
    MOV A, sc_doel_roll
    CLR C
    SUBB A, sc_huidig_roll
    JZ M1R_DONE

    JNC M1R_UP
M1R_DOWN:
    SETB DIR2
    CPL A
    INC A
    SJMP M1R_START
M1R_UP:
    CLR DIR2
M1R_START:
    MOV R6, A

M1R_PULSE:
    SETB STEP2
    LCALL delay1ms
    CLR STEP2
    LCALL delay1ms
    DJNZ R6, M1R_PULSE
    MOV sc_huidig_roll, sc_doel_roll
M1R_DONE:
    RET

; ==============================================================================
; FUNCTIE: STUUR_ELLEBOOG (M2P & M2R)
; ==============================================================================
stuur_elleboog:
M2P_berekenen:
    MOV A, el_doel_plooien
    CLR C
    SUBB A, el_huidig_plooien
   
    JZ M2R_berekenen

    JNC M2P_UP
M2P_DOWN:
    SETB DIR3
    CPL A
    INC A
    SJMP M2P_START
M2P_UP:
    CLR DIR3
M2P_START:
    MOV R4, a
M2P_PULSE:

    SETB STEP3
    LCALL delay1ms
    CLR STEP3
    LCALL delay1ms
    DJNZ R4, M2P_PULSE
    MOV el_huidig_plooien, el_doel_plooien

M2R_berekenen:
    MOV A, el_doel_draaien
    CLR C
    SUBB A, el_huidig_draaien
    
    JZ M2R_DONE

    JNC M2R_UP
M2R_DOWN:
    SETB DIR4
    CPL A
    INC A
    SJMP M2R_START
M2R_UP:
    CLR DIR4
M2R_START:
    MOV R3, A
M2R_PULSE:

    SETB STEP4
    LCALL delay1ms
    CLR STEP4
    LCALL delay1ms
    DJNZ R3, M2R_PULSE
    MOV el_huidig_draaien, el_doel_draaien
M2R_DONE:
    RET

; ==============================================================================
; FUNCTIE: STUUR_POLS (M3P & M3R)
; ==============================================================================
stuur_pols:
M3P_berekenen:
    MOV A, po_doel_knijpen
    CLR C
    SUBB A, po_huidig_knijpen
    JZ M3R_berekenen

    JNC M3P_UP
M3P_DOWN:
    SETB DIR5
    CPL A
    INC A
    SJMP M3P_START
M3P_UP:
    CLR DIR5
M3P_START:
    MOV R7,a
M3P_PULSE:
    SETB STEP5
    LCALL delay1ms
    CLR STEP5
    LCALL delay1ms
    DJNZ R7, M3P_PULSE
    MOV po_huidig_knijpen, po_doel_knijpen

M3R_berekenen:
    MOV A, po_doel_draaien
    CLR C
    SUBB A, po_huidig_draaien
    JZ M3R_DONE

    JNC M3R_UP
M3R_DOWN:
    SETB DIR6
    CPL A
    INC A
    SJMP M3R_START
M3R_UP:
    CLR DIR6
M3R_START:
    MOV R2,A
M3R_PULSE:
    SETB STEP6
    LCALL delay1ms
    CLR STEP6
    LCALL delay1ms
    DJNZ R2, M3R_PULSE
    MOV po_huidig_draaien, po_doel_draaien
M3R_DONE:
    RET


receivebyte:
;    LCALL uart1inchar

ret
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

#include "c:\HEADERTIJMEN&LUCAS.inc"
#include "c:\colorxc0.inc"
;#include "c:\UART1.inc"
#include "c:\xcez5.inc"

END