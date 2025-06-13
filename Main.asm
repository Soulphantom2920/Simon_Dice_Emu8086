INCLUDE 'emu8086.inc'

DATOS SEGMENT
    ; --- Variables de estado del juego ---
    player_count  db 0
    nickname1     db 11 dup('$')
    nickname2     db 11 dup('$')
    
    tipo_juego    db 0 ; 1=Colores, 2=Emojis, 3=Numeros
    dificultad    db 0 ; 1=Facil, 2=Intermedio, 3=Dificil
    modo_juego    db 0 ; 1=Tiempo
    
    ; --- Constantes y Datos Comunes ---
    SCREEN_WIDTH    EQU 80
    SCREEN_HEIGHT   EQU 25

    ; --- Constantes y Datos para Emojis ---
    NUM_EMOJIS      EQU 20
    SEQUENCE_LENGTH EQU 5
    emoji1  DB  ':(', 0
    emoji2  DB  ';)', 0
    emoji3  DB  '^_~', 0
    emoji4  DB  '^_^', 0
    emoji5  DB  '^0^', 0
    emoji6  DB  '>:(', 0
    emoji7  DB  ':[', 0
    emoji8  DB  'U_U', 0
    emoji9  DB  '>"<', 0
    emoji10 DB  ':-O', 0
    emoji11 DB  'UwU', 0
    emoji12 DB  ':-()', 0
    emoji13 DB  '~_~', 0
    emoji14 DB  '^3^', 0
    emoji15 DB  'T_T', 0
    emoji16 DB  'X_X', 0
    emoji17 DB  'O_O', 0
    emoji18 DB  '=)', 0
    emoji19 DB  '$_$', 0
    emoji20 DB  'Y.Y', 0
    emoji_pointers DW emoji1, emoji2, emoji3, emoji4, emoji5, emoji6, emoji7, emoji8, emoji9, emoji10
                   DW emoji11, emoji12, emoji13, emoji14, emoji15, emoji16, emoji17, emoji18, emoji19, emoji20
    sequence_buffer DB 50 DUP(0)

    ; --- Constantes y Datos para Números ---
    NUMBER_COUNT      EQU 10
    NUMBER_SEQ_LENGTH EQU 7 
    TOTAL_PRINT_LENGTH EQU (NUMBER_SEQ_LENGTH * 2) - 1
    _number_chars   DB '0123456789'
    _num_seq_buffer DB TOTAL_PRINT_LENGTH DUP ('$')

    ; --- [NUEVO-CLR] Constantes y Datos para Colores ---
    COLOR_PALETTE_SIZE  EQU 15
    COLOR_SEQ_LENGTH    EQU 5
    prng_seed   DW  ?
    color_palette   DB  1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 7, 1
      
        ; --- Constantes de Dificultad ---
    COLOR_SEQ_LENGTH_EASY   EQU 5
    COLOR_SEQ_LENGTH_MED    EQU 8
    COLOR_SEQ_LENGTH_HARD   EQU 12

    EMOJI_SEQ_LENGTH_EASY   EQU 5
    EMOJI_SEQ_LENGTH_MED    EQU 8
    EMOJI_SEQ_LENGTH_HARD   EQU 12

    NUMBER_SEQ_LENGTH_EASY  EQU 7
    NUMBER_SEQ_LENGTH_MED   EQU 10
    NUMBER_SEQ_LENGTH_HARD  EQU 14
    
    ; Tiempos de pausa en microsegundos para INT 15h, AH=86h
    ; Formato: CX (high word), DX (low word)
    time_delays_h   DW 13h,   0Bh,   03h
    time_delays_l   DW 12D0h, 71B0h, 0D480h 
    ; Fácil:    1.25 segundos
    ; Medio:    0.75 segundos
    ; Difícil:  0.25 segundos
    
DATOS ENDS

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

CODIGO SEGMENT
    ASSUME DS:DATOS, CS:CODIGO, SS:PILA

INICIO PROC FAR
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV AX, DATOS
    MOV DS, AX
    MOV ES, AX
    CALL Main_Game_Loop
    MOV AX, 4C00h
    INT 21h
INICIO ENDP

Main_Game_Loop PROC NEAR
    CALL Initial_Setup_Players
    CALL Configure_Game_Settings
    
    CMP tipo_juego, 1
    JE jugar_colores  

    CMP tipo_juego, 2
    JE jugar_emojis   

    CMP tipo_juego, 3
    JE jugar_numeros  

    JMP fin_del_juego

jugar_colores:
    CALL Jugar_Secuencia_Colores
    JMP fin_del_juego

jugar_emojis:
    CALL Jugar_Secuencia_Emojis
    JMP fin_del_juego

jugar_numeros:
    CALL MostrarSecuenciaNumeros
    JMP fin_del_juego
    
fin_del_juego:    
    RET
Main_Game_Loop ENDP

; =======================================================
; [NUEVO] LÓGICA DEL JUEGO DE COLORES
; =======================================================
Jugar_Secuencia_Colores PROC NEAR
    PUSHA

    ; Inicializar semilla y modo de video
    MOV AH, 2Ch
    INT 21h
    MOV [prng_seed], DX
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    ; --- [CORREGIDO] Seleccionar longitud de secuencia basado en dificultad ---
    MOV CH, 0 ; Limpiamos la parte alta de CX
    CMP dificultad, 1
    JE  easy_len_color
    CMP dificultad, 2
    JE  medium_len_color
    
hard_len_color:
    MOV CL, COLOR_SEQ_LENGTH_HARD
    JMP start_color_loop
medium_len_color:
    MOV CL, COLOR_SEQ_LENGTH_MED
    JMP start_color_loop
easy_len_color:
    MOV CL, COLOR_SEQ_LENGTH_EASY

start_color_loop:
    ; Bucle principal de la secuencia
color_sequence_loop:
    PUSH CX
    
    ; Obtener color aleatorio
    MOV AX, [prng_seed]
    MOV BX, 12345
    MUL BX
    ADD AX, 54321
    MOV [prng_seed], AX
    MOV DX, 0
    MOV BX, COLOR_PALETTE_SIZE
    DIV BX
    LEA SI, color_palette
    ADD SI, DX
    MOV BL, [SI]

    ; Mostrar flash de color
    MOV BH, BL
    SHL BH, 4
    MOV AH, 06h
    MOV AL, 0
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    INT 10h

    ; --- [CORREGIDO] Pausa para memorizar usando una tabla ---
    MOV AL, dificultad
    DEC AL          ; Convertir dificultad 1,2,3 a índice 0,1,2
    MOV AH, 0
    SHL AX, 1       ; Multiplicar por 2 (porque los valores son Words)
    MOV BX, AX      ; Usar BX como índice

    MOV CX, [time_delays_h + BX]  ; Cargar parte alta del tiempo
    MOV DX, [time_delays_l + BX]  ; Cargar parte baja del tiempo
    MOV AH, 86h
    INT 15h         ; Ejecutar la pausa
    
    ; Pantalla en negro entre colores
    MOV BH, 00h
    MOV AH, 06h
    MOV AL, 0
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    MOV CX, 03h      ; Pausa corta fija entre colores
    MOV DX, 0D480h
    MOV AH, 86h
    INT 15h

    POP CX
    LOOP color_sequence_loop

    ; Esperar tecla al final (temporal)
    MOV AH, 00h
    INT 16h
    
    POPA
    RET
Jugar_Secuencia_Colores ENDP

Jugar_Secuencia_Emojis PROC NEAR
    PUSHA

    ; Limpiar pantalla inicial
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h

    ; --- Seleccionar longitud de secuencia ---
    CMP dificultad, 1
    JE  easy_len_emoji
    CMP dificultad, 2
    JE  medium_len_emoji
hard_len_emoji:
    MOV CX, EMOJI_SEQ_LENGTH_HARD
    JMP start_emoji_loop
medium_len_emoji:
    MOV CX, EMOJI_SEQ_LENGTH_MED
    JMP start_emoji_loop
easy_len_emoji:
    MOV CX, EMOJI_SEQ_LENGTH_EASY
    
start_emoji_loop:
emoji_sequence_loop:
    PUSH CX

    ; --- Generar UN emoji aleatorio ---
    MOV AH, 2Ch
    INT 21h
    MOV AL, DL
    MOV AH, 0
    MOV BL, NUM_EMOJIS
    DIV BL
    MOV BL, AH
    MOV BH, 0
    SHL BX, 1
    LEA SI, emoji_pointers
    ADD SI, BX
    MOV SI, [SI]

    ; --- Mostrar ESE emoji en el centro ---
    ; Centrar cursor en la pantalla
    MOV DL, 38  ; Columna aproximada para centrar
    MOV DH, 12  ; Fila central
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    ; Imprimir el emoji
    CALL Print_Single_Emoji_From_SI

    ; --- Pausa para memorizar ---
    MOV AL, dificultad
    DEC AL          
    MOV AH, 0
    SHL AX, 1       
    MOV BX, AX      
    MOV CX, [time_delays_h + BX]
    MOV DX, [time_delays_l + BX]
    MOV AH, 86h
    INT 15h

    ; --- Limpiar la pantalla para el siguiente emoji ---
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    
    ; Pausa corta entre elementos
    MOV CX, 01h
    MOV DX, 86A0h ; 100,000 us (0.1s)
    MOV AH, 86h
    INT 15h

    POP CX
    LOOP emoji_sequence_loop

    ; Esperar tecla al final
    MOV AH, 0
    INT 16h
    POPA
    RET
Jugar_Secuencia_Emojis ENDP

Print_Single_Emoji_From_SI PROC NEAR
    ; Procedimiento auxiliar para imprimir un emoji (null-terminated)
    ; Recibe el puntero en SI
    PUSH AX
    PUSH SI
print_emoji_char:
    MOV AL, [SI]
    CMP AL, 0
    JE  end_print_emoji
    MOV AH, 0Eh
    INT 10h
    INC SI
    JMP print_emoji_char
end_print_emoji:
    POP SI
    POP AX
    RET
Print_Single_Emoji_From_SI ENDP

MostrarSecuenciaNumeros PROC
    PUSHA 
    
    ; Limpiar pantalla inicial
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h

    ; --- Seleccionar longitud de secuencia ---
    CMP dificultad, 1
    JE  easy_len_num
    CMP dificultad, 2
    JE  medium_len_num
hard_len_num:
    MOV CX, NUMBER_SEQ_LENGTH_HARD
    JMP start_num_loop
medium_len_num:
    MOV CX, NUMBER_SEQ_LENGTH_MED
    JMP start_num_loop
easy_len_num:
    MOV CX, NUMBER_SEQ_LENGTH_EASY
    
start_num_loop:
num_sequence_loop:
    PUSH CX

    ; --- Generar UN número aleatorio ---
    MOV AH, 2Ch
    INT 21h
    MOV AL, DL
    MOV AH, 0
    MOV BL, NUMBER_COUNT
    DIV BL
    MOV AL, AH      ; El número aleatorio (0-9) queda en AL
    ADD AL, '0'     ; Convertir a caracter ASCII

    ; --- Mostrar ESE número en el centro ---
    MOV DL, 39      ; Columna central
    MOV DH, 12      ; Fila central
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    ; Imprimir el número
    MOV AH, 0Eh
    MOV BL, 0Eh     ; Color amarillo
    INT 10h

    ; --- Pausa para memorizar ---
    MOV AL, dificultad
    DEC AL          
    MOV AH, 0
    SHL AX, 1       
    MOV BX, AX      
    MOV CX, [time_delays_h + BX]
    MOV DX, [time_delays_l + BX]
    MOV AH, 86h
    INT 15h

    ; --- Limpiar la pantalla para el siguiente número ---
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    
    ; Pausa corta entre elementos
    MOV CX, 01h
    MOV DX, 86A0h ; 100,000 us (0.1s)
    MOV AH, 86h
    INT 15h

    POP CX
    LOOP num_sequence_loop

    ; Esperar tecla al final
    MOV AH, 0
    INT 16h
    POPA
    RET
MostrarSecuenciaNumeros ENDP

Initial_Setup_Players PROC NEAR
    PRINTN "BIENVENIDO A SIMON DICE"
    PRINTN "=========================="
ask_players:
    PRINT "Cantidad de jugadores (1 o 2): "
    MOV AH, 01h
    INT 21h
    CMP AL, '1'
    JE one_player
    CMP AL, '2'
    JE two_players
    PRINTN ""
    PRINTN "Entrada no valida. Por favor, ingrese 1 o 2."
    JMP ask_players
one_player:
    MOV player_count, 1
    PRINTN ""
    PRINT "Jugador 1 - Nickname (3-10 caracteres): "
    LEA DI, nickname1
    CALL Read_Nickname
    JMP show_nicks
two_players:
    MOV player_count, 2
    PRINTN ""
    PRINT "Jugador 1 - Nickname (3-10 caracteres): "
    LEA DI, nickname1
    CALL Read_Nickname
    PRINTN ""
    PRINT "Jugador 2 - Nickname (3-10 caracteres): "
    LEA DI, nickname2
    CALL Read_Nickname
show_nicks:
    PRINTN ""
    PRINTN "--- Nicknames Registrados ---"
    PRINT "Jugador 1: "
    MOV DX, OFFSET nickname1
    CALL Print_Nickname
    CMP player_count, 2
    JNE setup_done
    PRINT "Jugador 2: "
    MOV DX, OFFSET nickname2
    CALL Print_Nickname
setup_done:
    PRINTN "=========================="
    PRINTN ""
    RET
Initial_Setup_Players ENDP

Read_Nickname PROC NEAR
    PUSH AX
    PUSH CX
    PUSH BX
    MOV CX, 10
    XOR BX, BX
read_loop:
    MOV AH, 00h
    INT 16h
    CMP AL, 0Dh
    JE check_length
    CMP AL, 08h
    JE backspace
    CMP BL, 10
    JAE read_loop
    MOV AH, 0Eh
    INT 10h
    MOV [DI + BX], AL
    INC BX
    JMP read_loop
backspace:
    CMP BX, 0
    JE read_loop
    DEC BX
    PUTC 08h
    PUTC ' '
    PUTC 08h
    JMP read_loop
check_length:
    CMP BX, 3
    JB too_short
    MOV BYTE PTR [DI + BX], '$'
    POP BX
    POP CX
    POP AX
    RET
too_short:
    PRINTN ""
    PRINT "El nickname debe tener entre 3 y 10 caracteres. Intente de nuevo: "
    MOV CX, BX
    clear_loop:
        PUTC 08h
        PUTC ' '
        PUTC 08h
    LOOP clear_loop
    XOR BX, BX
    JMP read_loop
Read_Nickname ENDP

Print_Nickname PROC NEAR
    PUSH AX
    MOV AH, 09h
    INT 21h
    PRINTN ""
    POP AX
    RET
Print_Nickname ENDP

Configure_Game_Settings PROC NEAR
ask_type:
    PRINT "Seleccione el tipo de secuencia (1=Colores, 2=Emojis, 3=Numeros): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL invalid_type
    CMP AL, 3
    JG invalid_type
    MOV tipo_juego, AL
    JMP ask_difficulty
invalid_type:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_type
ask_difficulty:
    PRINTN ""
    PRINT "Seleccione la dificultad (1=Facil, 2=Intermedio, 3=Dificil): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL invalid_difficulty
    CMP AL, 3
    JG invalid_difficulty
    MOV dificultad, AL
    JMP set_time_mode
invalid_difficulty:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_difficulty
set_time_mode:
    MOV modo_juego, 1
config_done:
    PRINTN ""
    PRINTN "--- Configuracion guardada. Preparando el juego... ---"
    RET
Configure_Game_Settings ENDP    

CODIGO ENDS
END INICIO