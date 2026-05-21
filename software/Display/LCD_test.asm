;een test programma voor het scherm om verschillende functies op uit te testen

	org	0000h		;startadres van het programma
	mov	sp,#7fh		;stackpointer klaar zetten
	lcall	initdipswitch
	lcall	initlcd
	lcall	lcdlighton	;anders zien we niet veel
	lcall	initcolor	;lcd scherm klaar zetten

    mov   a, #36h         ; MADCTL commando
    lcall coloroutbytec
    mov   a, #068h        ; Waarde voor Landscape (kan variëren per schermtype)
    lcall coloroutbyted
    ;0C8: connector onder
    ;08A: connector rechts
    ;068: connector links

    lcall   achtergrond
    lcall   pijl

    mov     r5,#50      ;x-pos
    mov     r6,#50      ;y-pos
    mov     r4,#ffh     ;font kleur
    mov     r3,#ffh
    mov     r2,#00h     ;achtergrond kleur
    mov     r1,#00h
    mov     dptr,#test2
    lcall   draw_bitmap_16x32

    een   equ 40h
    tien    equ 41h
    honderd equ 42h
    mov     een,#00h
    mov     tien,#00h
    mov     honderd,#00h
;----------------------------------------
;           hoofdprogramma
;----------------------------------------
main:
    lcall   getal
    mov     a,#1
    lcall   delayA0k05s
    lcall   dec_counter

    ljmp main
;----------------------------------------
;           subroutines
;----------------------------------------
;scherm is 128x160 pixels
;voor colordraw functie
    ;R6 = x start
    ;R5 = Y start
    ;R4 = X eind
    ;R3 = Y eind
    ;R2 kleur MSB
    ;R1 kleur LSB

achtergrond:    ;WERKT
    mov r5, #0      ; X start
    mov r3, #120    ; X eind (max 127)
    mov r6, #0      ; Y start
    mov r4, #60    ; Y eind (max 159)
    mov r2, #07h    ; Kleur Groen MSB
    mov r1, #e0h    ; Kleur Groen LSB
    lcall colordraw
    ret

getal:          ;WERKT
	mov	r6,#00		;coordinaten zetten
	mov	r5,#00
	mov	r4,#f4h	;kleur
	mov	r3,#b8h
	mov	r2,#00h	;achtergrond kleur
	mov	r1,#00h
	mov	a,#21h
	lcall	coloroutbyte
    ret
pijl:           ;WERKT
    mov     r6,#30
    mov     r5,#10
    mov     r4,#30
    mov     r3,#70
    mov     r2,#6eh
    mov     r1,#f7h
    lcall   colordraw

        ret
dec_counter:
    lcall   hide_msb 
    ;Roggemans zijn coloroutbyte print 2 decimalen, ik wil er maar 3 hebben dus ik bedek de laatste
 
    inc     een
    mov     a,een
    cjne    a,#10,eind_een

    mov     een,#00h
    lcall   enkel   ;de nul nog printen
   
    inc     tien
    mov     a,tien
    cjne    a,#10,eind_tien

    mov     tien,#00h
    lcall   dubbel

    inc     honderd
    mov     a,honderd
    cjne    a,#10,eind_honderd

    mov     honderd,#00h
    lcall   trippel

    ljmp    eind
;----------------------------------------    
;hier stel je de waarde in met welke stappen je wil opstellen
enkel:
	mov	r6,#00     ;start Y    (blijft hetzelfde)
	mov	r5,#80     ;start X 
	mov	r4,#00h	;kleur
	mov	r3,#00h
	mov	r2,#ffh	;achtergrond kleur
	mov	r1,#ffh
	mov	a,een
    lcall	coloroutbyte
    ret
dubbel:
	mov	r6,#00     ;Y
	mov	r5,#64     ;X-16
	mov	r4,#00h	;kleur
	mov	r3,#00h
	mov	r2,#ffh	;achtergrond kleur
	mov	r1,#ffh
	mov	a,tien
    lcall	coloroutbyte
    ret
trippel:
	mov	r6,#00     ;Y
	mov	r5,#48     ;X-32
	mov	r4,#00h	;kleur
	mov	r3,#00h
	mov	r2,#ffh	;achtergrond kleur
	mov	r1,#ffh
	mov	a,honderd
    lcall	coloroutbyte
    ret

hide_msb:
    mov r5, #48     ; X-48 (X van laatste digit)
    mov r3, #64     ; X+16
    mov r6, #0      ; Y (hetzelfde als start)
    mov r4, #32     ; Y start +32
    mov r2, #07h    ; Kleur MSB
    mov r1, #e0h    ; Kleur LSB
    lcall colordraw
    ret

    ;alle waarde updaten maar enkel het gene dat nodig
    eind_honderd:
    lcall   trippel
    eind_tien:
    lcall   dubbel
    eind_een:
    lcall   enkel
    eind:
  
    ret
;----------------------------------------
;           gemini
;----------------------------------------

draw_bitmap_16x32:
    ; STAP 1: Venster instellen op het scherm (16 pixels breed, 32 hoog)
    ; Hier hergebruiken we de bestaande venster-routines van de driver
    push  dpl             ; Adres even parkeren op de stack
    push  dph
    
    ; Stel venster in: X = R5 t/m R5+15, Y = R6 t/m R6+31
    ; (Afhankelijk van hoe jouw specifieke driver de window-functie noemt)
    lcall set_window_16x32 

    pop   dph             ; Adres weer terugzetten in DPTR
    pop   dpl

    ; STAP 2: De pixels "pompen"
    mov   r7, #64         ; We gaan 64 bytes lezen
bit_loop_byte:
    clr   a
    movc  a, @a+dptr      ; Haal byte uit je bitmap
    mov   b, #8           ; 8 bits per byte
bit_loop_bits:
    rlc   a               ; Schuif de meest linkse bit in de Carry-vlag
    jc    paint_fg        ; Als bit 1 is -> voorgrondkleur
paint_bg:
    mov   a, r2           ; Achtergrondkleur (High byte)
    lcall coloroutbyted
    mov   a, r1           ; Achtergrondkleur (Low byte)
    lcall coloroutbyted
    sjmp  next_bit
paint_fg:
    mov   a, r4           ; Voorgrondkleur (High byte)
    lcall coloroutbyted
    mov   a, r3           ; Voorgrondkleur (Low byte)
    lcall coloroutbyted
next_bit:
    djnz  b, bit_loop_bits ; Doe dit voor alle 8 bits
    inc   dptr             ; Volgende byte uit je bitmap
    djnz  r7, bit_loop_byte; Doe dit voor alle 64 bytes
    ret
;========================================================================
set_window_16x32:
    ; X-as (Breedte = 16 pixels)
    mov   a, #2Ah         
    lcall coloroutbytec
    mov   a, #00h
    lcall coloroutbyted
    mov   a, r5           ; Gebruik R5 voor X
    lcall coloroutbyted
    mov   a, #00h
    lcall coloroutbyted
    mov   a, r5           
    add   a, #15          ; X-eind is X-start + 15
    lcall coloroutbyted

    ; Y-as (Hoogte = 32 pixels)
    mov   a, #2Bh         
    lcall coloroutbytec
    mov   a, #00h
    lcall coloroutbyted
    mov   a, r6           ; Gebruik R6 voor Y
    lcall coloroutbyted
    mov   a, #00h
    lcall coloroutbyted
    mov   a, r6           
    add   a, #31          ; Y-eind is Y-start + 31
    lcall coloroutbyted

    mov   a, #2Ch
    lcall coloroutbytec
    ret
;----------------------------------------
;           bitmap
;----------------------------------------
potato:
    db 0FFh, 0FFh  ; Rij 1: Volledig gevuld
    ; Rijen 2 t/m 31: Alleen randen
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 080h, 001h, 080h, 001h, 080h, 001h, 080h, 001h
    db 0FFh, 0FFh  ; Rij 32: Volledig gevuld

test1:
    ; Rijen 1-8
    db 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 003h, 0F0h, 003h, 0F0h, 0C3h, 0F0h, 0C3h, 0F0h, 0C3h, 0F0h, 0C3h
    ; Rijen 9-16
    db 0F0h, 0C3h, 0F0h, 0C3h, 0F0h, 0C3h, 0F0h, 0C3h, 0F0h, 003h, 0F0h, 003h, 0FFh, 0FFh, 0FFh, 0FFh
    ; Rijen 17-24
    db 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 08Fh, 090h, 08Fh, 093h, 08Fh, 093h, 08Fh, 093h, 08Fh, 093h, 08Fh
    ; Rijen 25-32
    db 093h, 08Fh, 093h, 08Fh, 093h, 08Fh, 093h, 08Fh, 090h, 08Fh, 0F0h, 08Fh, 0FFh, 0FFh, 0FFh, 0FFh

test2: ;WERKT
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h
    db 0FFh, 0FFh, 000h, 000h, 0FFh, 0FFh, 000h, 000h

#include	"c:\colorxc0.inc"
#include	"c:\xcez5.inc"
END