INCLUDE 'emu8086.inc'

DATOS SEGMENT
    ; --- Variables de estado del juego ---
    player_count  db 0
    nickname1     db 11 dup('$')
    nickname2     db 11 dup('$')
    
    tipo_juego    db 0 ; 1=Colores, 2=Emojis, 3=Numeros
    dificultad    db 0 ; 1=Facil, 2=Intermedio, 3=Dificil
    modo_juego    db 0 ; 1=Tiempo
    
    ; --- Variables para el HUD ---
    puntaje1        dw 0
    tiempo_restante dw 0 ; Se inicializa en 0, se actualiza dinámicamente

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

    ; --- Constantes y Datos para Colores ---
    COLOR_PALETTE_SIZE  EQU 15
    prng_seed   DW  ?
    color_palette   DB  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    palette_chars   DB 'A', 'R', 'V', 'M', 'N', 'C', 'G', 'B', 'Z', 'F', 'Q', 'T', 'L', 'P', 'S'
      
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
    time_delays_h   DW 13h,   0Bh,   03h
    time_delays_l   DW 12D0h, 71B0h, 0D480h 

    ; Tiempos iniciales por dificultad (en segundos)
    tiempos_iniciales   dw 10, 8, 5
    
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
    
    CALL Dibujar_HUD
    CALL Mostrar_Contador
    
    CMP tipo_juego, 1
    JE jugar_colores_main
    CMP tipo_juego, 2
    JE jugar_emojis_main
    CMP tipo_juego, 3
    JE jugar_numeros_main
    JMP fin_del_juego

jugar_colores_main:
    CALL Jugar_Secuencia_Colores
    JMP post_secuencia

jugar_emojis_main:
    CALL Jugar_Secuencia_Emojis
    JMP post_secuencia

jugar_numeros_main:
    CALL MostrarSecuenciaNumeros

post_secuencia:
    CALL Dibujar_HUD
    
    CMP tipo_juego, 1
    JE  dibuja_paleta_colores
    CMP tipo_juego, 2
    JE  dibuja_paleta_emojis
    CMP tipo_juego, 3
    JE  dibuja_paleta_numeros
    JMP dibujar_botones

dibuja_paleta_colores:
    CALL Dibujar_Paleta_Colores
    JMP dibujar_botones

dibuja_paleta_emojis:
    CALL Dibujar_Paleta_Emojis
    JMP dibujar_botones

dibuja_paleta_numeros:
    CALL Dibujar_Paleta_Numeros

dibujar_botones:
    CALL Dibujar_Botones_Menu
    
    MOV AH, 00h
    INT 16h

fin_del_juego:    
    RET
Main_Game_Loop ENDP

Jugar_Secuencia_Colores PROC NEAR
    PUSHA
    MOV AH, 2Ch
    INT 21h
    MOV [prng_seed], DX
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV CH, 0
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
color_sequence_loop:
    PUSH CX
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
    MOV BH, BL
    SHL BH, 4
    MOV AH, 06h
    MOV AL, 0
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    INT 10h
    MOV AL, dificultad
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV CX, [time_delays_h + BX]
    MOV DX, [time_delays_l + BX]
    MOV AH, 86h
    INT 15h
    MOV BH, 00h
    MOV AH, 06h
    MOV AL, 0
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    MOV CX, 03h
    MOV DX, 0D480h
    MOV AH, 86h
    INT 15h
    POP CX
    LOOP color_sequence_loop
    POPA
    RET
Jugar_Secuencia_Colores ENDP

Jugar_Secuencia_Emojis PROC NEAR
    PUSHA
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
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
    MOV DL, 38
    MOV DH, 12
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    CALL Print_Single_Emoji_From_SI
    MOV AL, dificultad
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV CX, [time_delays_h + BX]
    MOV DX, [time_delays_l + BX]
    MOV AH, 86h
    INT 15h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    MOV CX, 01h
    MOV DX, 86A0h
    MOV AH, 86h
    INT 15h
    POP CX
    LOOP emoji_sequence_loop
    POPA
    RET
Jugar_Secuencia_Emojis ENDP

MostrarSecuenciaNumeros PROC
    PUSHA
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
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
    MOV AH, 2Ch
    INT 21h
    MOV AL, DL
    MOV AH, 0
    MOV BL, NUMBER_COUNT
    DIV BL
    MOV AL, AH
    ADD AL, '0'
    MOV DL, 39
    MOV DH, 12
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    MOV AH, 0Eh
    MOV BL, 0Eh
    INT 10h
    MOV AL, dificultad
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV CX, [time_delays_h + BX]
    MOV DX, [time_delays_l + BX]
    MOV AH, 86h
    INT 15h
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0
    MOV DX, 184Fh
    INT 10h
    MOV CX, 01h
    MOV DX, 86A0h
    MOV AH, 86h
    INT 15h
    POP CX
    LOOP num_sequence_loop
    POPA
    RET
MostrarSecuenciaNumeros ENDP

Print_Single_Emoji_From_SI PROC NEAR
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
    CALL Actualizar_Tiempo_Inicial
    PRINTN ""
    PRINTN "--- Configuracion guardada. Preparando el juego... ---"
    RET
Configure_Game_Settings ENDP    

Actualizar_Tiempo_Inicial PROC NEAR
    PUSHA
    MOV AL, [dificultad]
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV AX, [tiempos_iniciales + BX]
    MOV [tiempo_restante], AX
    POPA
    RET
Actualizar_Tiempo_Inicial ENDP

Dibujar_HUD PROC NEAR
    PUSHA
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 07h
    MOV CX, 0000
    MOV DX, 184Fh
    INT 10h
    GOTOXY 0, 0
    MOV CX, 26
    top_line_hud:
        PUTC '_'
    LOOP top_line_hud
    GOTOXY 0, 1
    PUTC '|'
    GOTOXY 25, 1
    PUTC '|'
    GOTOXY 0, 2
    PUTC '|'
    GOTOXY 25, 2
    PUTC '|'
    GOTOXY 0, 3
    PUTC '|'
    GOTOXY 25, 3
    PUTC '|'
    GOTOXY 0, 4
    MOV CX, 26
    bottom_line_hud:
        PUTC '_'
    LOOP bottom_line_hud
    GOTOXY 2, 1
    PRINT "Jugador 1: "
    GOTOXY 2, 2
    PRINT "Puntaje: "
    GOTOXY 2, 3
    PRINT "Tiempo: "
    GOTOXY 13, 1
    MOV DX, OFFSET nickname1
    MOV AH, 09h
    INT 21h
    GOTOXY 13, 2
    MOV AX, [puntaje1]
    CALL PRINT_NUM
    GOTOXY 13, 3
    MOV AX, [tiempo_restante]
    CALL PRINT_NUM
    POPA
    RET
Dibujar_HUD ENDP

Mostrar_Contador PROC NEAR
    PUSHA
    GOTOXY 33, 11
    PRINT "Secuencia en:"
    MOV CX, 0Fh
    MOV DX, 4240h
    GOTOXY 39, 12
    PUTC '3'
    MOV AH, 86h
    INT 15h
    GOTOXY 39, 12
    PUTC '2'
    MOV AH, 86h
    INT 15h
    GOTOXY 39, 12
    PUTC '1'
    MOV AH, 86h
    INT 15h
    POPA
    RET
Mostrar_Contador ENDP  

Dibujar_Paleta_Colores PROC NEAR
    PUSHA
    MOV SI, 0
    MOV DH, 8
draw_row:
    MOV DI, 0
    MOV DL, 20
draw_col:
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    CALL Dibujar_Recuadro_Color
    INC SI
    ADD DL, 5
    INC DI
    CMP DI, 5
    JNE draw_col
    ADD DH, 4
    CMP DH, 20
    JNE draw_row
    POPA
    RET
Dibujar_Paleta_Colores ENDP

Dibujar_Recuadro_Color PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, SI
    MOV AL, [palette_chars + BX]
    MOV BL, [color_palette + BX]
    PUSH DX
    INC DH
    ADD DL, 1
    MOV AH, 02h
    INT 10h
    MOV CX, 1
    MOV AH, 09h
    INT 10h
    POP DX
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Dibujar_Recuadro_Color ENDP

; =======================================================
;       PROCEDIMIENTO PARA DIBUJAR LA PALETA DE EMOJIS (Corregido)
; =======================================================
Dibujar_Paleta_Emojis PROC NEAR
    PUSHA

    MOV CX, NUM_EMOJIS ; <-- CORREGIDO: Usar la constante para 20 emojis
    MOV SI, 0          ; Índice para recorrer los punteros de emojis
    
emoji_grid_loop:
    PUSH CX

    ; --- Calcular Fila y Columna para la cuadrícula 4x5 ---
    MOV AX, SI      ; Usamos el índice actual (0-19)
    MOV BL, 5       ; 5 elementos por fila
    DIV BL          ; AX = Cociente (fila), AH = Residuo (columna)
    
    MOV CH, AL      ; Guardamos el número de fila (0, 1, 2, 3)
    MOV CL, AH      ; Guardamos el número de columna (0, 1, 2, 3, 4)

    ; Calcular Coordenada Y (Fila de la pantalla)
    MOV AL, 4       ; Cada fila de la paleta ocupa 4 filas de pantalla
    MUL CH          ; Fila_actual * 4
    ADD AL, 6       ; Fila inicial de la paleta
    MOV DH, AL      
    
    ; Calcular Coordenada X (Columna de la pantalla)
    MOV AL, 8       ; Cada columna de la paleta ocupa 8 de pantalla
    MUL CL          ; Columna_actual * 8
    ADD AL, 18      ; Columna inicial de la paleta
    MOV DL, AL      

    ; --- Posicionar e Imprimir ---
    MOV AH, 02h
    MOV BH, 0
    INT 10h

    PUSH SI         
    MOV BX, SI
    SHL BX, 1       
    MOV DI, [emoji_pointers + BX]
    PUSH DI
    POP SI          
    CALL Print_Single_Emoji_From_SI
    POP SI          

    INC SI
    POP CX
    LOOP emoji_grid_loop

    POPA
    RET
Dibujar_Paleta_Emojis ENDP


; =======================================================
;       PROCEDIMIENTO PARA DIBUJAR LA PALETA DE NÚMEROS (Corregido)
; =======================================================
Dibujar_Paleta_Numeros PROC NEAR
    PUSHA
    
    MOV CX, 10      ; Son 10 números (0-9)
    MOV SI, 0       ; Índice de 0 a 9
    
num_grid_loop:
    PUSH CX

    ; --- Calcular Fila y Columna para la cuadrícula 2x5 ---
    MOV AX, SI
    MOV BL, 5       ; 5 elementos por fila
    DIV BL
    
    MOV CH, AL      ; Guardamos el número de fila (0 o 1)
    MOV CL, AH      ; Guardamos el número de columna (0-4)
    
    ; Calcular Coordenada Y (Fila de la pantalla)
    MOV AL, 4
    MUL CH
    ADD AL, 10      ; Fila inicial
    MOV DH, AL
    
    ; Calcular Coordenada X (Columna de la pantalla)
    MOV AL, 8
    MUL CL
    ADD AL, 20      ; Columna inicial
    MOV DL, AL

    ; --- Posicionar e Imprimir ---
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    
    ; --- CORREGIDO: Usar la tabla _number_chars ---
    MOV BX, SI
    MOV AL, [_number_chars + BX]
    PUTC AL

    INC SI
    POP CX
    LOOP num_grid_loop
    
    POPA
    RET
Dibujar_Paleta_Numeros ENDP

Dibujar_Botones_Menu PROC NEAR
    PUSHA
    GOTOXY 15, 24
    PRINT "[ Rendirse ]"
    GOTOXY 35, 24
    PRINT "[ Reset ]"
    GOTOXY 55, 24
    PRINT "[ Quit ]"
    POPA
    RET
Dibujar_Botones_Menu ENDP

CODIGO ENDS

DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

END INICIO