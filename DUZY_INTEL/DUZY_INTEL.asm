section	.text
global  find_markers
global	get_pixel

find_markers:
	push	ebp
	mov		ebp,esp
	
	mov 	ebx, DWORD[ebp+8]	;wskaznik na bmp
								; zmienne
	mov		eax, [ebx+10]		; offset [ebp-4]
	push    eax
	mov		eax, [ebx+18]		; width  [ebp-8]
	push    eax
	mov		eax, [ebx+22]		; height [ebp-12]
	push    eax
	mov		eax, 0
	push	eax					;x iterator [ebp-16]
	push	eax					;y iterator [ebp-20]
	push    eax					;poziomy licznik czarnych pixeli [ebp-24]
	push	eax					;pionowy licznik czarnych pixeli [ebp-28]
	push	eax					;licznik znalezionych znaczników [ebp-32]

	push	eax					;kolor[ebp-36]
	push	eax					;y_2 [ebp-40]
					
set_y:	
	mov		ecx, DWORD[ebp-12]		
	add		ecx, -1
	add     [ebp-20],ecx			;y = wysokość - 1
	
									;petla iterujaca po pixelach pliku bmp od lewego-górnego rogu do prawego dolnego
while1:	
	cmp		DWORD[ebp-20], -1		;while(y>=0 && znaczniki<50)
	je		exit1
	cmp		DWORD[ebp-32],50
	je		exit1
while2:
	mov		ecx, DWORD[ebp-8]		;while(x<=szerokosc && znaczniki<50)
	cmp		DWORD[ebp-16], ecx
	jge		exit2
	cmp		DWORD[ebp-32],50
	je		exit2
	
	jmp		kolor
continue:
	mov		DWORD[ebp-36], eax		;kolor w x,y

	cmp		DWORD[ebp-36], 0		;kolor w x,y == czarny
	je		increment_black_h
	
	cmp		DWORD[ebp-24], 0		;licznik czarnych poziomych pixeli > 0
	jg		not_black_pixel


continue2:	
	add		DWORD[ebp-16],1			;x++
	jmp		while2
exit2:
	mov		DWORD[ebp-16],0			;x=0
	sub		DWORD[ebp-20],1			;y--
	jmp		while1
exit1:
	jmp exit

;--------------------------------------------------------------------------------------------
kolor:
	mov		eax, DWORD[ebp-20]		; push y
	push	eax 
	mov		eax, DWORD[ebp-16]		;push x
	push	eax
	mov		eax,DWORD[ebp+8]		;push wskaznik na bmp
	push	eax
	call	get_pixel
	pop		ecx
	pop 	ecx
	pop		ecx
	jmp		continue

x_is_width:
	add		DWORD[ebp-16], 1		;korekacja wspolrzednej x
	cmp		DWORD[ebp-24], 0		; if czarne poziome piksele > 0
	jg		check
	jmp		black_h_zero			;wyzeruj licznik czarnych poziomych pixeli
	
increment_black_h:
	add		DWORD[ebp-24],1			;poziomy licznik czarnych pixeli++
	
	mov		ecx, DWORD[ebp-8]
	sub		ecx, 1
	cmp		DWORD[ebp-16],ecx		; x==szerokosc
	je		x_is_width
	
	jmp		continue2				;powrót do pętli iterującej po po pliku bmp
	
not_black_pixel:
	jmp		check
;------------------------------------------------------------------------------------
check:
	mov		ecx, DWORD[ebp-12]
	sub		ecx,1
	cmp		DWORD[ebp-20], ecx		;if y<wysokosc-1 sprawdz w pixel ponad ostatnim czarnym else sprawdz pixele w dol
	jl		check_above				
	jmp		check_down
check_continue:	
	jmp		black_h_zero

check_above:
	mov		eax, DWORD[ebp-20]		; push y
	add		eax, 1
	push	eax 
	mov		eax, DWORD[ebp-16]		;push x
	sub		eax, 1
	push	eax
	mov		eax,DWORD[ebp+8]		;push wskaznik na bmp
	push	eax
	call	get_pixel
	pop		ecx
	pop 	ecx
	pop		ecx
	
	cmp		eax, 0					; jesli pixel ponad ostatnim czarnym pixelem w ciagu jest czarny to wroc do petli iteracyjnej
	je		check_continue
	
	jmp		check_down				

check_down:
	mov		ebx, DWORD[ebp-20]
	mov		DWORD[ebp-40], ebx		;y_2 = y
	mov		DWORD[ebp-28],0			; licznik czarnych pionwych pixeli = 0
while3:
	cmp		DWORD[ebp-40], -1		;y_2>=0
	je		exit3
	
	mov		eax, DWORD[ebp-40]		; push y_2 
	push	eax 
	mov		eax, DWORD[ebp-16]		;push x
	sub		eax, 1
	push	eax
	mov		eax,DWORD[ebp+8]		;push wskaznik na bmp
	push	eax
	call	get_pixel
	pop		ecx
	pop 	ecx
	pop		ecx
	
	cmp		eax, 0					;piksel w x,y_2 nie jest czarny -> exit3
	jne		exit3
	
	sub		DWORD[ebp-40], 1		; y_2--
	add		DWORD[ebp-28], 1		; licznik czarnych pionwych pixeli = 0
	jmp		while3
exit3:
	mov		ebx, DWORD[ebp-24]
	cmp		DWORD[ebp-28],ebx		;pinowe pixele = poziome pixele
	je		tag_add
	jmp		black_h_zero
;-----------------------------------------------------------------------------------------
tag_add:
	cmp		DWORD[ebp-28],1			;gdy wykryty znacznik to jeden pixel to wroc do petli iteracyjnej
	je		black_h_zero
	jmp		add_to_array			; dodaj wspolrzedne znacznika do tablicy
tag_add_c:	
	add		DWORD[ebp-32],1			
	jmp		black_h_zero
	
black_h_zero:
	mov		DWORD[ebp-24], 0		;poziomy licznik czarnych pixeli = 0
	jmp		continue2
	
add_to_array:
	mov		eax, DWORD[ebp-32]
	imul	eax,4					;offset
	mov		ebx, DWORD[ebp+12]		;tablica x
	mov		ecx, DWORD[ebp-16]		;X
	sub		ecx, 1					
	mov		DWORD[ebx+eax], ecx		;tablica[offset] = x
	
	mov		ebx, DWORD[ebp+16]		; tablica y
	mov		edx, DWORD[ebp-12]		; wysokosc
	sub		edx, 1					; wysokosc-1
	mov		ecx, DWORD[ebp-20]		; y
	sub		edx, ecx				; wysokosc-y
	mov		DWORD[ebx+eax], edx		;tablica[offset] = wysokosc -y
	
	jmp		tag_add_c
	
	
exit:
	mov		eax, DWORD[ebp-32]
	pop		ecx						; pop ze stosu utworzonych zmiennych
	pop		ecx
	pop		ecx
	pop		ecx
	pop		ecx
	pop		ecx
	pop		ecx
	pop		ecx	
	pop		ecx
	pop		ecx
	
	pop 	ebp
	ret
	
get_pixel:
	push	ebp
	mov		ebp,esp
	
	mov		eax, DWORD[ebp+8]		;adres początku zdjęcia
	mov 	ebx, [eax+18]			;szerokość zdjecia x
	mov	 	ecx, [ebp+16]			;wspolrzedna y
	
	imul	ebx,3					; x * 3 (obliczanie wierszy)
	add 	ebx,3					; x + 3
	and		ebx, 0xFFFFFFFC			; and z not 3
	imul 	ebx, ecx				; szerokość w bajtach z wyrównaniem do 4 bajtów * wspołrzedna y pixela
	
	mov 	edx,[ebp+12]			;wspolrzedna x_pixela(obliczanie kolumny)
	imul 	edx,3					;x_pixela *3 
	add 	ebx,edx					; +kolumna
	add 	ebx,eax					; +addres zdjecia
	add 	ebx,54					; +offset
	
	mov 	eax,[ebx]
	and 	eax, 0x00FFFFFF
	
	pop 	ebp
	ret