;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE
;-------------------------------------------------------------------------
; To jest przyk�adowa funkcja. 
;-------------------------------------------------------------------------
;parametry funkcji: RCX RDX R8 R9 stos, 
;lub zmiennoprzec.  XMM0 1 2 3
Increment proc
    ; RCX zawiera wska�nik na zmienn�
    mov     eax, [rcx]    ; Za�aduj warto�� zmiennej do EAX (32-bitowa operacja)
    inc     eax           ; Zwi�ksz warto�� o 1
    mov     [rcx], eax    ; Zapisz zaktualizowan� warto�� z powrotem do pami�ci
    ret
Increment endp

END 			;no entry point
;-------------------------------------------------------------------------