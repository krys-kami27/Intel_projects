;=====================================================================
; ECOAR - example Intel x86 assembly program
;
; Author:      Krystian Kamiński
; Date:        2020-12-17
; Description: Rozwiązanie zadania 7d
;
;=====================================================================

section .text
global  func

func:
; Główna funkcja,operując na stringu
; ustawiam znacznik początkowy i końcowy
	push ebp
	mov ebp, esp
	mov eax, DWORD [ebp+8]
	xor ecx, ecx
	xor ch, ch
	xor cl, cl
	mov bl, [eax]
	inc eax
	mov bh, [eax]
	add eax, 2
	jmp seek_flags
seek_flags:
; Sprawdzam warunek istnienia znacznika
; w celu ustalenia czy string ulegnie zmianie
	mov dl, [eax]
	inc eax
	cmp dl, bl
	je first_sign
	cmp dl, bh
	je second_sign
	test dl, dl
	jnz seek_flags
	test dl, dl
	jz is_signs
first_sign:
	add cl, 1
	jmp seek_flags
second_sign:
	add ch, 1
	jmp seek_flags
is_signs:
; Sprawdzam czy któryś ze znaków nie występuje
	cmp cl, 0
	je endf
	cmp ch, 0
	je endf
	sub eax,0
move_backward_to_second_sign:
; Do momentu wystąpienia drugiego znacznika
; zamieniamy wszystkie znaki na *
	sub eax, 1
	mov dl, [eax]
	cmp dl, ' '
	jl move_backward_to_second_sign
	cmp dl, bh
	je move_backward_to_first_sign
	mov BYTE[eax], '*'
	jmp move_backward_to_second_sign
	move_backward_to_first_sign:
; Do momentu wystąpienia pierwszego znacznika
; iterujemy, nie zmieniając stringa
	sub eax, 1
	mov dl,[eax]
	cmp dl, bl
	jne move_backward_to_first_sign
	jmp backward_to_begining
backward_to_begining:
; Do samego początku od tego momentu ustawiamy *
	sub eax, 1
	mov dl, [eax]
	cmp dl, ' '
	jl set_whitespace
	mov BYTE[eax], '*'
	jmp backward_to_begining
set_whitespace:
; trzy pierwsze znaki zamieniamy na spacje
	mov eax, DWORD [ebp+8]
	mov BYTE[eax], ' '
	add eax, 1
	mov BYTE[eax], ' '
	add eax, 1
	mov BYTE[eax], ' '
	add eax, 1
	jmp endf
endf:
; Zakończenie programu
	mov eax, ecx
	pop ebp
	ret
