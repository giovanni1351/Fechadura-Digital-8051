; --- Mapeamento de Hardware (8051) ---
    RS      equ     P1.3    ; Reg Select ligado em P1.3 - usado para selecionar o registro do LCD
    EN      equ     P1.2    ; Enable ligado em P1.2 - usado para habilitar o LCD

; Configuração inicial
org 0000h
LJMP START                ; Salto para a rotina de inicialização do sistema


; Definindo as mensagens de feedback para o display
Aberto:
DB "Aberto"               ; Mensagem exibida quando a senha está correta
DB 0                      ; Caracter nulo para indicar o fim da string

SenhaIncorreta:
DB "Senha Incorreta"      ; Mensagem exibida quando a senha está incorreta
DB 0

VoltandoAoEstadoNormal:
DB "         Tente novamente" ; Mensagem para nova tentativa após erro de senha
DB 0

; --- Função para escrever strings no LCD ---
escreveString:
    MOV R2, #0            ; Inicializa o índice R2 para percorrer a string
rot:
    MOV A, R2             ; Carrega o índice R2 no acumulador
    MOVC A, @A+DPTR       ; Lê a tabela de strings na memória de programa
    ACALL sendCharacter   ; Envia o caractere no acumulador ao LCD
    INC R2                ; Incrementa o índice
    JNZ rot               ; Se o valor é 0 (fim da string), sai do loop
    RET                   ; Retorna ao chamador

; --- Início da rotina principal ---
org 0100h
START:
    ACALL lcd_init        ; Inicializa o LCD
rotina:
    MOV 50h, #0           ; Zera registradores para armazenar senha digitada
    MOV 51h, #0
    MOV 52h, #0
    MOV 53h, #0

    ; Leitura da senha digitada pelo usuário
ler1:
    mov r2, #1
    acall ler             ; Lê o primeiro dígito da senha
    mov 50h, R0           ; Armazena o primeiro dígito
    CJNE r2, #0, ler1     ; Repete a leitura caso necessário
    acall delay

ler2:
    mov r2, #1
    acall ler             ; Lê o segundo dígito da senha
    mov 51h, R0           ; Armazena o segundo dígito
    CJNE r2, #0, ler2
    acall delay

ler3:
    mov r2, #1
    acall ler             ; Lê o terceiro dígito da senha
    mov 52h, R0           ; Armazena o terceiro dígito
    CJNE r2, #0, ler1
    acall delay

ler4:
    mov r2, #1
    acall ler             ; Lê o quarto dígito da senha
    mov 53h, R0           ; Armazena o quarto dígito
    CJNE r2, #0, ler1
    acall delay

    ; Verificação da senha digitada
    mov r1, 50h
    CJNE R1, #1h, SenhaErrada  ; Verifica se o primeiro dígito é 1
    mov r1, 51h
    CJNE R1, #2h, SenhaErrada  ; Verifica se o segundo dígito é 2
    mov r1, 52h
    CJNE R1, #3h, SenhaErrada  ; Verifica se o terceiro dígito é 3
    mov r1, 53h
    CJNE R1, #4h, SenhaErrada  ; Verifica se o quarto dígito é 4

    acall SenhaCorreta    ; Caso a senha esteja correta, chama a rotina para abrir a fechadura
    JMP $                 ; Aguarda uma nova tentativa

SenhaCorreta:
    ; Exibe a mensagem de sucesso e ativa o motor
    MOV A, #06h
    ACALL posicionaCursor
    MOV DPTR, #Aberto     ; Aponta para a string "Aberto"
    ACALL escreveString   ; Exibe a mensagem "Aberto"
    CLR P3.5              ; Desativa o motor
    acall delay
    acall clearDisplay    ; Limpa o display
    acall LIGARMOTOR      ; Liga o motor para abrir a fechadura
    jmp rotina            ; Retorna para a rotina principal

SenhaErrada:
    ; Exibe mensagens de erro e retorna para nova tentativa
    MOV A, #40h
    ACALL posicionaCursor
    MOV DPTR, #SenhaIncorreta
    ACALL escreveString
    acall delay
    acall clearDisplay
    acall retornaCursor

    MOV A, #40h
    ACALL posicionaCursor
    MOV DPTR, #VoltandoAoEstadoNormal
    ACALL escreveString
    acall delay
    acall clearDisplay
    jmp rotina            ; Volta à rotina para nova tentativa

; --- Rotina de controle do motor ---
LIGARMOTOR:
    CLR P3.1              ; Liga o motor para abrir a fechadura
    ACALL delayMotor      ; Temporizador para o motor
    SETB P3.1             ; Desliga o motor
    RET

delayMotor:
    MOV R0, #200          ; Loop para gerar um atraso no motor
    DJNZ R0, $
    RET

lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

    ; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
    ; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


    ; entry mode set
    ; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear


    ; display on/off control
    ; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endere�o da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	         ; clear RS - indicates that instruction is being sent to module
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	RET


;Retorna o cursor para primeira posi��o sem limpar o display
retornaCursor:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E
	;mov r7, #20
	;delayChamar:
    ;	CALL delay		
	;djnz r7, delay

	RET


delay:
	MOV R0, #50
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
