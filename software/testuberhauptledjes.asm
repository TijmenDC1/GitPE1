;test of de ledjes uberhaupt werken




ORG 0000H
    
    push    syscon0
    mov     syscon0,#004h
    push    port_page
    mov     port_page,#000h
    mov     p0_dir,#11111111b  
    mov     p1_dir,#11111111b
    pop    port_page
    pop    syscon0


START:
    
    CLR rood1
    
  

#include "c:\xcez5.inc"
#include "c:\HEADERTIJMEN&LUCAS.inc"
END
