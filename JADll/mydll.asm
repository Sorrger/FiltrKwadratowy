;-------------------------------------------------------------------------
;.586
;INCLUDE C:\masm32\include\windows.inc 

.CODE

Darken proc
; Ustal wartoœæ, o któr¹ zwiêkszymy ka¿dy kana³ (np. 30)
    mov r8b, 30             ; Zwiêkszenie o 30 dla ka¿dego komponentu B, G, R

    ; Przetwarzamy ka¿dy bajt w tablicy
    xor rbx, rbx            ; Zerujemy rbx, bêdzie u¿ywane jako licznik

process_pixel:
    ; Sprawdzamy, czy osi¹gnêliœmy koniec tablicy
    cmp rbx, rdx            ; Jeœli licznik >= liczba elementów, zakoñcz
    jge end_function

    ; £adujemy wartoœæ piksela
    mov al, byte ptr [rcx + rbx]   ; Pobierz wartoœæ piksela (kolor B, G lub R)

    ; Dodajemy wartoœæ podbicia, sprawdzaj¹c maksymaln¹ wartoœæ 255
    add al, r8b                    ; Dodajemy zwiêkszenie (r8b) do bie¿¹cej wartoœci
    jc set_max_255                 ; Jeœli wynik przekracza 255, ustaw na 255
    jmp store_value

set_max_255:
    mov al, 255                    ; Ustaw maksymaln¹ wartoœæ, gdyby by³o przepe³nienie

store_value:
    ; Zapisz z powrotem zmodyfikowan¹ wartoœæ
    mov byte ptr [rcx + rbx], al

    ; PrzejdŸ do nastêpnego elementu
    inc rbx                        ; Zwiêkszamy licznik bajtów (nastêpny kana³)
    jmp process_pixel              ; Kontynuujemy dla kolejnego koloru

end_function:
    ret
Darken endp

END             ;no entry point
;-------------------------------------------------------------------------