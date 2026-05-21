;======================================    
;------------initialisatie------------
;======================================
    org 0000h
    mov sp,#7fh

    ;poort initialisatie
    lcall   initftoetsen    ;poort 2

    ;input-output initialisatie
    mov p0_dir,#11111111b   ;enkel leds
    mov p1_dir,#11111111b   ;enkel leds
    mov p2_dir,#00000000b   ;alle ingangen
    mov p3_dir,#11111111b
    mov p4_dir,#11111111b

    ;LCD scherm initialisatie
    lcall	initlcd
	lcall	lcdlighton	
	lcall	initcolor	

    mov   a, #36h         ; MADCTL commando
    lcall coloroutbytec
    mov   a, #068h        ;in landscape zetten
    lcall coloroutbyted
    ;0C8: connector onder
    ;08A: connector rechts
    ;068: connector links
    mov     bgc_msb,#25h
    mov     bgc_msb,#e0h
    lcall   achtergrond


    ;adressen
    ;om de richting van de encoders te bepalen
    token_0     equ 20h ;elleboog
    token_1     equ 21h ;pols
    token_2     equ 22h ;vingers

    bgc_msb     equ 30h ;BackGroundColour     
    bgc_lsb     equ 31h   
    Lboog_count equ 33h
    mov Lboog_count,#00h    ;startwaarde

;======================================    
;------------hoofdprogramma------------
;======================================
main:
    lcall   elleboog_pitch  ;encoder
    lcall   pols            ;encoder
    lcall   vingers         ;encoder    

    ljmp main
;======================================
;------------subroutines---------------
;======================================
;/////////////////////////////////////
;------------subroutines I------------
;/////////////////////////////////////

;------------encoders-----------------

elleboog_pitch:
    jnb     IN1,checkR_0      ;met te klok
    jnb     IN2,checkL_0      ;tegen de klok in
    terug_0:
    ret
pols:
    jnb     IN3,checkR_1      
    jnb     IN4,checkL_1
    terug_1:  
    ret
vingers:
    jnb     IN5,checkR_2     
    jnb     IN6,checkL_2
    terug_2:  
    ret

;------------LCD-display--------------
achtergrond:
    mov r5,#0       ; X start
    mov r3,#159     ; X eind (max 159)
    mov r6,#0       ; Y start
    mov r4,#127      ; Y eind (max 127)
    mov r2,#25h  ;vastgestelde achtergrond kleur
    mov r1,#e0h
    ;mov r2,bgc_msb  ;vastgestelde achtergrond kleur
    ;mov r1,bgc_lsb    
    lcall colordraw
    ret
;/////////////////////////////////////
;------------subroutines II-----------
;/////////////////////////////////////

;------------encoders-----------------
;////////////elleboog////////////////////////////////
checkR_0:       
    mov     a,token_0
    cjne    a,00h,verder_0
    ;als de token hetzelfde is(AB AB BA)
    cpl     dir3
    ;clr     rood1      ;gaat CW
    ;setb    rood2     

    verder_0:   ;als de token anders is (AB AB AB)
    mov     token_0,#00h
    lcall   stap_Lboog
    ;lcall   display_Lboog
    ljmp    terug_0

checkL_0:
    mov     a,token_0
    cjne    a,01h,verder_1
    ;als de token hetzelfde is(BA BA AB)
    cpl     dir3
    ;clr     rood2      ;gaat CCW
    ;setb    rood1

    verder_1:   ;als de token anders is (BA BA BA)
    mov     token_0,#01h
    lcall   stap_Lboog
    ;lcall   display_Lboog
    ljmp    terug_0


;////////////pols////////////////////////////////
checkR_1:       
    mov     a,token_1
    cjne    a,00h,verder_2
    ;als de token hetzelfde is(AB AB BA)
    cpl     dir5
    clr     geel1      ;gaat CW
    setb    geel2     

    verder_2:   ;als de token anders is (AB AB AB)
    mov     token_1,#00h
    lcall   stap_pols
    ljmp    terug_1

checkL_1:
    mov     a,token_1
    cjne    a,01h,verder_3
    ;als de token hetzelfde is(BA BA AB)
    cpl     dir5
    clr     geel2      ;gaat CCW
    setb    geel1

    verder_3:   ;als de token anders is (BA BA BA)
    mov     token_1,#01h
    lcall   stap_pols
    ljmp    terug_1

;////////////vingers////////////////////////////////
checkR_2:       
    mov     a,token_2
    cjne    a,00h,verder_4
    ;als de token hetzelfde is(AB AB BA)
    cpl     dir6
    clr     groen1      ;gaat CW
    setb    groen2     

    verder_4:   ;als de token anders is (AB AB AB)
    mov     token_2,#00h
    lcall   stap_vingers
    ljmp    terug_2

checkL_2:
    mov     a,token_2
    cjne    a,01h,verder_5
    ;als de token hetzelfde is(BA BA AB)
    cpl     dir6
    clr     groen2      ;gaat CCW
    setb    groen1

    verder_5:   ;als de token anders is (BA BA BA)
    mov     token_2,#01h
    lcall   stap_vingers
    ljmp    terug_2
;/////////////////////////////////////
;------------subroutines III----------
;/////////////////////////////////////

;/////////////////////////////////////
;------------stappen_moters-----------
;/////////////////////////////////////
stap_Lboog:
    push    b
    mov     b,#10

    stappen_Lboog:
    mov     a,#1
    cpl     step3       ;stap wordt gelezen bij rising edge
    ;clr     rood1       ;indicatie led voor de stap
    lcall   delay1ms    ;0,001s
    cpl     step3
    ;setb    rood1
    lcall   delay1ms
    djnz    b,stappen_Lboog

    pop     b
    ret

stap_pols:
    push    b
    mov     b,#10

    stappen_pols:
    mov     a,#1
    cpl     step5       
    ;clr     rood1       
    lcall   delay1ms    
    cpl     step5
    ;setb    rood1
    lcall   delay1ms
    djnz    b,stappen_pols

    pop     b
    ret
stap_vingers:
    push    b
    mov     b,#10

    stappen_vingers:
    mov     a,#1
    cpl     step6       
    ;clr     rood1       
    lcall   delay1ms    
    cpl     step6
    ;setb    rood1
    lcall   delay1ms
    djnz    b,stappen_vingers

    pop     b

    ret
;/////////////////////////////////////
;------------display------------------
;/////////////////////////////////////   
display_Lboog:
    mov    r6,#20		;coordinaten zetten
	mov    r5,#10
	mov    r4,#00h	;kleur
	mov    r3,#00h
	mov    r2,#25h	;achtergrond kleur
	mov    r1,#e0h
    ;checken of we moeten optellen of aftrekken
    ;als DIR pin hoog is draad de motor de andere kant dus trekken we af
    jnb     dir3,subb_Lboog
    ;optellen
    mov     a,Lboog_count
    add     a,#01h
    mov     Lboog_count,a
    ljmp    add_Lboog

    subb_Lboog:
    mov     a,Lboog_count
    subb    a,#01h
    mov     Lboog_count,a

    add_Lboog:
	mov    a,Lboog_count
	lcall	coloroutbyte
    ret

#include "c:\colorxc0.inc"
#include "c:\xcez5T.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
        END        

