;.586
;INCLUDE C:\masm32\include\windows.inc

.DATA
mask_value dq 0.04, 0.04, 0.04, 0.04        ; Zmieniona wartoœæ maski (1/25)
max_value db 255, 255, 255, 255, 255, 255, 255, 255 ; Maksymalna wartoœæ dla kolorów (RGB 8-bit)
zero_value dq 0.0, 0.0, 0.0, 0.0           ; Zero dla przycinania wyników

.CODE

Darken PROC
    ; Argumenty:
    ; rcx - wskaŸnik do danych pikseli
    ; rdx - szerokoœæ obrazu (w pikselach)
    ; r8  - startY (pocz¹tek segmentu)
    ; r9  - segmentHeight (wysokoœæ segmentu)

    push rsi                    ; Zapisz rejestry
    push rdi

    ; Oblicz przesuniêcie dla startY
    mov rbx, r8                 ; rbx = startY
    imul rbx, rdx               ; rbx = startY * szerokoœæ
    imul rbx, 3                 ; rbx = startY * szerokoœæ * 3 (format RGB)
    add rcx, rbx                ; rcx = wskaŸnik pocz¹tkowy segmentu

    ; Oblicz koniec segmentu
    mov rsi, r9                 ; rsi = segmentHeight
    add rsi, r8                 ; rsi = endY (startY + segmentHeight)

apply_filter:
    ; Ustawienie pocz¹tkowych indeksów
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
    pxor xmm1, xmm1             ; Zerowanie xmm1 (sumowanie)

    ; Iteracja po s¹siednich pikselach w oknie 5x5
    mov r10, -2                 ; r10 = wiersz maski (-2)
mask_row:
    mov r11, -2                 ; r11 = kolumna maski (-2)
mask_col:
    ; Oblicz wspó³rzêdne s¹siedniego piksela
    mov rax, r10
    imul rax, rdx               ; rax = r10 * szerokoœæ
    imul rax, 3                 ; rax = r10 * szerokoœæ * 3 (RGB)
    add rax, r11                ; rax += r11 (offset kolumny)
    add rax, rdi                ; rax += poziomy offset

    ; SprawdŸ, czy s¹siad jest w obrêbie segmentu
    mov rbx, r10                ; SprawdŸ wiersze
    add rbx, r8
    cmp rbx, 0
    jl skip_neighbor
    cmp rbx, rsi
    jge skip_neighbor

    mov rbx, r11                ; SprawdŸ kolumny
    add rbx, rdi
    cmp rbx, 0
    jl skip_neighbor
    cmp rbx, rdx
    jge skip_neighbor

    ; Za³aduj s¹siedni piksel do xmm2
    add rax, rcx
    movdqu xmm2, xmmword ptr [rax]

    ; Pomnó¿ przez wartoœæ maski i dodaj do sumy
    mulps xmm2, xmmword ptr [mask_value]
    addps xmm1, xmm2

skip_neighbor:
    inc r11                     ; Nastêpna kolumna w masce
    cmp r11, 2
    jle mask_col

    inc r10                     ; Nastêpny wiersz w masce
    cmp r10, 2
    jle mask_row

    ; Przypisz now¹ wartoœæ do piksela (œrednia)
    movaps xmm2, xmm1
    maxps xmm2, xmmword ptr [zero_value]     ; Upewnij siê, ¿e wynik >= 0
    minps xmm2, xmmword ptr [max_value]      ; Upewnij siê, ¿e wynik <= 255
    movdqu xmmword ptr [rax], xmm2

    ; PrzejdŸ do nastêpnego piksela
    add rdi, 3                  ; Przesuñ o 3 bajty (RGB)
    cmp rdi, rdx
    jl pixel_loop

next_row:
    inc r8                      ; PrzejdŸ do nastêpnego wiersza
    add rcx, rdx                ; Przesuñ wskaŸnik do nastêpnego wiersza
    jmp row_loop

end_function:
    pop rsi
    pop rdi
    ret
Darken ENDP
END
