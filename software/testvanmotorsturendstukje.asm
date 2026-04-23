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

;tijdelijke opslag
sc_data_tijdelijk equ 30h        ; Schouder (3 bytes: XH,YH,ZH)
el_data_tijdelijk equ 36h        ; Elleboog 
po_data_tijdelijk equ 3Ch        ; Pols

; Berekende hoek
sc_huidig_pitch    equ 50h     ;pitch
sc_huidig_roll     equ 51h        ;roll
el_huidig_plooien  equ 52h
el_huidig_draaien  equ 53h
po_huidig_knijpen  equ 53h
po_huidig_draaien    equ 54h

; DOEL
sc_doel_pitch     equ 55h
sc_doel_roll      equ 56h
el_doel_plooien   equ 57h
el_doel_draaien   equ 58h
po_doel_knijpen   equ 59h
po_doel_draaien   equ 60h

ORG 0000h
INIT:
    MOV SP,#7fh            ; Initialiseer de Stack Pointer
    
    ; soort start hoek instellen

    MOV sc_doel_pitch, #0
    MOV sc_doel_roll, #0
    MOV el_doel_plooien, #0
    MOV el_doel_draaien, #0
    MOV po_doel_knijpen, #0
    MOV po_doel_draaien, #0        ; Pols doel: 10 graden

;===============================================================================
; HOOFDPROGRAMMA
;===============================================================================

MAIN_LOOP:
    ;wacht op sync van uart 0xFF
    LCALL receivebyte       ;code van lucas zal byte in acc steken
    CJNE A, #0xFF, MAIN_LOOP 

    ;Leestbytes leze
    ; Deze bytes bevatten de accelerometer metingen
    LCALL READ_PACKET
    
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
; FUNCTIE: STUUR_GEWRICHT (SCHOUDER / ELLEBOOG / POLS)
; Beschrijving: Vergelijkt huidige hoek met de doel-hoek. Bepaalt de richting
; ==============================================================================
stuur_schouder:
M1P_berekenen:
    MOV A, sc_doel_pitch
    CLR C
    SUBB A, sc_huidig_pitch
    JZ M1R_berekenen             
    
    ; Bepaal richting
    JNC M1P_UP               ; Doel > Huidig omhoog
    SETB M1P_DIR             ; omlaag
    SJMP M1P_PULSE
M1P_UP:
    CLR M1P_DIR
M1P_PULSE:
    SETB M1P_STEP            ; Start puls
    LCALL delay_motor       ; Wacht (bepaalt snelheid motor)
    CLR M1P_STEP             ; Eindig puls
        
M1R_berekenen:
    MOV A, sc_doel_roll
    CLR C
    SUBB A, sc_huidig_roll
    JZ M1R_DONE              
    
    ; Bepaal richting
    JNC M1R_UP               ; Doel > Huidig omhoog
    SETB M1R_DIR             ; omlaag
    SJMP M1R_PULSE
M1R_UP:
    CLR M1R_DIR
M1R_PULSE:
    SETB M1R_STEP            ; Start puls
    LCALL delay_motor       ; Wacht (bepaalt snelheid motor)
    CLR M1R_STEP             ; Eindig puls
M1R_DONE:
    RET

stuur_elleboog:
M2P_berekenen:
    MOV A, el_doel_plooien
    CLR C
    SUBB A, el_huidig_plooien
    JZ M2R_berekenen                  
    JNC M2P_UP
    SETB M2P_DIR
    SJMP M2P_PULSE
M2P_UP:
    CLR M2P_DIR
M2P_PULSE:
    SETB M2P_STEP
    LCALL delay_motor
    CLR M2P_STEP

M2R_berekenen:
    MOV A, el_doel_draaien
    CLR C
    SUBB A, el_huidig_draaien
    JZ M2R_DONE                      
    JNC M2R_UP
    SETB M2R_DIR
    SJMP M2R_PULSE
M2R_UP:
    CLR M2R_DIR
M2R_PULSE:
    SETB M2R_STEP
    LCALL delay_motor
    CLR M2R_STEP
M2R_DONE:
    RET

stuur_pols:
M3P_berekenen:
    MOV A, po_doel_knijpen
    CLR C
    SUBB A, po_huidig_knijpen
    JZ M3R_DONE
    JNC M3P_UP
    SETB M3P_DIR
    SJMP M3P_PULSE
M3P_UP:
    CLR M3P_DIR
M3P_PULSE:
    SETB M3P_STEP
    LCALL delay_motor
    CLR M3P_STEP

M3R_berekenen:    
    MOV A, po_doel_knijpen
    CLR C
    SUBB A, po_huidig_knijpen
    JZ M3R_DONE
    JNC M3R_UP
    SETB M3R_DIR
    SJMP M3R_PULSE
M3R_UP:
    CLR M3R_DIR
M3R_PULSE:
    SETB M3R_STEP
    LCALL delay_motor
    CLR M3R_STEP
M3R_DONE:
    RET

; ==============================================================================
; HULPFUNCTIES
; ==============================================================================
delay_motor:
    MOV R5, #15
D_LUS: 
    DJNZ R5, D_LUS
    RET
receivebyte:
    ret
#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"

END