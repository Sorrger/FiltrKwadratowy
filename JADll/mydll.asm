;.586
;INCLUDE C:\masm32\include\windows.inc 

.DATA
add_value   db 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
max_value   db 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255

.CODE

Darken proc
    movdqa xmm1, xmmword ptr [add_value]
    
    movdqa xmm2, xmmword ptr [max_value]

    xor rbx, rbx               ; Zerowanie rbx

process_pixel:
    cmp rbx, rdx
    jge end_function

    movdqu xmm0, xmmword ptr [rcx + rbx]

    paddusb xmm0, xmm1

    movdqu xmmword ptr [rcx + rbx], xmm0

    add rbx, 16
    jmp process_pixel

end_function:
    ret
Darken endp

END
