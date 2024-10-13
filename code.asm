org 0000h
LJMP MAIN

org 0080h
MAIN:   
    
	MOV 50h,#0
	MOV 51h,#0
	MOV 52h,#0
	MOV 53h,#0
;	ACALL SENHA_CORRETA
;	JMP $  

	ler1:
	mov r2, #1
	acall ler
	mov 50h, R0 
	CJNE r2,#0, ler1

	ler2:
	mov r2, #1
	acall ler
	mov 51h, R0 
	CJNE r2,#0, ler2

	ler3:
	mov r2, #1
	acall ler	
	mov 52h, R0 
	CJNE r2,#0, ler1

	ler4:
	mov r2, #1
	acall ler
	mov 53h, R0 
	CJNE r2,#0, ler1

	mov r1 , 50h
	CJNE R1, #1h, SENHA_INCORRETA
	mov r1 , 51h
	CJNE R1, #1h, SENHA_INCORRETA
	mov r1 , 52h
	CJNE R1, #1h, SENHA_INCORRETA
	mov r1 , 53h
	CJNE R1, #1h, SENHA_INCORRETA
	

	


	jmp $
;	acall ler
	;CJNE R0, #1h, MAIN  
 	;NOP
	;NOP 
	;NOP 
	;NOP 
	;acall ler
	;CJNE R0, #2h, MAIN
	;acall ler
	;CJNE R0, #3h, MAIN
	;jmp $
	

	
;1ABCDEFG
;00000000B
;11111110B - O
;11100111B - P
;11001111B - E
;10010111B - N

SENHA_CORRETA:
	SETB P3.3 ; |
	SETB P3.4 ; | enable display 3
	MOV P1, #10000001B ; put pattern for 1 on display
;	CALL delay
	CLR P3.3 ; enable display 2
	MOV P1, #11100111B ; put pattern for 2 on display
	;CALL delay
	CLR P3.4 ; |
	SETB P3.3 ; | enable display 1
	MOV P1, #11001111B ; put pattern for 3 on display
	;CALL delay
	CLR P3.3 ; enable display 0
	MOV P1, #10010111B ; put pattern for 4 on display
	;CALL delay
	RET

SENHA_INCORRETA:
	SETB P3.3 ; |
	SETB P3.4 ; | enable display 3
	MOV P1, #10000001B ; put pattern for 1 on display
	CALL delay
	CLR P3.3 ; enable display 2
	MOV P1, #11100111B ; put pattern for 2 on display
	CALL delay
	CLR P3.4 ; |
	SETB P3.3 ; | enable display 1
	MOV P1, #11001111B ; put pattern for 3 on display
	CALL delay
	CLR P3.3 ; enable display 0
	MOV P1, #10010111B ; put pattern for 4 on display
	CALL delay
	JMP MAIN


delay:
	MOV R0, #200
	DJNZ R0, $	
	RET


ler:
MOV R0, #0 ; limpa R0 - a primeira tecla é key0
; scan row0
SETB P0.3 ; setar row3
CLR P0.0 ; limpar row0
CALL colScan ; chamar a rotina de scanear 
JB F0, finish ; | se F0 é 1, pula pra o fim do programaend of progra
; | (por que a tecla precionada foi achada e o numero é no R0
; scan row1
SETB P0.0 ; set row0
CLR P0.1 ; clear row1
CALL colScan ; call column-scan subroutine
JB F0, finish ; | if F0 is set, jump to end of program
; | (because the pressed key was found and its number is in R0)
; scan row2
SETB P0.1 ; set row1
CLR P0.2 ; clear row2
CALL colScan ; call column-scan subroutine
JB F0, finish ; | if F0 is set, jump to end of program
; | (because the pressed key was found and its number is in R0)
; scan row3
SETB P0.2 ; set row2
CLR P0.3 ; clear row3
CALL colScan ; call column-scan subroutine
JB F0, finish ; | if F0 is set, jump to end of program
; | (because the pressed key was found and its number is in R0)
JMP ler ; | go back to scan row 0
; | (this is why row3 is set at the start of the program
; | - when the program jumps back to start, row3 has just been scanned)
finish:
CLR F0 
MOV P0 ,#11111111B
MOV r2, #00h
ret ; program execution arrives here when key is found - do nothing
; column-scan subroutine
colScan:
JNB P0.4, gotKey ; if col0 is cleared - key found
INC R0 ; otherwise move to next key
JNB P0.5, gotKey ; if col1 is cleared - key found
INC R0 ; otherwise move to next key
JNB P0.6, gotKey ; if col2 is cleared - key found
INC R0 ; otherwise move to next key
RET ; return from subroutine - key not found
gotKey:
SETB F0 ; key found - set F0
RET ; and return from subroutine
