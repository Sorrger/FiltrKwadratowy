.DATA
    align 16
const_0_04  dd 0.04           ; Sta³a do mno¿enia (1/25)
    align 16

.CODE
PUBLIC Darken
Darken PROC
    ; Zapisz rejestry nieulotne
    push rbp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    ; Pobierz parametry
    mov r10d, [rsp + 104]    ; r10d = imageHeight
    mov r12d, r8d            ; r12d = startY
    mov r13d, edx            ; r13d = width
    mov rbp, rcx             ; rbp = pixelData (wskaŸnik do danych pikseli)
    mov r9d, r9d             ; r9d = endY

    ; Pêtla po wierszach
row_loop:
    cmp r12d, r9d
    jge end_function         ; Jeœli y >= endY, zakoñcz

    ; Inicjalizacja x
    xor r14d, r14d           ; r14d = x

col_loop:
    cmp r14d, r13d
    jge next_row             ; Jeœli x >= width, przejdŸ do nastêpnego wiersza

    ; Inicjalizacja sum
    pxor xmm0, xmm0            ; sumBlue
    pxor xmm1, xmm1            ; sumGreen
    pxor xmm2, xmm2            ; sumRed

    ; Rêczne sumowanie pikseli w s¹siedztwie 5x5
    mov ecx, r12d
    sub ecx, 2                ; y-2
    call process_row
    add ecx, 1                ; y-1
    call process_row
    add ecx, 1                ; y
    call process_row
    add ecx, 1                ; y+1
    call process_row
    add ecx, 1                ; y+2
    call process_row

    ; Podziel sumy przez 25
    movss xmm4, dword ptr [const_0_04]  ; Za³aduj 0.04 do xmm4
    mulss xmm0, xmm4
    mulss xmm1, xmm4
    mulss xmm2, xmm4

    ; Konwertuj z powrotem do liczb ca³kowitych i ogranicz do 0-255
    cvttss2si ecx, xmm0 ; Blue
    cvttss2si edx, xmm1 ; Green
    cvttss2si r11d, xmm2 ; Red

    cmp ecx, 255
    jle clamp_blue
    mov ecx, 255
clamp_blue:
    cmp edx, 255
    jle clamp_green
    mov edx, 255
clamp_green:
    cmp r11d, 255
    jle clamp_red
    mov r11d, 255
clamp_red:

    ; Zapisz nowe wartoœci piksela
    mov eax, r12d
    imul eax, r13d
    add eax, r14d
    imul eax, 3

    mov byte ptr [rbp + rax], cl     ; Blue
    mov byte ptr [rbp + rax + 1], dl ; Green
    mov byte ptr [rbp + rax + 2], r11b ; Red

    inc r14d
    jmp col_loop

next_row:
    inc r12d
    jmp row_loop

end_function:
    ; Przywróæ rejestry
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

process_row PROC
    cmp ecx, 0
    jl skip_row
    cmp ecx, r10d
    jge skip_row

    mov esi, ecx
    imul esi, r13d            ; y_offset * width
    add esi, r14d             ; + x
    imul esi, 3               ; *3 (B, G, R)

    mov r15d, -2              ; x_offset start
sum_x_offsets:
    mov eax, r14d
    add eax, r15d
    cmp eax, 0
    jl skip_x_offset
    cmp eax, r13d
    jge skip_x_offset

    mov edx, ecx              ; y_new
    imul edx, r13d
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    mov esi, edx
    call sum_pixels_row

skip_x_offset:
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets

skip_row:
    ret
process_row ENDP

sum_pixels_row PROC
    movzx r8d, byte ptr [rbp + rsi]     ; Blue
    cvtsi2ss xmm4, r8d
    addss xmm0, xmm4

    movzx r8d, byte ptr [rbp + rsi + 1] ; Green
    cvtsi2ss xmm4, r8d
    addss xmm1, xmm4

    movzx r8d, byte ptr [rbp + rsi + 2] ; Red
    cvtsi2ss xmm4, r8d
    addss xmm2, xmm4
    ret
sum_pixels_row ENDP

Darken ENDP
END