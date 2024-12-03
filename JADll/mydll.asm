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
    ; Iteracja po przesuniêciach pionowych (-2 do +2)
    mov ecx, r12d             ; y
    sub ecx, 2                 ; y-2
    cmp ecx, 0
    jl skip_row_minus_2
    mov esi, ecx
    imul esi, r13d            ; y_offset * width
    add esi, r14d              ; + x
    imul esi, 3                ; *3 (B, G, R)
    ; Teraz esi = (y-2) * width + x) * 3
    ; Dodanie sumowania poziomych x_offsets (-2 do +2)
    mov r15d, -2              ; x_offset start
sum_x_offsets_minus_2:
    ; Oblicz x_new = x + x_offset
    mov eax, r14d
    add eax, r15d
    ; SprawdŸ granice x
    cmp eax, 0
    jl skip_x_offset_minus_2
    cmp eax, r13d
    jge skip_x_offset_minus_2
    ; Oblicz indeks pikselu: (y_new * width + x_new) * 3
    mov edx, ecx              ; y_new = y-2
    imul edx, r13d            ; y_new * width
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    ; Ustaw rsi na indeks pikselu
    mov esi, edx
    ; Dodaj piksel do sumy
    call sum_pixels_row
skip_x_offset_minus_2:
    ; Inkrementuj x_offset
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets_minus_2

skip_row_minus_2:

    ; Rz¹d -1
    mov ecx, r12d
    sub ecx, 1
    cmp ecx, 0
    jl skip_row_minus_1
    mov esi, ecx
    imul esi, r13d
    add esi, r14d
    imul esi, 3
    ; Dodanie sumowania poziomych x_offsets (-2 do +2)
    mov r15d, -2              ; x_offset start
sum_x_offsets_minus_1:
    ; Oblicz x_new = x + x_offset
    mov eax, r14d
    add eax, r15d
    ; SprawdŸ granice x
    cmp eax, 0
    jl skip_x_offset_minus_1
    cmp eax, r13d
    jge skip_x_offset_minus_1
    ; Oblicz indeks pikselu: (y_new * width + x_new) * 3
    mov edx, ecx              ; y_new = y-1
    imul edx, r13d            ; y_new * width
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    ; Ustaw rsi na indeks pikselu
    mov esi, edx
    ; Dodaj piksel do sumy
    call sum_pixels_row
skip_x_offset_minus_1:
    ; Inkrementuj x_offset
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets_minus_1

skip_row_minus_1:

    ; Rz¹d 0
    mov ecx, r12d
    ; (y_new = y)
    ; Dodanie sumowania poziomych x_offsets (-2 do +2)
    mov esi, ecx
    imul esi, r13d
    add esi, r14d
    imul esi, 3
    mov r15d, -2              ; x_offset start
sum_x_offsets_0:
    ; Oblicz x_new = x + x_offset
    mov eax, r14d
    add eax, r15d
    ; SprawdŸ granice x
    cmp eax, 0
    jl skip_x_offset_0
    cmp eax, r13d
    jge skip_x_offset_0
    ; Oblicz indeks pikselu: (y_new * width + x_new) * 3
    mov edx, ecx              ; y_new = y
    imul edx, r13d            ; y_new * width
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    ; Ustaw rsi na indeks pikselu
    mov esi, edx
    ; Dodaj piksel do sumy
    call sum_pixels_row
skip_x_offset_0:
    ; Inkrementuj x_offset
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets_0

    ; Rz¹d +1
    mov ecx, r12d
    add ecx, 1
    cmp ecx, r10d
    jge skip_row_plus_1
    mov esi, ecx
    imul esi, r13d
    add esi, r14d
    imul esi, 3
    ; Dodanie sumowania poziomych x_offsets (-2 do +2)
    mov r15d, -2              ; x_offset start
sum_x_offsets_plus_1:
    ; Oblicz x_new = x + x_offset
    mov eax, r14d
    add eax, r15d
    ; SprawdŸ granice x
    cmp eax, 0
    jl skip_x_offset_plus_1
    cmp eax, r13d
    jge skip_x_offset_plus_1
    ; Oblicz indeks pikselu: (y_new * width + x_new) * 3
    mov edx, ecx              ; y_new = y+1
    imul edx, r13d            ; y_new * width
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    ; Ustaw rsi na indeks pikselu
    mov esi, edx
    ; Dodaj piksel do sumy
    call sum_pixels_row
skip_x_offset_plus_1:
    ; Inkrementuj x_offset
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets_plus_1

skip_row_plus_1:

    ; Rz¹d +2
    mov ecx, r12d
    add ecx, 2
    cmp ecx, r10d
    jge skip_row_plus_2
    mov esi, ecx
    imul esi, r13d
    add esi, r14d
    imul esi, 3
    ; Dodanie sumowania poziomych x_offsets (-2 do +2)
    mov r15d, -2              ; x_offset start
sum_x_offsets_plus_2:
    ; Oblicz x_new = x + x_offset
    mov eax, r14d
    add eax, r15d
    ; SprawdŸ granice x
    cmp eax, 0
    jl skip_x_offset_plus_2
    cmp eax, r13d
    jge skip_x_offset_plus_2
    ; Oblicz indeks pikselu: (y_new * width + x_new) * 3
    mov edx, ecx              ; y_new = y+2
    imul edx, r13d            ; y_new * width
    add edx, eax              ; + x_new
    imul edx, 3                ; *3
    ; Ustaw rsi na indeks pikselu
    mov esi, edx
    ; Dodaj piksel do sumy
    call sum_pixels_row
skip_x_offset_plus_2:
    ; Inkrementuj x_offset
    add r15d, 1
    cmp r15d, 2
    jle sum_x_offsets_plus_2

skip_row_plus_2:

    ; Podziel sumy przez 25
    movss xmm4, dword ptr [const_0_04]  ; Za³aduj 0.04 do xmm4
    mulss xmm0, xmm4
    mulss xmm1, xmm4
    mulss xmm2, xmm4

    ; Konwertuj z powrotem do liczb ca³kowitych i ogranicz do 0-255
    cvttss2si ecx, xmm0 ; Blue
    cvttss2si edx, xmm1 ; Green
    cvttss2si r11d, xmm2 ; Red

    ; Ogranicz wartoœci do 0-255
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

    ; Nastêpny x
    inc r14d
    jmp col_loop

next_row:
    ; Nastêpny y
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

; Funkcja pomocnicza do sumowania pikseli w wierszu
sum_pixels_row PROC
    ; Pobierz wartoœci pikseli i dodaj do sum
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