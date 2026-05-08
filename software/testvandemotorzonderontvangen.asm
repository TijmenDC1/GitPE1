; ===============================================================================
; TEST PROGRAMMA: Robotarm Ontvanger (XC888)
; Beschrijving: Beweegt alle 6 de motor-assen naar een hardcoded positie.
; ===============================================================================

; --- MOTOR PIN DEFINITIES ---
M1P_STEP    BIT p0.0        ; Schouder Pitch
M1P_DIR     BIT p0.1
M1R_STEP    BIT p0.2        ; Schouder Roll
M1R_DIR     BIT p0.3
M2P_STEP    BIT p0.4        ; Elleboog Plooien
M2P_DIR     BIT p0.5
M2R_STEP    BIT p0.6        ; Elleboog Draaien
M2R_DIR     BIT p0.7
M3P_STEP    BIT p3.0        ; Pols Draaien
M3P_DIR     BIT p3.1
M3R_STEP    BIT p3.2        ; Knijp motor
M3R_DIR     BIT p3.3

; --- GEHEUGEN LOCATIES ---
; Huidige hoeken (Huidig)
sc_huidig_pitch    equ 50h
sc_huidig_roll     equ 51h
el_huidig_plooien  equ 52h
el_huidig_draaien  equ 53h
po_huidig_knijpen  equ 54h
po_huidig_draaien  equ 55h

; Doel hoeken (Doel)
sc_doel_pitch      equ 56h
sc_doel_roll       equ 57h
el_doel_plooien    equ 58h
el_doel_draaien    equ 59h
po_doel_knijpen    equ 60h
po_doel_draaien    equ 61h

ORG 0000h
    LJMP INIT_SYSTEM

ORG 0030h
INIT_SYSTEM:
    MOV SP,#7fh             ; Initialiseer Stack Pointer
    
    ; 1. Zet alle huidige posities op 0
    MOV sc_huidig_pitch,   #0
    MOV sc_huidig_roll,    #0
    MOV el_huidig_plooien, #0
    MOV el_huidig_draaien, #0
    MOV po_huidig_knijpen, #0
    MOV po_huidig_draaien, #0

    ; 2. STEL TEST-DOELEN IN (Pas deze getallen aan om te testen)
    MOV sc_doel_pitch,     #40
    MOV sc_doel_roll,      #15
    MOV el_doel_plooien,   #60
    MOV el_doel_draaien,   #30
    MOV po_doel_knijpen,   #10
    MOV po_doel_draaien,   #80

    ; 3. Initialiseer poorten via xcez5
    LCALL initleds          ; Configureert P3

; ===============================================================================
; HOOFDPROGRAMMA
; ===============================================================================
MAIN_LOOP:
    ; We slaan de UART-check over en sturen direct de gewrichten aan
    LCALL stuur_schouder
    LCALL stuur_elleboog
    LCALL stuur_pols

    ; Vertraging om de beweging vloeiend en zichtbaar te maken
    MOV A, #1               ; 0.05s pauze
    LCALL delaya0k05s       

    SJMP MAIN_LOOP

; ==============================================================================
; FUNCTIE: STUUR_SCHOUDER
; ==============================================================================
stuur_schouder:
    ; --- Pitch ---
    MOV A, sc_doel_pitch
    CLR C
    SUBB A, sc_huidig_pitch
    JZ M1R_calc             ; Doel bereikt? Volgende as.
    
    JNC M1P_UP              ; Als Doel > Huidig
    SETB M1P_DIR            ; Omlaag
    DEC sc_huidig_pitch     ; Werk positie bij
    SJMP M1P_PULSE
M1P_UP:
    CLR M1P_DIR             ; Omhoog
    INC sc_huidig_pitch     ; Werk positie bij
M1P_PULSE:
    SETB M1P_STEP
    LCALL delay_motor
    CLR M1P_STEP

M1R_calc:
    ; --- Roll ---
    MOV A, sc_doel_roll
    CLR C
    SUBB A, sc_huidig_roll
    JZ M1_DONE
    
    JNC M1R_RIGHT
    SETB M1R_DIR
    DEC sc_huidig_roll
    SJMP M1R_PULSE
M1R_RIGHT:
    CLR M1R_DIR
    INC sc_huidig_roll
M1R_PULSE:
    SETB M1R_STEP
    LCALL delay_motor
    CLR M1R_STEP
M1_DONE:
    RET

; ==============================================================================
; FUNCTIE: STUUR_ELLEBOOG
; ==============================================================================
stuur_elleboog:
    ; --- Plooien ---
    MOV A, el_doel_plooien
    CLR C
    SUBB A, el_huidig_plooien
    JZ M2R_calc
    
    JNC M2P_FWD
    SETB M2P_DIR
    DEC el_huidig_plooien
    SJMP M2P_PULSE
M2P_FWD:
    CLR M2P_DIR
    INC el_huidig_plooien
M2P_PULSE:
    SETB M2P_STEP
    LCALL delay_motor
    CLR M2P_STEP

M2R_calc:
    ; --- Draaien ---
    MOV A, el_doel_draaien
    CLR C
    SUBB A, el_huidig_draaien
    JZ M2_DONE
    
    JNC M2R_CW
    SETB M2R_DIR
    DEC el_huidig_draaien
    SJMP M2R_PULSE
M2R_CW:
    CLR M2R_DIR
    INC el_huidig_draaien
M2R_PULSE:
    SETB M2R_STEP
    LCALL delay_motor
    CLR M2R_STEP
M2_DONE:
    RET

; ==============================================================================
; FUNCTIE: STUUR_POLS
; ==============================================================================
stuur_pols:
    ; --- Knijpen ---
    MOV A, po_doel_knijpen
    CLR C
    SUBB A, po_huidig_knijpen
    JZ M3R_calc
    
    JNC M3P_CLOSE
    SETB M3P_DIR
    DEC po_huidig_knijpen
    SJMP M3P_PULSE
M3P_CLOSE:
    CLR M3P_DIR
    INC po_huidig_knijpen
M3P_PULSE:
    SETB M3P_STEP
    LCALL delay_motor
    CLR M3P_STEP

M3R_calc:
    ; --- Draaien ---
    MOV A, po_doel_draaien
    CLR C
    SUBB A, po_huidig_draaien
    JZ M3_DONE
    
    JNC M3R_CW
    SETB M3R_DIR
    DEC po_huidig_draaien
    SJMP M3R_PULSE
M3R_CW:
    CLR M3R_DIR
    INC po_huidig_draaien
M3R_PULSE:
    SETB M3R_STEP
    LCALL delay_motor
    CLR M3R_STEP
M3_DONE:
    RET

; ==============================================================================
; HULPFUNCTIES
; ==============================================================================
delay_motor:
    MOV R5, #15             ; Bepaalt de breedte van de stap-puls
D_LUS: 
    DJNZ R5, D_LUS
    RET

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"

END