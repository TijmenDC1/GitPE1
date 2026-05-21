; Dit is een testprogramma voor de color driver.
; Geschreven door Roggemans M. (MGM) op 01/04/2013

		org	0000h		;startadres van het programma
		mov	sp,#7fh		;stackpointer klaar zetten
		lcall	initdipswitch
		lcall	initlcd
		lcall	lcdlighton	;anders zien we niet veel
		lcall	initcolor	;lcd scherm klaar zetten
		mov	dptr,#msg1
		lcall	lcdoutmsga	;iet laten zien

; coloroutchar:		sturen van een ascii code naar lcd (input=accu, R5=x, r6=y r4,r3=color (r4=msb))

		mov	r6,#00		;coordinaten zetten
		mov	r5,#00
		mov	r4,#07h	;kleur
		mov	r3,#e0h
		mov	r2,#00h	;achtergrond kleur
		mov	r1,#00h
		mov	a,#12h
		lcall	coloroutbyte
		mov	r6,#32		;coordinaten zetten
		mov	r5,#00
		mov	r4,#00h	;kleur
		mov	r3,#00h
		mov	r2,#ffh	;achtergrond kleur
		mov	r1,#e0h
		mov	dptr,#naam
		lcall	coloroutmsga
		mov	r6,#64		;coordinaten zetten
		mov	r5,#00
		mov	r4,#f8h	;kleur
		mov	r3,#00h
		mov	r2,#07h	;achtergrond kleur
		mov	r1,#ffh
		mov	dptr,#naam1
		lcall	coloroutmsga
		mov	r6,#96		;coordinaten zetten
		mov	r5,#00
		mov	r4,#00h	;kleur
		mov	r3,#00h
		mov	r2,#ffh	;achtergrond kleur
		mov	r1,#ffh
		mov	a,#00h
lus:		lcall	coloroutbyte
		inc	a
		push	acc
		mov	a,r3
		clr	c
		subb	a,#1
		mov	r3,a
		mov	a,r4
		subb	a,#0
		mov	r4,a
		mov	a,r1
		add	a,#1
		mov	r1,a
		mov	a,r2
		addc	a,#0
		mov	r2,a
		pop	acc
		push	06
		push	05
		push	04
		push	03
		mov	r6,#130
		mov	r5,#00
		mov	r4,#132
		mov	r3,#127
		lcall	colordraw
		pop	03
		pop	04
		pop	05
		pop	06
		ljmp	lus

msg1:		db	0ch,"zie de al iet?",000h
naam:		db	"Super",00h
naam1:		db	"Marc",00h

#include	"c:\colorxc0.inc"
#include	"c:\xcez5.inc"
END
