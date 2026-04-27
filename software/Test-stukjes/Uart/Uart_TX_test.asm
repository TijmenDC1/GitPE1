;programma om een karakter te sturen met de HC-12 RF module met behulp van Roggemans zijn include file
    org 0000h
    mov sp,#7fh
    lcall  inituart1          	;klaar zetten van de sio en de poorten
    mov     p0_dir,#00000011b   ;pin 0.0 en 0.1 als output zetten voor de rode leds
    clr     rood2

    
;------------hoofdprogramma------------
main:
    mov     a,#aah			;te verzenden karakter
    lcall   uart1outchar		;routine voor verzenden

    ljmp main

;------------subroutines------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; inituart1 zal UART1 klaar zetten voor gebruik van de seriele poort met
; volgende instellingen: 9600 baud.
;
; We gaan er van uit dat p0.5=RXD en p0.4=TXD.
; We gaan er van uit dat de RS232 gebruikt wordt. Dartoe moet JP2 in de positie 2-3
; staan. Voor RS485 is dat positie 1-2.
; Voor de zelftest wordt 2-3 van de RS232 stekker kortgesloten (onderkant PCB).
; De initialisatie voorziet ook niet in het klaar zetten van de "direction" lijn voor
; de rs485 (pin p0.6).
;
; Gebruikt geen registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inituart1: 	lcall	ports		;poorten juist zetten
		lcall	baudrate	;baud rate juist zetten
		ret

; poort 0.5 als input
; poort 0.4 als output en altsel juist zetten

ports:		push	port_page		  ;bewaren voor later (nu totaal overbodig)
		mov	port_page,#00h	          ;laatste 3 bits geven pagina aan
		mov	p0_dir,#00010000b	      ;p0.4=output
		mov	p0_data,#ffh		      ;alle outputs op 1
		mov	port_page,#02		      ;page 2 selecteren
		mov	p0_altsel0,#00010000b     ;altsel voor p0.4
		mov	p0_altsel1,#00010000b     ;idem
		pop	port_page		          ;terug herstellen
		ret

baudrate:     lcall	mapregs
		mov    scon1,#01010000b      ;UART initialiseren
		
; LET OP!!!!!!!!!!!!!! eerst BG laden, dan bcon, anders wordt BG waarde niet
; gebruikt!!

        mov    bg1,#155    		    ;gebruiken geen fractional devider
        mov    bcon1,#00000001b	    ;baud rate generator activeren
        mov    fdcon1,#00000000b    ;fractional devider staat uit
		lcall	nomapregs
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; uart1outchar IS EEN SUBROUTINE DIE EEN KARAKTER VIA DE SERIELE INTERFACE NAAR
; BUITEN STUURT. DE ROUTINE blijft wachten tot het karakter verzonder is.
;
; de routine gebruikt geen registers.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

uart1outchar: lcall	mapregs	                ;regs van uart1 zitten in de gemapte zone
		      MOV    SBUF1,A                ;KARAKTER VERZENDEN
uart1outchar1:JNB    scon1.1,uart1outchar1  ;WACHT TOT ZENDER BESCHIKBAAR
              ;CLR    scon1.1               ;LAAG MAKEN VAN DE BIT

;***** bovenstaande clr scon1.x instructie werkt NIET door een BUG in de chip!!
;***** Dat kan je terugvinden in de erratasheet op de site van infineon.com.
;***** Het probleem kan omzeild worden door mov scon1,# of door ANL scon1,#(allemaal 1 en een 0 op de plaats van bit x)
        clr     rood1           ;rode lateb branden om tonen dat data verstuurd is

		anl	scon1,#11111101b	;alternatief voor clear TI vlag

		lcall	nomapregs	;terug naar standaardset regs schakelen
		ret			        ;einde functie

#include "c:\xcez1.inc"
;#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

