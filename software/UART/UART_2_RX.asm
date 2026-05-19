;Eigen UART testprogramma (RX gedeelte)
;gebruikt 0.4 TXD en 0.5 RXD
;werkt op 9600 bps

;rood2      de ontvangen data wordt na het inlezen op rood2 gekopieert om de data te controleren
;geel1      indicatie dat het programma aan staat
;groen1     als indicatie van begin en einde lezen

    org 0000h
    mov sp,#7fh

    lcall   init_rxd
    mov p0_dir,#00000111b
    mov p1_dir,#01000000b

    full_data   equ 11h ;Om de ontvangen data in op te slaan in de recvbyte subroutine
    delay       equ 12h ;delay waarde om de baudrate te bepalen
    mydata      equ 13h ;een kopie van de ontvangen data

    ;9600 bps --> 104us
    mov         delay,#10
    clr         geel1   ;indicatie dat het bordje met iets bezig is
    clr         rood2   ;rood2 standaard laaghouden
    
;------------hoofdprogramma------------
main:
    ;om data te onvangen, data komt in de accu
    lcall   recvbyte
    mov     mydata, a   ;ontvangen data direct opslaan
    ;===================================================
    
    mov     r3,#8
    leeslus:
    mov     a, delay
    lcall   delay10usx
    
    mov     a, mydata   ;onvangen data in de accu zetten en de LSB in de carry duwen
    rrc     a
    mov     mydata, a   ;doorgeschoven data wordt terug gestoken

    mov     rood2, c

    djnz    r3,leeslus

    ljmp main

;------------subroutines------------
recvbyte: 
;IDLE
    ;wachten op een 0 (startbit)
    idle:
    ;er zou een counter kunnen komen dat de subroutine sluit
    ;als het te lang zit wachten op een start byte
    ;jb     IN1,idle
    jb     RXD,idle
    
    ;halve baud periode wachten
    clr     groen1       ;indicatie dat de byte is ingelezen
    ;mov     a,#5
    ;lcall   delay10usx
    lcall   delay10us
    lcall   delay10us
    lcall   delay10us
    lcall   delay10us
    lcall   delay10us
    setb    groen1

;LEZEN
    ;8 bit gaan inlezen en naar rechts schuiven (LSB) komt eerst
    mov     r2,#8
    mov     full_data,#0

    lus1:
    mov     a,delay
    lcall   delay10usx

    mov     c,RXD           ;ingelezen data in de carry zetten en die in full_data doorduwen
    ;mov     rood2, c        ;om te testen wat er allemaal wordt gelezen
    ;clr     rood2           ;zodat je even een peak ziet
    mov     a, full_data
    rrc     a
    mov     full_data, a   

    djnz    r2,lus1

;STOPBIT
    ;een stopbit verwachten anders alles weggooien
    ;clr     rood2
    clr     groen1
    mov     a,delay
    lcall   delay10usx

 
    jnb     RXD,fout
    ;als juist data in de accu steken
    mov     a,full_data
    setb    groen1
    ljmp    einde   ;!!als je niet jump naar einde voert die de fout code ook uit!!

    fout:
    mov     a,#00h
    setb    groen1   
 
    einde: 
    
ret

delay10usx:
; met de delay10us kan je geen waarde in de accu meegeven om een variabele periode in te stellen
; zoal de delayA0k05s (5ms x accu waarde)
; met deze functie kan je dat wel
    push    b
    mov     b,a

lusx:
    lcall   delay10us
    djnz    b,lusx

    pop     b
ret

init_rxd:
    push   syscon0              ;juiste map selecteren
    mov    syscon0,#004h
    push   port_page            ;tijdelijk bewaren zodat we dat kunnen herstellen
    mov    port_page,#001h      ;selecteer poort page 1
    orl    p0_pudsel,#00100000b ;Pul-Up-Device Select enkel voor pin 0.5 (RXD) pin
    orl    p0_puden,#00100000b  ;selectie van P0.5 inschakelen
    mov    port_page,#000h      ;pagina 0 selecteren
    anl    p0_dir,#11011111b    ;enkel 0.5 als input zetten (0) de rest met 1 and zodat het blijft zoals het is
    pop    port_page            ;herstellen in oorspronkelijke staat
    pop    syscon0              ;pagina terug herstellen
ret

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

