code_seg segment
        ASSUME  CS:CODE_SEG,DS:code_seg,ES:code_seg
	org 100h
;
start:

jmp BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;MACRO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CR		EQU		13
	LF		EQU		10
	Space	EQU		20h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_letter	macro	letter
	push	AX
	push	DX
	mov	DL, letter
	mov	AH,	02
	int	21h
	pop	DX
	pop	AX
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_mes	macro	message
	local	msg, nxt
	push	AX
	push	DX
	mov	DX, offset msg
	mov	AH,	09h
	int	21h
	pop	DX
	pop	AX
	jmp nxt
	msg	DB message,'$'
	nxt:
	endm
;=====================================================
open_file	macro	file_name
	local name,nxt
		push	AX
		push	DX
	mov	AX,	3D02h		; Open file for read/write
	mov	DX, offset name
		int	21h
	pop	DX
	pop	AX
jmp	nxt	
name	DB file_name,0
nxt:
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;BUBBLE SORT;;;;;;;;;;;;;



	BEGIN:						;THERE PROG STARTS
	
print_letter	CR
print_letter	LF
;------- check string of parameters -------------------------
	mov 	BL,		ES:[80h] 	; length parameters in psp
	cmp 	BL,		0			; is it 0 ?
	jne 	with_param    		; если не 0, то переходим к    		
;---------------------------------------------------------------
	print_mes 'not parameters'   	; иначе (0 параметров)
   jmp	vvod
;---------------------------------------------------------------
with_param:
	xor	BH,	BH
	mov	byte ptr [BX+81h],	0	; ASCIIZ
;---------------------------------------------------------------
    mov	CL,	BL
   xor 	CH,	CH      ; CX=CL= длина хвоста
   cld             	; DF=0 - флаг направления вперед
   mov 	DI, 81h     ; ES:DI-> начало хвоста в PSP
   mov 	AL,' '      ; Уберем пробелы из начала хвоста
repe    scasb   	; Сканируем хвост пока пробелы							; AL - (ES:DI) -> флаги процессора
					; повторять пока элементы равны
     dec DI        	; DI-> на первый символ после пробелов
;---------------------------------------------------------------
	mov	AX,	3D02h	; Open file for read/write
	mov	DX, DI
	int	21h
	jnc	openOK
print_letter	CR
print_letter	LF
print_mes	'openERR'
	int	20h
;=====================================================
openOK:
	mov	Handler,	AX
;
print_mes	'openOK'
print_letter	CR
print_letter	LF
print_letter	CR
print_letter	LF
;
;	mov		AX,	4C00h
;	int 	21h
	jmp		go_to_read
;
vvod:
print_letter	CR
print_letter	LF
print_mes	'Input File Name > '	
	mov		AH,	0Ah
	mov		DX,	offset	FileName
	int		21h
print_letter	CR
print_letter	LF
;===============================================================
	xor	BH,	BH
	mov	BL,  FileName[1]
	mov	FileName[BX+2],	0
;===============================================================
	mov	AX,	3D02h		; Open file for read/write
	mov	DX, offset FileName+2
	int	21h
	jc	err1
	mov	Handler,	AX
	jmp	openOK1
err1:
print_letter	CR
print_letter	LF
print_mes	'openERR'
	int	20h
;===============================================================
openOK1:
;
print_mes	'openOK1'
print_letter	CR
print_letter	LF
print_letter	CR
print_letter	LF
;
go_to_read:
;
;СНАЧАЛА СОЗДАДИМ ВЫХОДНОЙ ФАЙЛ
;
;-------------------------------------------------
MOV		AH, 3Ch			; Функция CREATE
MOV 	CX, 0			; Без атрибутов
MOV		DX, OFFSET FilenameOut	; Адрес имени Файла
INT 	21h			; Вызов DOS
Mov		HandlerOut, AX		; сохранить дескриптор
;------------------------------------------------------
cont:
	mov AH, 3Fh
	mov BX, Handler
	mov DX, offset ReadBuf
	mov CX, 1000
	int 21h
;
	mov		count,	AX
;	push	AX				; сколько реально прочитано
;
    cld                 	;Сброс флага df
    mov  cx,AX          	;Счетчик 
    lea  di,WriteBuf     	;Адрес области "куда«
	lea  si,ReadBuf     	;Адрес области "откуда"
   ;rep 	movsb			;Переслать данные  
   mov bx, offset Tbl
ckl:
   lodsb
;
	xlat
;	
   stosb  
   loop ckl
;
;-------------------------------------------

mov		DI,		offset WriteBuf ; Что сортировать
		mov		DL,		128
;--------------------------------------------

	call bubble_sort			; ЗАПУСК СОРТИРОВКИ

;-------------------------------------------
; write to output  file
;-------------------------------------------
MOV		AH, 40h					; Функция записи
MOV		BX, HandlerOut			; Дескриптор
MOV		CX, count				; Число записываемых байтов
MOV 	DX, OFFSET WriteBuf		; Адрес буфера
INT 	21h
;

cmp	count, 128
je cont
; Печатаем буффер
	print_mes 'INPUT:'
	print_letter	CR
	print_letter	LF
	mov AH, 09h
	mov DX, offset ReadBuf
	int 21h
	print_letter	CR
	print_letter	LF
	
	print_mes 'OUTPUT:'
	print_letter	CR
	print_letter	LF	
	mov AH, 09h
	mov DX, offset WriteBuf
	int 21h

;
	mov		AX,	4C00h
	int 	21h
	

int 20h
;----------------------------------------------
;
seed	dw 1
FileName	DB		14,0,14 dup (0)
Handler		DW	?
HandlerOut	DW	?
ReadBuf		DB	128 dup('$')
WriteBuf	DB	128 dup('$')
			DB '$'
FilenameOut	DB	'my_out.txt',0
count		DW	?
;=========================== таблица перекодировки ============================

Tbl DB 0
n=1
rept 127 
db	n
n=n+1
endm
;rept 32
;DB	177
;endm
;
;Big letters
DB	'A','B','V','G','D','E','G','Z','I','J','K','L','M','N','O','P'
DB  'R','S','T','U','F','H','C','C','S','S',039,'E',039,'E','U','Y'
;
;Small letters
DB	'a','b','v','g','d','e','g','z','i','j','k','l','m','n','o','p'
;АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ
;ABVGDEGZIJKLMNOPRSTUFHCHSS'E'EUY
l=176
rept  48
db	l
l=l+1
endm
DB  'r','s','t','u','f','h','c','c','s','s',039,'e',039,'e','u','y'
DB 'e','e','e','e'
;
m=242
rept  13
db	l
m=m+1
endm
;===============================================================
bubble_sort proc near

;pusha не работает, так как слишком старый процессор
	push DI
	push SI
	push BP
	push BX
	push DX
	push CX
	push AX
	
	cld
	cmp		dl,		1
	jbe		sort_exit		;	Выйти,если сортировать нечего
	dec		dl
sn_loop1:
	mov		cl,	dl				;	Установить длину цикла.
	xor		bx,	bx				;	ВХ будет флагом обмена.
	mov		si,	di				;	SI будет указателем на	текущий	элемент.

sn_loop2:
	lodsb						;	Прочитать следующее слово.
	cmp		byte ptr[si], al	; 	В порядке убывания a1 >= a2 >= an
	;(если поменять сортировка будет в порядке возрастания) a1 <= a2 <= an
	
	jbe		no_swap				;	Если элементы не в порядке,
	xchg	al, byte ptr[si]	;	поменять их местами
	mov		byte ptr [si-1], al
	inc		bx					;	и	установить флаг	в	1
no_swap: 
	loop	sn_loop2
	cmp		bx, 0				;	Если сортировка не закончилась,
	jne	sn_loop1				;	перейти к следующему элементу.
sort_exit:

;popa аналогично pusha сверху
	pop AX
	pop CX
	pop DX
	pop BX
	pop BP
	pop SI
	pop DI

ret
bubble_sort	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
code_seg ends
	 end start
	 