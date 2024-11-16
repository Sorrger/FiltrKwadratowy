;.586
;INCLUDE C:\masm32\include\windows.inc

.DATA
mask_value dq 0.04166667, 0.04166667, 0.04166667, 0.04166667  ; Wartoœæ maski (1/24 dla normalizacji)
max_value  db 255, 255, 255, 255, 255, 255, 255, 255          ; Maksymalna wartoœæ dla kolorów (RGB 8-bit)
zero_value dq 0.0, 0.0, 0.0, 0.0                             ; Zero dla przycinania wyników

.CODE

Darken PROC
    ; Argumenty:
    ; rcx - wskaŸnik do danych pikseli
    ; rdx - szerokoœæ obrazu (w pikselach)
    ; r8  - startY (pocz¹tek segmentu)
    ; r9  - segmentHeight (wysokoœæ segmentu)

    push rsi                    ; Zapisz rejestry
    push rdi

    mov rbx, r8                 ; rbx = startY
    imul rbx, rdx               ; rbx = startY * szerokoœæ
    imul rbx, 3                 ; rbx = startY * szerokoœæ * 3 (format RGB)
    add rcx, rbx                ; Adjust rcx by the startY

    mov rsi, r9                 ; rsi = segmentHeight
    add rsi, r8                 ; rsi = endY (startY + segmentHeight)

apply_filter:
    mov rdi, 0                  ; rdi = poziomy offset w wierszu

row_loop:
    cmp r8, rsi                 ; Czy r8 (aktualny wiersz) przekroczy³ segmentHeight?
    jge end_function            ; Zakoñcz jeœli tak

    mov rdi, 0                  ; Resetuj poziomy indeks dla ka¿dego wiersza
pixel_loop:
    cmp rdi, rdx                ; Czy rdi (kolumna) przekroczy³a szerokoœæ obrazu?
    jge next_row

    ; Za³aduj aktualny piksel do xmm0
    mov rax, rcx
    add rax, rdi                ; Oblicz offset pikseli
    movdqu xmm0, xmmword ptr [rax]

    ; Zresetuj sumy dla maski
    pxor xmm1, xmm1

    ; Iteruj po s¹siednich pikselach w oknie 5x5
    mov rcx, -2                 ; rcx = pocz¹tek wierszy maski (-2)
mask_row:
    mov rbx, -2                 ; rbx = pocz¹tek kolumn maski (-2)
mask_col:
    ; Oblicz wspó³rzêdne s¹siednich pikseli
    mov rax, rcx
    imul rax, rdx               ; rax = rcx * szerokoœæ
    imul rax, 3                 ; rax = rcx * szerokoœæ * 3 (RGB)
    add rax, rbx                ; rax += rbx (offset kolumny)
    add rax, rdi                ; rax += poziomy offset

    ; SprawdŸ, czy s¹siad jest w obrêbie obrazu
    mov r10, rcx                ; SprawdŸ zakres wierszy
    add r10, r8                 ; r10 = aktualny wiersz (r8 + rcx)
    cmp r10, 0                  ; Upewnij siê, ¿e r10 >= 0
    jl skip_neighbor
    cmp r10, rsi                ; Upewnij siê, ¿e r10 < segmentHeight
    jge skip_neighbor

    mov r10, rbx                ; SprawdŸ zakres kolumn
    add r10, rdi                ; r10 = aktualna kolumna (rdi + rbx)
    cmp r10, 0                  ; Upewnij siê, ¿e r10 >= 0
    jl skip_neighbor
    cmp r10, rdx                ; Upewnij siê, ¿e r10 < szerokoœæ
    jge skip_neighbor

    ; Za³aduj s¹siedni piksel do xmm2
    add rax, rcx
    movdqu xmm2, xmmword ptr [rax]

    ; Pomnó¿ przez wartoœæ maski i dodaj do sumy
    mulps xmm2, xmmword ptr [mask_value]
    addps xmm1, xmm2

skip_neighbor:
    inc rbx                     ; PrzejdŸ do nastêpnej kolumny maski
    cmp rbx, 2
    jle mask_col

    inc rcx                     ; PrzejdŸ do nastêpnego wiersza maski
    cmp rcx, 2
    jle mask_row

    ; Przypisz now¹ wartoœæ do piksela (œrednia)
    movaps xmm2, xmm1
    maxps xmm2, xmmword ptr [zero_value]     ; Zapewnij, ¿e wynik nie jest mniejszy ni¿ 0
    minps xmm2, xmmword ptr [max_value]      ; Zapewnij, ¿e wynik nie przekroczy 255
    movdqu xmmword ptr [rax], xmm2

    ; PrzejdŸ do nastêpnego piksela
    add rdi, 3                  ; Przesuñ o 3 bajty (RGB)
    cmp rdi, rdx
    jl pixel_loop

next_row:
    inc r8                      ; PrzejdŸ do nastêpnego wiersza
    imul rax, rdx, 3            ; rax = offset wiersza (rdx * 3)
    add rcx, rax                ; Przesuñ wskaŸnik do nastêpnego wiersza w danych pikseli
    jmp row_loop

end_function:
    pop rsi
    pop rdi
    ret
Darken ENDP
END
