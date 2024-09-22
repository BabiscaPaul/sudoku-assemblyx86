.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

button_x EQU 0
button_y EQU 0
button_size_x EQU 360
button_size_y EQU 360  

sudokuMatrix dd '5', '0', '0', '4', '6', '7' ,'3', '0', '9'
			 dd '9', '0', '3', '8', '1', '0', '4', '2', '7'
			 dd '1', '7', '4', '2', '0', '3', '0', '0', '0'
			 dd '2', '3', '1', '9', '7', '6', '8', '5', '4'
			 dd '8', '5', '7', '1', '2', '4', '0', '9', '0'
			 dd '4', '9', '6', '3', '0', '8', '1', '7', '2'
			 dd '0', '0', '0', '0', '8', '9', '2', '6', '0'
			 dd '7', '8', '2', '6', '4', '1', '0', '0', '5'
			 dd '0', '1', '0', '0', '0', '0', '7', '0', '8'
			 
sudokuMatrixProcessed dd '5', '0', '0', '4', '6', '7' ,'3', '0', '9'
					  dd '9', '0', '3', '8', '1', '0', '4', '2', '7'
					  dd '1', '7', '4', '2', '0', '3', '0', '0', '0'
					  dd '2', '3', '1', '9', '7', '6', '8', '5', '4'
					  dd '8', '5', '7', '1', '2', '4', '0', '9', '0'
					  dd '4', '9', '6', '3', '0', '8', '1', '7', '2'
					  dd '0', '0', '0', '0', '8', '9', '2', '6', '0'
					  dd '7', '8', '2', '6', '4', '1', '0', '0', '5'
					  dd '0', '1', '0', '0', '0', '0', '7', '0', '8'
			 
i dd '0'
j dd '0' 
tempI dd 4
tempJ dd 36
valuePressed dd '0'

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_white proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] 		; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 				; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] 		; pointer la matricea de pixeli
	mov eax, [ebp+arg4] 		; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] 		; pointer la coord x
	shl eax, 2 					; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	
	ret
make_text_white endp



make_text_green proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 229954h
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text_green endp



; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text_macro_white_space macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text_white
	add esp, 16
endm

make_text_macro_green macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text_green
	add esp, 16
endm

get_coords_from_pos macro x, y
    mov ecx, 40
    mov eax, x
    xor edx, edx ; Clear edx
    idiv ecx
    mov i, eax
	; add i, '0'
    
    mov eax, y
    xor edx, edx ; Clear edx
    idiv ecx
    mov j, eax
	; add j, '0'
endm

line_horizontal macro x, y, len, color 
local bucla_linie
	mov eax, y
	mov ebx, area_width
	mul ebx 
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len 
bucla_linie:
	mov dword ptr[eax], color 
	add eax, 4
	loop bucla_linie
endm

line_vertical macro x, y, len, color
local bucla_linie 
	mov eax, y
	mov ebx, area_width
	mul ebx 
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len 
bucla_linie:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop bucla_linie
endm

; value_already_in_row macro value, row_index
    ; mov ecx, 9
    
    ; mov eax, row_index
    ; mul 4
    ; mov ebx, eax
    
    ; mov eax, 0
    ; column:
        ; cmp sudokuMatrixProcessed[ebx][eax], value
        ; jz found_same_value
        
        ; add eax, 36
        
        ; loop column
    
    ; jmp afisare_litere
    
    ; found_same_value:
    ; mov sudokuMatrixProcessed[ebx][eax], 'X'
; endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer
	cmp eax, 3
	jz evt_key
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere

evt_key: 
	mov ecx, [ebp+arg2]

	mov eax, i
	mul tempI
	mov ebx, eax

	mov eax, j
	mul tempJ
	
	cmp sudokuMatrix[ebx][eax], '0'
	jg dont_modify_value
	cmp sudokuMatrix[ebx][eax], 10
	je dont_modify_value

	mov sudokuMatrixProcessed[ebx][eax], ecx 
	mov sudokuMatrix[ebx][eax], 10
	
	dont_modify_value:
	jmp afisare_litere

	
evt_click:
	mov eax, [ebp+arg2]
	cmp eax, 360
	jg afisare_litere

	mov eax, [ebp+arg3]
	cmp eax, 360
	jg afisare_litere

	
	;s-a dat click inauntrul matricei 
	get_coords_from_pos [ebp+arg2], [ebp+arg3]
	
	; make_text_macro i, area, 490, 110
	; make_text_macro j, area, 485, 180
	

	
	
	
evt_timer:
	inc counter
	
afisare_litere:

	make_text_macro sudokuMatrixProcessed[5 * 4][4 * 36], area, 480, 480

	;desen 9x9 grid 
	
	line_horizontal button_x, button_y, button_size_x, 0
	line_horizontal button_x, button_y + button_size_y, button_size_x, 0
	line_vertical button_x, button_y, button_size_y, 0
	line_vertical button_x + button_size_x, button_y, button_size_y, 0
	line_vertical button_x + 120, button_y, button_size_y, 0
	line_vertical button_x + 120 * 2, button_y, button_size_y, 0
	line_horizontal button_x, button_y + 120, button_size_x, 0
	line_horizontal button_x, button_y + 120 * 2, button_size_x, 0
	line_horizontal button_x, button_y + 40, button_size_x, 85929Eh
	line_horizontal button_x, button_y + 40 * 2, button_size_x, 85929Eh
	line_horizontal button_x, button_y + 40 * 4, button_size_x, 85929Eh
	line_horizontal button_x, button_y + 40 * 5, button_size_x, 85929Eh
	line_horizontal button_x, button_y + 40 * 7, button_size_x, 85929Eh
	line_horizontal button_x, button_y + 40 * 8, button_size_x, 85929Eh
	line_vertical button_x + 40, button_y, button_size_y, 85929Eh
	line_vertical button_x + 40 * 2, button_y, button_size_y, 85929Eh
	line_vertical button_x + 40 * 4, button_y, button_size_y, 85929Eh
	line_vertical button_x + 40 * 5, button_y, button_size_y, 85929Eh
	line_vertical button_x + 40 * 7, button_y, button_size_y, 85929Eh
	line_vertical button_x + 40 * 8, button_y, button_size_y, 85929Eh
	
	mov esi, sudokuMatrix
	mov eax, 0	;i
	mov ebx, 0	;j
				
	mov ecx, 20	;coord x
	mov edx, 20	;coord y
	
	mov edi, -1
	
	row_loop:
		column_loop:
		
			cmp sudokuMatrix[eax][ebx], '0'
			je print_it_green
		
			make_text_macro sudokuMatrixProcessed[eax][ebx], area, ecx, edx
			jmp skip_printing_symbol_green
			
			print_it_green:
			make_text_macro_green sudokuMatrixProcessed[eax][ebx], area, ecx, edx
			
			skip_printing_symbol_green:
			
			add ecx, 40
			
			add ebx, 4 			;inc col counter and move to the next element 
			
			inc edi 
			
			cmp edi, 8			; check to see if I am at the end of the row 
			jz end_column_loop
			
			jmp column_loop		; if not, continue looping over the cols 
				
		end_column_loop: 
			mov ecx, 20 		; set the coord for pixels to draw them 
			add edx, 40
			
			mov edi, -1

			sub ebx, 4	
			add eax, 4
			
			cmp eax, 36			;check if end of array
			jz end_row_loop
			
			jmp row_loop		;if not continue looping 
			
		end_row_loop:

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
