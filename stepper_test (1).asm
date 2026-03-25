        org 0000h
        mov sp,#7fh

        mov     port_page,#01h
        mov     p2_puden,#ffh
        mov     p2_pudsel,#00h
        mov     port_page,#00h
;-------inputs en zetten (1 out, 0 in)
   
        mov     p1_dir,#01111111b
        mov     p2_dir,#00000000b
        mov     p3_dir,#11111111b

        setb    p1_data.4
        setb     p3_data.0
        setb     p3_data.1

;hoofd programma
loop:
    ;cpl p1_data.4   ;richting veranderen

    ;mov     a,#15
    ;lcall delayA0k05s   ;15x 0,5ms
    ;lcall stap
    ;lcall stap
    ;lcall stap
    ;lcall stap
    ;lcall stap
    
    ljmp loop

;subroutines
stap:
    mov     a,#2
    cpl     p1_data.5       ;stap pin laag zetten
    clr     p3_data.4       ;een 1 sturen naar rode LED
    lcall   delayA0k05s
    cpl     p1_data.5       ;stap pin terug hoog 
    setb     p3_data.4       ;een 0 sturen naar rode LED
    lcall   delayA0k05s
    ret
      

#include "C:\xcez5T.inc"

END
