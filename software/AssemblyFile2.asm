; *******************************************************************************
; MPU6050 Gyroscoop Test voor XC888
; De waarde van Gyro-X (High Byte) wordt getoond op de LED's (Poort 3)
; SDA = P0.7, SCL = P0.3
; *******************************************************************************

ORG 0000H
    LJMP START

ORG 0030H
START:
    LCALL initiic        ; Configureer P0.7 en P0.3 voor I2C [cite: 20, 82]

    ; Alle LED's even kort aan als opstart-check (actief laag) 
    

    ; 2. MPU6050 Wekken (Register 0x6B op 0 zetten)
    LCALL iicstart       ; [cite: 21, 93]
    MOV A, #0D0H         ; MPU6050 schrijf-adres
    LCALL iicoutbyte     ; [cite: 25, 107]
    MOV A, #6BH          ; Register: PWR_MGMT_1
    LCALL iicoutbyte
    MOV A, #00H          ; Wek de sensor
    LCALL iicoutbyte
    LCALL iicstop        ; [cite: 22, 101]

MAIN_LOOP:
    ; 3. Selecteer het Gyroscoop X-as High register (0x43)
    LCALL iicstart
    MOV A, #0D0H         ; Schrijf-modus
    LCALL iicoutbyte
    MOV A, #43H          ; Start-register Gyro X_OUT_H
    LCALL iicoutbyte
    
    ; 4. Lees de waarde uit
    LCALL iicstart       ; Herhaalde start
    MOV A, #0D1H         ; Lees-modus
    LCALL iicoutbyte
    LCALL iicinbytenack  ; Lees 1 byte en stuur NACK (stopt de reeks) [cite: 24, 129]
    LCALL iicstop
    
    ; 5. De waarde naar de LED's sturen
    ; De accu (A) bevat nu de rotatiesnelheid.
    ; Omdat LED's op dit bord actief laag zijn, inverteren we de waarde 
    ; zodat een 'hogere' waarde meer licht geeft.
    CPL A                
    MOV groen1, A            ; Toon bitpatroon op LED's van Poort 3 [cite: 79, 80]

    
    
    SJMP MAIN_LOOP

; Inclusie van de driver file (verplicht onderaan) [cite: 4, 6]
#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
