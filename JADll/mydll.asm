.DATA
white_value db 255, 255, 255   ; Kolor bia�y (RGB)

.CODE
Darken PROC
    push rsi
    push rdi
    push rbx

    ; Pobierz imageHeight, startY oraz segmentHeight
    mov r10, [rsp + 40]         ; r10 = imageHeight
    mov r11, r8                 ; r11 = startY (pocz�tek wiersza)
    mov r12, r9                 ; r12 = segmentHeight (wysoko�� segmentu)

    ; Dopasowanie warto�ci ko�ca segmentu, je�li przekracza wymiary obrazu
    add r11, r12                ; r11 = startY + segmentHeight
    cmp r11, r10
    jle no_adjust_end
    mov r11, r10                ; Je�li koniec segmentu przekracza obraz, ustaw go na imageHeight
no_adjust_end:

    ; Ustaw wska�nik na startY
    cmp r8, r10
    jge end_function            ; Je�li startY >= imageHeight, zako�cz

    ; P�tla po wierszach (r8 = aktualny wiersz)
row_loop:
    cmp r8, r11
    jge end_function            ; Je�li r8 >= endY, zako�cz

    ; Pomi� dwa g�rne wiersze w g�rnym segmencie obrazu   - dziala
    cmp r8, 2
    jl skip_top_rows            ; Je�li wiersz < 2, pomin�� (przeskocz)
    
    ; imageHeight - 2
    sub r10, 2               ; Teraz r10 = imageHeight - 2

    ; Pomi� dwa dolne wiersze w dolnym segmencie obrazu  - dziala
    cmp r8, r10              ; Sprawd�, czy aktualny wiersz r8 >= (imageHeight - 2)
    jge end_function         ; Je�li wiersz >= imageHeight - 2, zako�cz funkcj�

    ; Przywr�� warto�� imageHeight do r10
    add r10, 2   

    mov rsi, 2                  ; Pocz�tek kolumny (pomijamy 2 kolumny brzegowe)

    ; P�tla po kolumnach w wierszu (rsi = aktualna kolumna)
pixel_loop:
    
    sub rdx, 2

    cmp rsi, rdx                ; Por�wnaj rsi (kolumna) z szeroko�ci� obrazu (rdx)
    jge next_row                ; Je�li rsi >= imageWidth - 2, przejd� do nast�pnego wiersza

    add rdx, 2

    ; Oblicz wska�nik do bie��cego piksela
    mov rdi, r8                 ; rdi = aktualny wiersz
    imul rdi, rdx               ; rdi = rdi * imageWidth
    add rdi, rsi                ; rdi = rdi + column
    imul rdi, 3                 ; rdi = rdi * 3 (RGB)
    lea rbx, [rcx + rdi]        ; rbx = wska�nik do bie��cego piksela

    ; Zmie� warto�� piksela na bia�y (zapis RGB)
    mov byte ptr [rbx], 255     ; R
    mov byte ptr [rbx + 1], 255 ; G
    mov byte ptr [rbx + 2], 255 ; B

    add rsi, 1                  ; Przejd� do nast�pnej kolumny
    jmp pixel_loop

next_row:
    inc r8
    add rdx, 2
    jmp row_loop

skip_top_rows:
    ; Pomi� dwie pierwsze kolumny, ale wejd� do p�tli wierszy
    add r8, 2
    jmp row_loop

skip_bottom_rows:
    ; Pomi� dwie ostatnie kolumny, ale wejd� do p�tli wierszy
    sub r8, 2
    jmp row_loop

end_function:
    pop rbx
    pop rdi
    pop rsi
    ret
Darken ENDP
END