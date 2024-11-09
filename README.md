# Fechadura Digital com Intel 8051

Este projeto implementa uma fechadura digital em um microcontrolador Intel 8051, que permite ao usuário inserir uma senha de 4 dígitos. Se a senha estiver correta, um motor é ativado para abrir a porta. Caso contrário, o sistema exibe uma mensagem de erro e solicita uma nova tentativa.
-------
## Voce pode encontrar o código aqui: [Code](./code.asm)
# Diagrama de Funcionamento
```mermaid
graph TD
  A[Início] --> B[Inicializa LCD]
  B --> C[Ler senha digitada]
  C --> D{Senha correta?}
  D --|Sim|--> E[Exibe Aberto no display]
  E --> F[Ativa motor para abrir a fechadura]
  F --> G[Espera novo input de senha]
  D --|Não|--> H[Exibe Senha Incorreta]
  H --> I[Exibe Tente novamente]
  I --> C

  ```
# Caso senha incorreta 
- Avisando que a senha foi digitada incorretamente
![image](https://github.com/user-attachments/assets/10c737b8-28a8-4eac-9ed7-475fcb75a49f)
- Aviso que pode digitar novamente a senha
![image](https://github.com/user-attachments/assets/42d32868-e003-4802-9fa7-9290a890d3ea)

# Caso senha correta
- É digitado que a porta foi aberta e o motor entra em funcionamento
![image](https://github.com/user-attachments/assets/820c655e-de67-49fe-bc71-e481eaa93da7)



# Estrutura do Código

## Mapeamento de Hardware

### O código define os pinos de controle para o display LCD:

- RS (P1.3): Define se o dado enviado é um comando ou um caractere.
- EN (P1.2): Habilita a comunicação com o LCD.
----------
# Organização da Memória

## Mensagens:
- "Aberto": Exibido ao desbloquear a fechadura.
- "Senha Incorreta": Exibido para senhas erradas.
- "Tente novamente": Solicita nova tentativa.
## Funcionamento
Inicialização do LCD: A rotina lcd_init configura o display LCD para comunicação em modo 4 bits.
## Leitura de Senha:
Usa uma rotina ler para escanear o teclado.
A senha digitada é comparada com a senha correta (1234).
## Verificação da Senha:
+ Se correta: Exibe "Aberto", aciona o motor para abrir a fechadura, e volta ao modo de espera.
+ Se incorreta: Exibe "Senha Incorreta" seguido de "Tente novamente" e solicita nova entrada.
## Sub-rotinas
- Escrita no Display
- escreveString: Exibe uma string na tela até encontrar o caractere nulo.
- posicionaCursor: Posiciona o cursor no endereço desejado.
### Controle do Motor
- LIGARMOTOR: Ativa o motor para abrir a fechadura.
- delayMotor: Define o tempo de ativação do motor.
### Delay e Limpeza de Display
- delay: Pausa a execução por um intervalo fixo.
- clearDisplay: Limpa o conteúdo do display.

Participantes:
Giovanni Chahin Morassi  RA: 22123025-3
Laura de Souza Parente   RA: 22123033-7

