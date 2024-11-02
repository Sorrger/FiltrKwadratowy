;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE

Darken proc
    ; Ustal warto�� czynnika przyciemnienia (50%)
    mov r8, 128               ; Mno�nik (128) - 50% w skali 0-255
    mov r9, 255               ; Dzielnik (255) - dla oblicze�

    ; Przetwarzamy ka�dy bajt w tablicy
    xor rbx, rbx              ; Zerujemy rbx, b�dzie u�ywane jako licznik

process_pixel:
    ; Sprawdzamy, czy osi�gn�li�my koniec tablicy
    cmp rbx, rdx              ; Je�li licznik >= liczba element�w, zako�cz
    jge end_function

    ; �adujemy warto�� piksela
    mov al, byte ptr [rcx + rbx]   ; Pobierz warto�� piksela (kolor B, G lub R)

    ; Mno�enie przez 0.5 (w skali 0-255)
    imul rax, r8               ; Mno�enie przez 128
    xor rdx, rdx               ; Zeruj rdx przed dzieleniem
    div r9                      ; Dziel przez 255, wynik w al

    ; Zapisz z powrotem zmodyfikowan� warto��
    mov byte ptr [rcx + rbx], al

    ; Przejd� do nast�pnego elementu
    inc rbx                    ; Zwi�kszamy licznik bajt�w (nast�pny kana�)
    jmp process_pixel          ; Kontynuujemy dla kolejnego koloru

end_function:
    ret
Darken endp

END             ; no entry point
;-------------------------------------------------------------------------
