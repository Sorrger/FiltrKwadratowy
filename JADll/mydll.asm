;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE
;-------------------------------------------------------------------------
; To jest przyk³adowa funkcja. 
;-------------------------------------------------------------------------
;parametry funkcji: RCX RDX R8 R9 stos, 
;lub zmiennoprzec.  XMM0 1 2 3
Increment proc
    ; RCX zawiera wskaŸnik na zmienn¹
    mov     eax, [rcx]    ; Za³aduj wartoœæ zmiennej do EAX (32-bitowa operacja)
    inc     eax           ; Zwiêksz wartoœæ o 1
    mov     [rcx], eax    ; Zapisz zaktualizowan¹ wartoœæ z powrotem do pamiêci
    ret
Increment endp

END 			;no entry point
;-------------------------------------------------------------------------