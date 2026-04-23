;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Header file Lucas en Tijmen, beschrijving poorten
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------
;-------          LED's      ---------------------
;-------------------------------------------------
groen1       BIT     P0_data.0
groen2       BIT     P0_data.1
rood1        BIT     P0_data.2
rood2        BIT     P0_data.6
blauw1       BIT     P1_data.6
blauw2       BIT     P1_data.7


;-------------------------------------------------
;-------          STEP       ---------------------
;-------------------------------------------------
M1P_STEP   BIT     P1_data.3
M1R_STEP   BIT	   P1_data.5
M2P_STEP   BIT     P3_data.7
M2R_STEP   BIT     P3_data.1
M3P_STEP   BIT     P4_data.5
GRIJP_STEP   BIT     P4_data.7

;-------------------------------------------------
;-------          DIR        ---------------------
;-------------------------------------------------
M1P_DIR    BIT     P1_data.2
M1R_DIR    BIT     P1_data.4
M2P_DIR    BIT     P3_data.6
M2R_DIR    BIT     P3_data.0
M3P_DIR    BIT     P4_data.4
GRIJP_DIR    BIT     P4_data.6
;-------------------------------------------------
;-------     SPECIALMOTOR    ---------------------
;-------------------------------------------------
enable  BIT     p4_data.0
reset   BIT     p4_data.1
sleep   BIT     p4_data.2
ms1     BIT     p3_data.2
ms2     BIT     p3_data.3
ms3     BIT     p3_data.4

;-------------------------------------------------
;-------        INPUT        ---------------------
;-------------------------------------------------
IN1     BIT     P2_data.0
IN2     BIT     P2_data.1
IN3     BIT     P2_data.2
IN4     BIT     P2_data.3
IN5     BIT     P2_data.4
IN6     BIT     P2_data.5
IN7     BIT     P2_data.6
IN8     BIT     P2_data.7

;-------------------------------------------------
;-------          I2C        ---------------------
;-------------------------------------------------
SCK     BIT     P5_data.0
SDA     BIT     P5_data.1
CS      BIT     P5_data.2
A0      BIT     P5_data.3
RESET   BIT     P5_data.4

