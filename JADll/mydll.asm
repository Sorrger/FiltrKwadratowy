.DATA
white_value db 255, 255, 255   ; Kolor bia³y (RGB)

.CODE
Darken PROC
    push rsi
    push rdi
    push rbx

    ; Pobierz imageHeight, startY oraz segmentHeight
    mov r10, [rsp + 40]         ; r10 = imageHeight
    mov r11, r8                 ; r11 = startY (pocz¹tek wiersza)
    mov r12, r9                 ; r12 = segmentHeight (wysokoœæ segmentu)

    ; Dopasowanie wartoœci koñca segmentu, jeœli przekracza wymiary obrazu
    add r11, r12                ; r11 = startY + segmentHeight
    cmp r11, r10
    jle no_adjust_end
    mov r11, r10                ; Jeœli koniec segmentu przekracza obraz, ustaw go na imageHeight
no_adjust_end:

    ; Ustaw wskaŸnik na startY
    cmp r8, r10
    jge end_function            ; Jeœli startY >= imageHeight, zakoñcz

    ; Pêtla po wierszach (r8 = aktualny wiersz)
row_loop:
    cmp r8, r11
    jge end_function            ; Jeœli r8 >= endY, zakoñcz

    ; Pomiñ dwa górne wiersze w górnym segmencie obrazu   - dziala
    cmp r8, 2
    jl skip_top_rows            ; Jeœli wiersz < 2, pomin¹æ (przeskocz)
    
    ; imageHeight - 2
    sub r10, 2               ; Teraz r10 = imageHeight - 2

    ; Pomiñ dwa dolne wiersze w dolnym segmencie obrazu  - dziala
    cmp r8, r10              ; SprawdŸ, czy aktualny wiersz r8 >= (imageHeight - 2)
    jge end_function         ; Jeœli wiersz >= imageHeight - 2, zakoñcz funkcjê

    ; Przywróæ wartoœæ imageHeight do r10
    add r10, 2   

    mov rsi, 2                  ; Pocz¹tek kolumny (pomijamy 2 kolumny brzegowe)

    ; Pêtla po kolumnach w wierszu (rsi = aktualna kolumna)
pixel_loop:
    
    sub rdx, 2

    cmp rsi, rdx                ; Porównaj rsi (kolumna) z szerokoœci¹ obrazu (rdx)
    jge next_row                ; Jeœli rsi >= imageWidth - 2, przejdŸ do nastêpnego wiersza

    add rdx, 2

    ; Oblicz wskaŸnik do bie¿¹cego piksela
    mov rdi, r8                 ; rdi = aktualny wiersz
    imul rdi, rdx               ; rdi = rdi * imageWidth
    add rdi, rsi                ; rdi = rdi + column
    imul rdi, 3                 ; rdi = rdi * 3 (RGB)
    lea rbx, [rcx + rdi]        ; rbx = wskaŸnik do bie¿¹cego piksela

    ; Zmieñ wartoœæ piksela na bia³y (zapis RGB)
    mov byte ptr [rbx], 255     ; R
    mov byte ptr [rbx + 1], 255 ; G
    mov byte ptr [rbx + 2], 255 ; B

    add rsi, 1                  ; PrzejdŸ do nastêpnej kolumny
    jmp pixel_loop

next_row:
    inc r8
    add rdx, 2
    jmp row_loop

skip_top_rows:
    ; Pomiñ dwie pierwsze kolumny, ale wejdŸ do pêtli wierszy
    add r8, 2
    jmp row_loop

skip_bottom_rows:
    ; Pomiñ dwie ostatnie kolumny, ale wejdŸ do pêtli wierszy
    sub r8, 2
    jmp row_loop

end_function:
    pop rbx
    pop rdi
    pop rsi
    ret
Darken ENDP
END