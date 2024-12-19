section .data
    ; Mensagem de boas-vindas e entrada do usuário
    HEADER db 'WELCOME TO TOWER OF HANOI', 0xa, 0 
    len_header equ $ - HEADER  ; Tamanho da mensagem de boas-vindas

    msg_for_user db 'Pick a number between 1 and 99, please: ', 0
    len_msg_user equ $ - msg_for_user ; Tamanho da mensagem para entrada do usuário

    pula db '', 10
    len_p equ $ - pula

    ; Nomes das Torres
    Torre_inicial db 'A', 0, 10
    len_ti equ $ - Torre_inicial

    Torre_auxiliar db 'B', 0, 10
    len_ta equ $ - Torre_auxiliar

    Torre_final db 'C', 0, 10
    len_tf equ $ - Torre_final

    ; Mensagens sobre discos
    Iniciando db 'Starting Tower of Hanoi with '
    len_iniciando equ $ - Iniciando
    discos db ' disks:', 10, 0
    len_d equ $ - discos

    ; Mensagens de movimentação de discos
    movimento_1 db 'Moving the disk', 0 
    len_mov1 equ $ - movimento_1
    movimento_2 db ' from Tower '
    len_mov2 equ $ - movimento_2
    movimento_3 db ' to Tower', 0
    len_mov3 equ $ - movimento_3

    tam_num EQU 3  ; Espaço reservado para a entrada do usuário (até 3 caracteres)

section .bss
    data_input resb tam_num  ; Reserva espaço para a entrada do usuário
    number_disks resb 3     ; Armazena o número de discos
    buffer resb 16           ; Buffer para número convertido em string

section .text
    global _start  ; Ponto de entrada do programa

_start:
    ; Exibindo as mensagens iniciais
    call bv_input
    mov ecx, HEADER
    mov edx, len_header
    call bv_input

    mov ecx, pula
    mov edx, len_p
    call bv_input

    mov ecx, msg_for_user
    mov edx, len_msg_user
    call bv_input

    ; Lê a entrada do usuário e converte para inteiro
    call leitura_input
    call process_convert_str_int

    ; Exibe o número de discos
    mov ecx, pula
    mov edx, len_p
    call bv_input

    mov ecx, Iniciando
    mov edx, len_iniciando
    call bv_input

    call print_disk
    mov ecx, discos
    mov edx, len_d
    call bv_input

    ; Resolve o problema da Torre de Hanoi
    call algoritm_tower

    ; Finaliza o programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

bv_input:
    ; Exibe uma mensagem na saída padrão
    ; ECX: Endereço da mensagem
    ; EDX: Tamanho da mensagem
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

leitura_input:
    ; Lê a entrada do usuário
    mov eax, 3
    mov ebx, 0
    mov ecx, data_input
    mov edx, tam_num
    int 0x80
    ret

print_disk:
    ; Exibe o número de discos
    movzx eax, word [number_disks]
    lea edi, [buffer + 4]
    call loop_str_int

    mov eax, 4
    mov ebx, 1
    lea ecx, [edi]
    lea edx, [buffer + 4]
    sub edx, ecx
    int 0x80
    ret

process_convert_str_int:
    ; Converte a string de entrada para um número inteiro
    xor eax, eax
    xor ecx, ecx

convert_loop:
    movzx edx, byte [data_input + ecx]
    cmp edx, 0x0A
    je done_conversion
    sub edx, '0'
    imul eax, eax, 10
    add eax, edx
    inc ecx
    jmp convert_loop

done_conversion:
    mov [number_disks], eax
    ret

loop_str_int:
    ; Converte o número para string
    dec edi
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz loop_str_int
    ret

algoritm_tower:
    ; Algoritmo recursivo da Torre de Hanoi
    cmp word [number_disks], 1
    je caso_b
    jmp recursao

caso_b:
    ; Caso base (1 disco)
    mov ecx, movimento_1
    mov edx, len_mov1
    call bv_input

    call print_disk
    mov ecx, movimento_2
    mov edx, len_mov2
    call bv_input

    mov ecx, Torre_inicial
    mov edx, len_ti
    call bv_input

    mov ecx, movimento_3
    mov edx, len_mov3
    call bv_input

    mov ecx, Torre_final
    mov edx, len_tf
    call bv_input
    jmp done_tower

recursao:
    ; Passo recursivo para resolver o problema com mais de 1 disco
    dec byte [number_disks]          ; Decrementa o número de discos (prepara para a chamada recursiva)
    push word [number_disks]         ; Empilha o valor atual de [number_disks] para preservar o estado
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

    pop word [number_disks]          ; Restaura o valor original de [number_disks]

    ; Exibe a mensagem de movimentação do disco
    mov ecx, movimento_1              ; Carrega a mensagem "Movendo o disco" no registrador ECX
    mov edx, len_mov1                 ; Carrega o comprimento da mensagem
    call bv_input             ; Exibe a mensagem

    inc byte [number_disks]          ; Incrementa o número de discos para a visualização
    call print_disk                   ; Chama a função para exibir o disco movido
    dec byte [number_disks]          ; Decrementa novamente para manter a consistência

    ; Exibe a mensagem de origem e destino do disco
    mov ecx, movimento_2              ; Carrega a mensagem "da torre" no registrador ECX
    mov edx, len_mov2                 ; Carrega o comprimento da mensagem
    call bv_input             ; Exibe a mensagem

    mov ecx, Torre_inicial            ; Carrega a torre inicial no registrador ECX
    mov edx, len_ti                   ; Carrega o comprimento da mensagem
    call bv_input             ; Exibe a torre inicial

    mov ecx, movimento_3              ; Carrega a mensagem "para a torre" no registrador ECX
    mov edx, len_mov3                 ; Carrega o comprimento da mensagem
    call bv_input             ; Exibe a mensagem

    mov ecx, Torre_final              ; Carrega a torre final no registrador ECX
    mov edx, len_tf                   ; Carrega o comprimento da mensagem
    call bv_input             ; Exibe a torre final

    ; Troca novamente os valores das torres para continuar o processo recursivo
    mov dx, [Torre_auxiliar]          ; Carrega o valor de Torre_auxiliar em DX
    mov cx, [Torre_inicial]           ; Carrega o valor de Torre_inicial em CX
    mov [Torre_inicial], dx           ; Atualiza Torre_inicial com o valor de Torre_auxiliar
    mov [Torre_auxiliar], cx          ; Atualiza Torre_auxiliar com o valor de Torre_inicial

    call algoritm_tower               ; Chama recursivamente o algoritmo para resolver a sub-torre

done_tower:
    ret
    