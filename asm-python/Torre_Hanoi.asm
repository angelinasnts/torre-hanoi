section .data
    ; Mensagens para exibição aos usuários
    HEADER db 'WELCOME TO TOWER OF HANOI', 0xa, 0    ; Mensagem de boas-vindas
    len_header equ $ - HEADER                        ; Tamanho da mensagem de boas-vindas

    msg_for_user db 'Pick a number between 1 and 99, please: ', 0
    len_msg_user equ $ - msg_for_user                ; Tamanho da mensagem de entrada do usuário

    pula db '', 10                                   ; Nova linha
    len_p equ $ - pula

    ; Identificadores das torres
    Torre_inicial db 'A', 0, 10                      ; Nome da torre inicial
    len_ti equ $ - Torre_inicial                     ; Tamanho da string da torre inicial

    Torre_auxiliar db 'B', 0, 10                     ; Nome da torre auxiliar
    len_ta equ $ - Torre_auxiliar                    ; Tamanho da string da torre auxiliar

    Torre_final db 'C', 0, 10                        ; Nome da torre final
    len_tf equ $ - Torre_final                       ; Tamanho da string da torre final

    ; Mensagens sobre o estado do jogo
    Iniciando db 'Starting Tower of Hanoi with '     ; Mensagem inicial
    len_iniciando equ $ - Iniciando                 ; Tamanho da mensagem inicial
    discos db ' disks:', 10, 0                      ; Complemento da mensagem inicial
    len_d equ $ - discos                            ; Tamanho do complemento

    ; Mensagens para movimentação de discos
    movimento_1 db 'Moving the disk', 0             ; Início da mensagem de movimentação
    len_mov1 equ $ - movimento_1                    ; Tamanho da mensagem de movimentação
    movimento_2 db ' from Tower '                   ; Mensagem intermediária
    len_mov2 equ $ - movimento_2                    ; Tamanho da mensagem intermediária
    movimento_3 db ' to Tower', 0                   ; Mensagem final
    len_mov3 equ $ - movimento_3                    ; Tamanho da mensagem final

    tam_num EQU 3  ; Espaço reservado para a entrada do usuário (até 3 caracteres)

section .bss
    ; Variáveis alocadas na memória não inicializada
    input_user resb tam_num        ; Armazena a entrada do usuário
    number_discos resb 3           ; Armazena o número de discos escolhido
    buffer resb 16                 ; Buffer para conversão de número para string

section .text
    global _start                  ; Ponto de entrada do programa

_start:
    ; Exibição das mensagens iniciais
    mov ecx, HEADER                ; Carrega a mensagem de boas-vindas
    mov edx, len_header            ; Carrega o comprimento da mensagem
    call mensage_bv_input          ; Exibe a mensagem de boas-vindas

    mov ecx, pula                  ; Adiciona uma nova linha
    mov edx, len_p
    call mensage_bv_input          ; Exibe a nova linha

    mov ecx, msg_for_user          ; Solicita a entrada do usuário
    mov edx, len_msg_user
    call mensage_bv_input          ; Exibe a solicitação

    ; Processa a entrada do usuário
    call leitura_input             ; Lê a entrada do usuário
    call process_convert_str_int   ; Converte a entrada para inteiro

    ; Exibe a configuração inicial do jogo
    mov ecx, pula                  ; Adiciona uma nova linha
    mov edx, len_p
    call mensage_bv_input          ; Exibe a nova linha

    mov ecx, Iniciando             ; Exibe a mensagem inicial
    mov edx, len_iniciando
    call mensage_bv_input          ; Exibe a mensagem inicial

    call print_disc                ; Exibe o número de discos selecionados
    mov ecx, discos                ; Exibe o complemento da mensagem
    mov edx, len_d
    call mensage_bv_input          ; Exibe a mensagem completa

    ; Resolve o problema das Torres de Hanoi
    call algoritm_tower

    ; Encerra o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Funções auxiliares
mensage_bv_input:
    ; Exibe uma mensagem na saída padrão
    ; ECX: Endereço da mensagem
    ; EDX: Comprimento da mensagem
    mov eax, 4                     ; Código do syscall para escrever
    mov ebx, 1                     ; File descriptor para saída padrão
    int 0x80                       ; Chamada ao kernel
    ret                            ; Retorna da função

leitura_input:
    ; Lê a entrada do usuário
    mov eax, 3                     ; Código do syscall para leitura
    mov ebx, 0                     ; File descriptor para entrada padrão
    mov ecx, input_user            ; Endereço do buffer de entrada
    mov edx, tam_num               ; Comprimento máximo da entrada
    int 0x80                       ; Chamada ao kernel
    ret                            ; Retorna da função

process_convert_str_int:
    ; Converte a string de entrada para um número inteiro
    xor eax, eax                   ; Zera o registrador acumulador
    xor ecx, ecx                   ; Zera o contador de caracteres

convert_loop:
    movzx edx, byte [input_user + ecx] ; Lê o próximo caractere
    cmp edx, 0x0A                      ; Verifica se é nova linha
    je done_conversion                 ; Se sim, termina a conversão
    sub edx, '0'                       ; Converte caractere para número
    imul eax, eax, 10                  ; Multiplica o acumulador por 10
    add eax, edx                       ; Adiciona o número ao acumulador
    inc ecx                            ; Incrementa o índice
    jmp convert_loop                   ; Continua o loop

done_conversion:
    mov [number_discos], eax           ; Armazena o número convertido
    ret                                ; Retorna da função

print_disc:
    ; Exibe o número de discos
    movzx eax, word [number_discos]    ; Carrega o número de discos
    lea edi, [buffer + 4]              ; Configura o buffer
    call loop_str_int                  ; Converte número para string

    mov eax, 4                         ; Syscall para exibir a string
    mov ebx, 1                         ; Saída padrão
    lea ecx, [edi]
    lea edx, [buffer + 4]
    sub edx, ecx                       ; Calcula o comprimento da string
    int 0x80                           ; Chamada ao kernel
    ret                                ; Retorna da função

loop_str_int:
    ; Converte um número inteiro para string
    dec edi                            ; Move o índice para trás
    xor edx, edx                       ; Zera o registrador EDX
    mov ecx, 10                        ; Divisor base 10
    div ecx                            ; Divide EAX por ECX
    add dl, '0'                        ; Converte o dígito para caractere
    mov [edi], dl                      ; Armazena o caractere no buffer
    test eax, eax                      ; Verifica se EAX é zero
    jnz loop_str_int                   ; Continua se não for zero
    ret                                ; Retorna da função

algoritm_tower:
    ; Implementa o algoritmo das Torres de Hanoi
    cmp word [number_discos], 1
    je caso_b                          ; Se 1 disco, caso base
    jmp recursao                       ; Caso contrário, recursão

caso_b:
    ; Caso base: movimenta 1 disco
    mov ecx, movimento_1
    mov edx, len_mov1
    call mensage_bv_input

    call print_disc
    mov ecx, movimento_2
    mov edx, len_mov2
    call mensage_bv_input

    mov ecx, Torre_inicial
    mov edx, len_ti
    call mensage_bv_input

    mov ecx, movimento_3
    mov edx, len_mov3
    call mensage_bv_input

    mov ecx, Torre_final
    mov edx, len_tf
    call mensage_bv_input
    ret                                ; Retorna ao terminar

recursao:
    ; Passo recursivo para resolver o problema com mais de 1 disco
    dec byte [number_discos]          ; Decrementa o número de discos (prepara para a chamada recursiva)
    push word [number_discos]         ; Empilha o valor atual de [number_discos] para preservar o estado
    push word [Torre_inicial]         ; Empilha o endereço da torre inicial
    push word [Torre_auxiliar]        ; Empilha o endereço da torre auxiliar
    push word [Torre_final]           ; Empilha o endereço da torre final

    ; Troca os valores das torres para a chamada recursiva
    mov dx, [Torre_auxiliar]          ; Carrega o valor de Torre_auxiliar em DX
    mov cx, [Torre_final]             ; Carrega o valor de Torre_final em CX
    mov [Torre_final], dx             ; Atualiza Torre_final com o valor de Torre_auxiliar
    mov [Torre_auxiliar], cx          ; Atualiza Torre_auxiliar com o valor de Torre_final

    call algoritm_tower               ; Chama recursivamente o algoritmo para resolver a sub-torre

    ; Após a recursão, restaura os valores das torres e discos
    pop word [Torre_final]            ; Restaura o valor de Torre_final
    pop word [Torre_auxiliar]         ; Restaura o valor de Torre_auxiliar
    pop word [Torre_inicial]          ; Restaura o valor de Torre_inicial

    pop word [number_discos]          ; Restaura o valor original de [number_discos]

    ; Exibe a mensagem de movimentação do disco
    mov ecx, movimento_1              ; Carrega a mensagem "Movendo o disco" no registrador ECX
    mov edx, len_mov1                 ; Carrega o comprimento da mensagem
    call mensage_bv_input             ; Exibe a mensagem

    inc byte [number_discos]          ; Incrementa o número de discos para a visualização
    call print_disc                   ; Chama a função para exibir o disco movido
    dec byte [number_discos]          ; Decrementa novamente para manter a consistência

    ; Exibe a mensagem de origem e destino do disco
    mov ecx, movimento_2              ; Carrega a mensagem "da torre" no registrador ECX
    mov edx, len_mov2                 ; Carrega o comprimento da mensagem
    call mensage_bv_input             ; Exibe a mensagem

    mov ecx, Torre_inicial            ; Carrega a torre inicial no registrador ECX
    mov edx, len_ti                   ; Carrega o comprimento da mensagem
    call mensage_bv_input             ; Exibe a torre inicial

    mov ecx, movimento_3              ; Carrega a mensagem "para a torre" no registrador ECX
    mov edx, len_mov3                 ; Carrega o comprimento da mensagem
    call mensage_bv_input             ; Exibe a mensagem

    mov ecx, Torre_final              ; Carrega a torre final no registrador ECX
    mov edx, len_tf                   ; Carrega o comprimento da mensagem
    call mensage_bv_input             ; Exibe a torre final

    ; Troca novamente os valores das torres para continuar o processo recursivo
    mov dx, [Torre_auxiliar]          ; Carrega o valor de Torre_auxiliar em DX
    mov cx, [Torre_inicial]           ; Carrega o valor de Torre_inicial em CX
    mov [Torre_inicial], dx           ; Atualiza Torre_inicial com o valor de Torre_auxiliar
    mov [Torre_auxiliar], cx          ; Atualiza Torre_auxiliar com o valor de Torre_inicial

    call algoritm_tower               ; Chama recursivamente o algoritmo para resolver a sub-torre

done_tower:
    ret
