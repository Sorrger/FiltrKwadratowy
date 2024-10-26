;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE

Darken proc
; Ustal warto��, o kt�r� zwi�kszymy ka�dy kana� (np. 30)
    mov r8b, 30             ; Zwi�kszenie o 30 dla ka�dego komponentu B, G, R

    ; Przetwarzamy ka�dy bajt w tablicy
    xor rbx, rbx            ; Zerujemy rbx, b�dzie u�ywane jako licznik

process_pixel:
    ; Sprawdzamy, czy osi�gn�li�my koniec tablicy
    cmp rbx, rdx            ; Je�li licznik >= liczba element�w, zako�cz
    jge end_function

    ; �adujemy warto�� piksela
    mov al, byte ptr [rcx + rbx]   ; Pobierz warto�� piksela (kolor B, G lub R)

    ; Dodajemy warto�� podbicia, sprawdzaj�c maksymaln� warto�� 255
    sub al, r8b                    ; Dodajemy zwi�kszenie (r8b) do bie��cej warto�ci
    jns store_value                ; Je�li wynik nie jest ujemny, zapisz
    xor al, al

store_value:
    ; Zapisz z powrotem zmodyfikowan� warto��
    mov byte ptr [rcx + rbx], al

    ; Przejd� do nast�pnego elementu
    inc rbx                        ; Zwi�kszamy licznik bajt�w (nast�pny kana�)
    jmp process_pixel              ; Kontynuujemy dla kolejnego koloru

end_function:
    ret
Darken endp

END             ;no entry point
;-------------------------------------------------------------------------