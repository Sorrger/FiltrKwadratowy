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
    mov r12d, r8d            ; r12d = y (aktualny wiersz)
    mov r13d, edx            ; r13d = width (szerokoœæ obrazu)
    mov rbp, rcx             ; rbp = pixelData (wskaŸnik do danych pikseli)

    ; Pêtla po wierszach
row_loop:
    cmp r12d, r9d
    jge end_function         ; Jeœli y >= endY, zakoñcz

    ; Pêtla po kolumnach
    xor r14d, r14d           ; r14d = x (kolumna)
col_loop:
    cmp r14d, r13d
    jge next_row             ; Jeœli x >= width, przejdŸ do nastêpnego wiersza

    ; SprawdŸ, czy piksel znajduje siê w granicach obrazu dla maski 5x5
    cmp r14d, 2
    jl skip_pixel            ; Jeœli x < 2, pomiñ piksel
    cmp r12d, 2
    jl skip_pixel            ; Jeœli y < 2, pomiñ piksel

    mov eax, r13d
    sub eax, 3
    cmp r14d, eax
    jge skip_pixel           ; Jeœli x >= width - 3, pomiñ piksel

    cmp r9d, r10d
    jne continue_processing  ; Jeœli endY != imageHeight, kontynuuj przetwarzanie

    ; SprawdŸ granicê dla ostatniego segmentu
    mov eax, r12d
    add eax, 3
    cmp eax, r10d
    jge skip_pixel           ; Jeœli y + 3 >= imageHeight, pomiñ piksel

continue_processing:
    ; Inicjalizacja sum
    pxor xmm0, xmm0            ; sumBlue
    pxor xmm1, xmm1            ; sumGreen
    pxor xmm2, xmm2            ; sumRed

    ; Pêtla po dy (-2 do 2)
    mov r15d, -2
dy_loop:
    mov esi, r12d
    add esi, r15d              ; ny = y + dy

    ; Pêtla po dx (-2 do 2)
    mov edi, -2
dx_loop:
    mov ebx, r14d
    add ebx, edi               ; nx = x + dx

    ; Oblicz indeks piksela
    mov eax, esi
    imul eax, r13d             ; eax = ny * width
    add eax, ebx               ; eax = ny * width + nx
    imul eax, 3                ; eax *= 3 (RGB)

    ; Pobierz wartoœci kolorów i dodaj do sum
    movzx eax, byte ptr [rbp + rax]     ; Blue
    cvtsi2ss xmm4, eax
    addss xmm0, xmm4                    ; sumBlue

    movzx eax, byte ptr [rbp + rax + 1] ; Green
    cvtsi2ss xmm4, eax
    addss xmm1, xmm4                    ; sumGreen

    movzx eax, byte ptr [rbp + rax + 2] ; Red
    cvtsi2ss xmm4, eax
    addss xmm2, xmm4                    ; sumRed

    ; Nastêpny dx
    inc edi
    cmp edi, 3
    jle dx_loop

    ; Nastêpny dy
    inc r15d
    cmp r15d, 3
    jle dy_loop

    ; Podziel sumy przez 25
    movss xmm4, dword ptr [const_0_04]  ; Za³aduj 0.04 do xmm4

    mulss xmm0, xmm4    ; sumBlue *= 0.04
    mulss xmm1, xmm4    ; sumGreen *= 0.04
    mulss xmm2, xmm4    ; sumRed *= 0.04

    ; Konwertuj z powrotem do ca³kowitych i ogranicz do 0-255
    cvttss2si ecx, xmm0 ; Blue
    cvttss2si edx, xmm1 ; Green
    cvttss2si r11d, xmm2 ; Red

    ; Ogranicz wartoœci do 0-255
    ; Blue
    cmp ecx, 0
    jl set_blue_zero
    cmp ecx, 255
    jg set_blue_255
    jmp blue_clamped
set_blue_zero:
    mov ecx, 0
    jmp blue_clamped
set_blue_255:
    mov ecx, 255
blue_clamped:

    ; Green
    cmp edx, 0
    jl set_green_zero
    cmp edx, 255
    jg set_green_255
    jmp green_clamped
set_green_zero:
    mov edx, 0
    jmp green_clamped
set_green_255:
    mov edx, 255
green_clamped:

    ; Red
    cmp r11d, 0
    jl set_red_zero
    cmp r11d, 255
    jg set_red_255
    jmp red_clamped
set_red_zero:
    mov r11d, 0
    jmp red_clamped
set_red_255:
    mov r11d, 255
red_clamped:

    ; Zapisz nowe wartoœci piksela
    mov eax, r12d
    imul eax, r13d              ; eax = y * width
    add eax, r14d               ; eax = y * width + x
    imul eax, 3                 ; eax *= 3

    mov byte ptr [rbp + rax], cl     ; Blue
    mov byte ptr [rbp + rax + 1], dl ; Green
    mov byte ptr [rbp + rax + 2], r11b ; Red

skip_pixel:
    ; Inkrementuj x
    inc r14d
    jmp col_loop

next_row:
    ; Inkrementuj y
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
Darken ENDP
END