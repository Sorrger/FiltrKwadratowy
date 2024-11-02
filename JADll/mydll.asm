;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE

Darken proc
    ; Ustal wartoœæ czynnika przyciemnienia (50%)
    mov r8, 128               ; Mno¿nik (128) - 50% w skali 0-255
    mov r9, 255               ; Dzielnik (255) - dla obliczeñ

    ; Przetwarzamy ka¿dy bajt w tablicy
    xor rbx, rbx              ; Zerujemy rbx, bêdzie u¿ywane jako licznik

process_pixel:
    ; Sprawdzamy, czy osi¹gnêliœmy koniec tablicy
    cmp rbx, rdx              ; Jeœli licznik >= liczba elementów, zakoñcz
    jge end_function

    ; £adujemy wartoœæ piksela
    mov al, byte ptr [rcx + rbx]   ; Pobierz wartoœæ piksela (kolor B, G lub R)

    ; Mno¿enie przez 0.5 (w skali 0-255)
    imul rax, r8               ; Mno¿enie przez 128
    xor rdx, rdx               ; Zeruj rdx przed dzieleniem
    div r9                      ; Dziel przez 255, wynik w al

    ; Zapisz z powrotem zmodyfikowan¹ wartoœæ
    mov byte ptr [rcx + rbx], al

    ; PrzejdŸ do nastêpnego elementu
    inc rbx                    ; Zwiêkszamy licznik bajtów (nastêpny kana³)
    jmp process_pixel          ; Kontynuujemy dla kolejnego koloru

end_function:
    ret
Darken endp

END             ; no entry point
;-------------------------------------------------------------------------
