;.586
;INCLUDE C:\masm32\include\windows.inc

.DATA
mask_value dq 0.04, 0.04, 0.04, 0.04        ; Zmieniona warto�� maski (1/25)
max_value db 255, 255, 255, 255, 255, 255, 255, 255 ; Maksymalna warto�� dla kolor�w (RGB 8-bit)
zero_value dq 0.0, 0.0, 0.0, 0.0           ; Zero dla przycinania wynik�w

.CODE

Darken PROC
    ; Argumenty:
    ; rcx - wska�nik do danych pikseli
    ; rdx - szeroko�� obrazu (w pikselach)
    ; r8  - startY (pocz�tek segmentu)
    ; r9  - segmentHeight (wysoko�� segmentu)

    push rsi                    ; Zapisz rejestry
    push rdi

    ; Oblicz przesuni�cie dla startY
    mov rbx, r8                 ; rbx = startY
    imul rbx, rdx               ; rbx = startY * szeroko��
    imul rbx, 3                 ; rbx = startY * szeroko�� * 3 (format RGB)
    add rcx, rbx                ; rcx = wska�nik pocz�tkowy segmentu

    ; Oblicz koniec segmentu
    mov rsi, r9                 ; rsi = segmentHeight
    add rsi, r8                 ; rsi = endY (startY + segmentHeight)

apply_filter:
    ; Ustawienie pocz�tkowych indeks�w
    mov rdi, 0                  ; rdi = poziomy offset w wierszu
row_loop:
    cmp r8, rsi                 ; Czy r8 (aktualny wiersz) przekroczy� segmentHeight?
    jge end_function            ; Zako�cz je�li tak

    mov rdi, 0                  ; Resetuj poziomy indeks dla ka�dego wiersza
pixel_loop:
    cmp rdi, rdx                ; Czy rdi (kolumna) przekroczy�a szeroko�� obrazu?
    jge next_row

    ; Za�aduj aktualny piksel do xmm0
    mov rax, rcx
    add rax, rdi                ; Oblicz offset pikseli
    movdqu xmm0, xmmword ptr [rax]

    ; Zresetuj sumy dla maski
    pxor xmm1, xmm1             ; Zerowanie xmm1 (sumowanie)

    ; Iteracja po s�siednich pikselach w oknie 5x5
    mov r10, -2                 ; r10 = wiersz maski (-2)
mask_row:
    mov r11, -2                 ; r11 = kolumna maski (-2)
mask_col:
    ; Oblicz wsp�rz�dne s�siedniego piksela
    mov rax, r10
    imul rax, rdx               ; rax = r10 * szeroko��
    imul rax, 3                 ; rax = r10 * szeroko�� * 3 (RGB)
    add rax, r11                ; rax += r11 (offset kolumny)
    add rax, rdi                ; rax += poziomy offset

    ; Sprawd�, czy s�siad jest w obr�bie segmentu
    mov rbx, r10                ; Sprawd� wiersze
    add rbx, r8
    cmp rbx, 0
    jl skip_neighbor
    cmp rbx, rsi
    jge skip_neighbor

    mov rbx, r11                ; Sprawd� kolumny
    add rbx, rdi
    cmp rbx, 0
    jl skip_neighbor
    cmp rbx, rdx
    jge skip_neighbor

    ; Za�aduj s�siedni piksel do xmm2
    add rax, rcx
    movdqu xmm2, xmmword ptr [rax]

    ; Pomn� przez warto�� maski i dodaj do sumy
    mulps xmm2, xmmword ptr [mask_value]
    addps xmm1, xmm2

skip_neighbor:
    inc r11                     ; Nast�pna kolumna w masce
    cmp r11, 2
    jle mask_col

    inc r10                     ; Nast�pny wiersz w masce
    cmp r10, 2
    jle mask_row

    ; Przypisz now� warto�� do piksela (�rednia)
    movaps xmm2, xmm1
    maxps xmm2, xmmword ptr [zero_value]     ; Upewnij si�, �e wynik >= 0
    minps xmm2, xmmword ptr [max_value]      ; Upewnij si�, �e wynik <= 255
    movdqu xmmword ptr [rax], xmm2

    ; Przejd� do nast�pnego piksela
    add rdi, 3                  ; Przesu� o 3 bajty (RGB)
    cmp rdi, rdx
    jl pixel_loop

next_row:
    inc r8                      ; Przejd� do nast�pnego wiersza
    add rcx, rdx                ; Przesu� wska�nik do nast�pnego wiersza
    jmp row_loop

end_function:
    pop rsi
    pop rdi
    ret
Darken ENDP
END
