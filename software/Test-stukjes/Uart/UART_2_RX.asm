;Eigen UART testprogramma (RX gedeelte)
;gebruikt 0.4 TXD en 0.5 RXD
;werkt op 9600 bps
;rood2 de ontvangen data wordt na het inlezen op rood2 gekopieert om de data te controleren
;geel1 indicatie dat het programma aan staat
;groen1 als indicatie van begin en einde lezen

    org 0000h
    mov sp,#7fh

    mov p0_dir,#00100111b
    mov p1_dir,#01000000b
    full_data   equ 11h ;Om de ontvangen data in op te slaan in de recvbyte subroutine
    delay       equ 12h ;delay waarde om de baudrate te bepalen
    mydata      equ 13h ;een kopie van de ontvangen data
    clr         geel1   ;indicatie dat het bordje met iets bezig is
    
;------------hoofdprogramma------------
main:
    ;om data te onvangen, data komt in de accu
    lcall   recvbyte
    mov     mydata, a   ;ontvangen data direct opslaan
    ;===================================================
    
    mov     r3,#8
    leeslus:
    mov     a, delay
    lcall   delay10us
    
    mov     a, mydata   ;onvangen data in de accu zetten en de LSB in de carry duwen
    rrc     a
    mov     mydata, a

    jnc     laag        ;led hoog of laag zetten afhankelijk van de bit in de carry
    clr     rood2 
    ljmp    verder
    laag:
    setb    rood2
    verder:

    djnz    r3,leeslus

    ljmp main

;------------subroutines------------
recvbyte:
;IDLE
    ;wachten op een 0 (startbit)
    idle:
    ;ik zou een counter kunnen komen dat de subroutine sluit
    ;als het te lang zit wachten op een start byte
    clr     groen1       ;indicatie dat de byte is ingelezen
    jb     RXD,idle
    
    ;halve baud periode wachten
    mov     a,#5
    lcall   delay10us
    setb    groen1

;LEZEN
    ;8 bit gaan inlezen en naar rechts schuiven (LSB) komt eerst
    mov     r2,#8
    mov     full_data, #0

    lus1:
    mov     a,delay
    lcall   delay10us
    
    mov     c,RXD
    mov     a, full_data
    rrc     a
    mov     full_data, a   

    djnz    r2,lus1

;STOPBIT
    ;een stopbit verwachten anders alles weggooien
    clr     groen1
    mov     a,delay
    lcall   delay10us

 
    jnb     RXD,fout
    ;als juist data in de accu steken
    mov     a,full_data
    ret
    setb    groen1

    fout:
    mov     a,#00h
    setb    groen1    
    
ret

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

