; Definieer de geheugenlocaties (anders herkent de compiler ze niet)
sc_huidig_pitch   EQU 50h
sc_huidig_roll    EQU 51h

; Definieer de bit-adressen
step4    BIT     P3_data.1
dir4     BIT     P3_data.0
groen1   BIT     P0_data.0  ; Pas aan naar je juiste poort/pin
groen2   BIT     P0_data.1  ; Pas aan naar je juiste poort/pin

ORG 0000h
INIT:
    MOV SP, #7Fh

    ; --- CRUCIAAL: Stel alle poorten in als OUTPUT ---
    ; De compiler heeft de juiste headers nodig voor 'p0_dir'
    ; Als dit fouten geeft, staan de namen anders in xcez5.inc
    MOV p0_dir, #11111111b
    MOV p1_dir, #11111111b
    MOV p3_dir, #11111111b
    MOV p4_dir, #11111111b

    ; Initialiseer huidige standen
    MOV sc_huidig_pitch, #0
    MOV sc_huidig_roll, #0
    
    CLR dir4             ; Zet richting vast

TEST_LOOP:
    SETB step4           ; Stap pin HOOG
    SETB groen1
    LCALL delay1ms       ; Wacht
    
    CLR step4            ; Stap pin LAAG
    CPL groen2
    LCALL delay1ms       ; Wacht
    
    SJMP TEST_LOOP       ; Herhaal dit eeuwig

; Includes MOETEN voor de END staan
#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"

END ; Dit is het einde van het bestand
