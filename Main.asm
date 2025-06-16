INCLUDE 'emu8086.inc'

DATOS SEGMENT
    msg_acierto   DB '¡Correcto! Siguiente ronda...', '$'
    msg_fallo     DB '¡Fallaste!', '$'
    msg_rendirse  DB 'Te has rendido. Fin del juego.', '$'
    msg_feedback  DB 'Entrada Jugador:      ', '$'
    
    msg_j1_gana     DB 'Resultado: GANA JUGADOR 1 !!!', '$'
    msg_j2_gana     DB 'Resultado: GANA JUGADOR 2 !!!', '$'
    msg_empate      DB 'Resultado: ES UN EMPATE.', '$'
    msg_j1_gana_rendicion DB 'J2 se rinde. GANA JUGADOR 1!', '$'
    msg_j2_gana_rendicion DB 'J1 se rinde. GANA JUGADOR 2!', '$'

    player_count    db 0
    nickname1       db 11 dup('$')
    nickname2       db 11 dup('$')
    
    tipo_juego      db 0 
    dificultad      db 0 
    modo_juego      db 0 
    
    puntaje1        dw 0
    puntaje2        dw 0         
    jugador_actual  db 1         
    estado_j1       db 1
    estado_j2       db 1
    
    tiempo_restante  dw 0 
    oportunidades_j1 db 0
    oportunidades_j2 db 0
    
    SCREEN_WIDTH    EQU 80
    SCREEN_HEIGHT   EQU 25

    NUM_EMOJIS      EQU 20
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
    
    NUMBER_COUNT      EQU 10
    _number_chars   DB '0123456789'

    COLOR_PALETTE_SIZE  EQU 15
    prng_seed   DW  ?
    color_palette   DB  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    palette_chars   DB 'A', 'R', 'V', 'M', 'N', 'C', 'G', 'B', 'Z', 'F', 'Q', 'T', 'L', 'P', 'S'
    
    game_sequence_buffer   DB 50 DUP(?)
    player_sequence_buffer DB 50 DUP(?)
    player_input_count     DB 0
    current_seq_length     DB ?
      
    COLOR_SEQ_LENGTH_EASY   EQU 5
    COLOR_SEQ_LENGTH_MED    EQU 8
    COLOR_SEQ_LENGTH_HARD   EQU 12
    EMOJI_SEQ_LENGTH_EASY   EQU 5
    EMOJI_SEQ_LENGTH_MED    EQU 8
    EMOJI_SEQ_LENGTH_HARD   EQU 12
    NUMBER_SEQ_LENGTH_EASY  EQU 7
    NUMBER_SEQ_LENGTH_MED   EQU 10
    NUMBER_SEQ_LENGTH_HARD  EQU 14
    
    time_delays_h   DW 13h,   0Bh,   03h
    time_delays_l   DW 12D0h, 71B0h, 0D480h 

    tiempos_iniciales   dw 10, 8, 5
    oportunidades_iniciales DB 3, 2, 1 
     
    PIXELS_PER_CHAR   EQU 8
    COL_GRID_S_COL    EQU 20
    COL_GRID_S_ROW    EQU 8
    COL_GRID_H_SP     EQU 5
    COL_GRID_V_SP     EQU 4
    COL_GRID_N_FILAS  EQU 3
    COL_GRID_N_COLS   EQU 5
    COL_CLICK_BOX_W   EQU 2 * PIXELS_PER_CHAR
    COL_CLICK_BOX_H   EQU 2 * PIXELS_PER_CHAR
    COL_GRID_X_START  DW COL_GRID_S_COL * PIXELS_PER_CHAR
    COL_GRID_Y_START  DW COL_GRID_S_ROW * PIXELS_PER_CHAR
    COL_ANCHO_CELDA   EQU COL_GRID_H_SP * PIXELS_PER_CHAR
    COL_ALTO_CELDA    EQU COL_GRID_V_SP * PIXELS_PER_CHAR
    
    EMOJI_GRID_S_COL  EQU 18
    EMOJI_GRID_S_ROW  EQU 6
    EMOJI_GRID_H_SP   EQU 8
    EMOJI_GRID_V_SP   EQU 4
    EMOJI_GRID_N_FILAS EQU 4
    EMOJI_GRID_N_COLS  EQU 5
    EMOJI_CLICK_BOX_W  EQU 4 * PIXELS_PER_CHAR
    EMOJI_CLICK_BOX_H  EQU 2 * PIXELS_PER_CHAR
    EMOJI_GRID_X_START DW EMOJI_GRID_S_COL * PIXELS_PER_CHAR
    EMOJI_GRID_Y_START DW EMOJI_GRID_S_ROW * PIXELS_PER_CHAR
    EMOJI_ANCHO_CELDA  EQU EMOJI_GRID_H_SP * PIXELS_PER_CHAR
    EMOJI_ALTO_CELDA   EQU EMOJI_GRID_V_SP * PIXELS_PER_CHAR

    NUM_GRID_S_COL    EQU 20
    NUM_GRID_S_ROW    EQU 10
    NUM_GRID_H_SP     EQU 8
    NUM_GRID_V_SP     EQU 4
    NUM_GRID_N_FILAS  EQU 2
    NUM_GRID_N_COLS   EQU 5
    NUM_CLICK_BOX_W   EQU 2 * PIXELS_PER_CHAR
    NUM_CLICK_BOX_H   EQU 2 * PIXELS_PER_CHAR
    NUM_GRID_X_START  DW NUM_GRID_S_COL * PIXELS_PER_CHAR
    NUM_GRID_Y_START  DW NUM_GRID_S_ROW * PIXELS_PER_CHAR
    NUM_ANCHO_CELDA   EQU NUM_GRID_H_SP * PIXELS_PER_CHAR
    NUM_ALTO_CELDA    EQU NUM_GRID_V_SP * PIXELS_PER_CHAR
    
    BTN_RENDIRSE_X DW 15 * PIXELS_PER_CHAR
    BTN_RENDIRSE_Y DW 24 * PIXELS_PER_CHAR
    BTN_RENDIRSE_W DW 12 * PIXELS_PER_CHAR
    BTN_RESET_X    DW 35 * PIXELS_PER_CHAR
    BTN_RESET_Y    DW 24 * PIXELS_PER_CHAR
    BTN_RESET_W    DW 9 * PIXELS_PER_CHAR
    BTN_QUIT_X     DW 55 * PIXELS_PER_CHAR
    BTN_QUIT_Y     DW 24 * PIXELS_PER_CHAR
    BTN_QUIT_W     DW 8 * PIXELS_PER_CHAR
    BTN_H          DW 1 * PIXELS_PER_CHAR

    mouse_was_down    db 0
    click_valido      db 0
    elemento_seleccionado db ?
    mouse_x           dw ?
    mouse_y           dw ?
    menu_click_result db 0 
    
DATOS ENDS

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

CODIGO SEGMENT
    ASSUME DS:DATOS, CS:CODIGO, SS:PILA

INICIO PROC FAR
    MOV AX, DATOS
    MOV DS, AX
    MOV ES, AX
    
Main_Game_Loop:
    MOV [estado_j1], 1
    MOV [estado_j2], 1
    MOV [jugador_actual], 1
    MOV [puntaje1], 0
    MOV [puntaje2], 0

    CALL Initial_Setup_Players
    CALL Configure_Game_Settings
        
game_round:
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
    
    CALL Esperar_Input_Jugador_Loop
        
    LEA SI, game_sequence_buffer
    LEA DI, player_sequence_buffer
    MOV CL, [current_seq_length]
    MOV CH, 0
    JCXZ ronda_ganada

    verif_loop_inline:
        MOV AL, [SI]
        MOV BL, [DI]
        CMP AL, BL
        JNE ronda_perdida
        INC SI
        INC DI
        LOOP verif_loop_inline
    JMP ronda_ganada
        
;Lógica de ronda perdida que maneja ambos modos de juego
ronda_perdida:
    GOTOXY 28, 12
    LEA DX, msg_fallo
    MOV AH, 09h
    INT 21h
    
    ; Muestra el feedback de secuencias, útil para ambos modos
    GOTOXY 0, 21
    PRINT "Simon Dice: "
    LEA SI, game_sequence_buffer
    MOV CL, [current_seq_length]
    MOV CH, 0
    CALL Print_Buffer
        
    GOTOXY 0, 22
    PRINT "Tu Dijiste: "
    LEA SI, player_sequence_buffer
    MOV CL, [player_input_count]
    MOV CH, 0
    CALL Print_Buffer
    
    ;Comprueba el modo de juego para decidir qué hacer ---
    CMP [modo_juego], 1
    JE modo_tiempo_perdida      ; Si es 1, es por tiempo, usa la lógica anterior

;Lógica para MODO POR OPORTUNIDADES ---
modo_oportunidades_perdida:
    CMP [jugador_actual], 1
    JE restar_oportunidad_j1
    
restar_oportunidad_j2:
    DEC [oportunidades_j2]      ; Resta una vida al J2
    CALL Dibujar_HUD            ; Actualiza el HUD para mostrar la vida menos
    CMP [oportunidades_j2], 0
    JNE cambiar_de_turno        ; Si aún tiene vidas, solo cambia el turno
    MOV [estado_j2], 0          ; Si no, queda fuera de juego
    JMP chequear_fin_partida    ; Y revisa si la partida terminó

restar_oportunidad_j1:
    DEC [oportunidades_j1]      ; Resta una vida al J1
    CALL Dibujar_HUD            ; Actualiza el HUD
    CMP [oportunidades_j1], 0
    JNE cambiar_de_turno        ; Si aún tiene vidas, solo cambia el turno
    MOV [estado_j1], 0          ; Si no, queda fuera de juego
    JMP chequear_fin_partida    ; Y revisa si la partida terminó

modo_tiempo_perdida:
    CMP [player_count], 1
    JE fin_juego_individual

    CMP [jugador_actual], 1
    JE marcar_j1_fuera_directo

marcar_j2_fuera_directo:
    MOV [estado_j2], 0
    JMP chequear_fin_partida

marcar_j1_fuera_directo:
    MOV [estado_j1], 0

chequear_fin_partida:
    CMP [estado_j1], 0
    JNE cambiar_de_turno
    CMP [estado_j2], 0
    JNE cambiar_de_turno
    JMP declarar_ganador

fin_juego_individual:
    CALL Manejar_Opciones_Fin_Juego
    JMP fin_del_juego

ronda_ganada:
    CMP [jugador_actual], 1
    JE dar_punto_j1
dar_punto_j2:
    ADD [puntaje2], 10
    JMP mostrar_mensaje_acierto
dar_punto_j1:
    ADD [puntaje1], 10
mostrar_mensaje_acierto:
    GOTOXY 28, 12
    LEA DX, msg_acierto
    MOV AH, 09h
    INT 21h
    MOV CX, 0Fh
    MOV DX, 4240h
    MOV AH, 86h
    INT 15h
    JMP cambiar_de_turno

cambiar_de_turno:
    CMP [player_count], 2
    JNE game_round

    CMP [jugador_actual], 1
    JE chequear_estado_j2

chequear_estado_j1:
    CMP [estado_j1], 1
    JNE game_round 
    MOV [jugador_actual], 1
    JMP game_round

chequear_estado_j2:
    CMP [estado_j2], 1
    JNE game_round 
    MOV [jugador_actual], 2
    JMP game_round

declarar_ganador:
    GOTOXY 28, 13
    MOV AX, [puntaje1]
    CMP AX, [puntaje2]
    JA j1_gana_final
    JB j2_gana_final
    LEA DX, msg_empate
    JMP mostrar_ganador
j1_gana_final:
    LEA DX, msg_j1_gana
    JMP mostrar_ganador
j2_gana_final:
    LEA DX, msg_j2_gana
mostrar_ganador:
    MOV AH, 09h
    INT 21h
    CALL Manejar_Opciones_Fin_Juego
    JMP fin_del_juego

jugador_se_rinde:
    CMP [player_count], 1
    JE rendicion_j1_solo

    GOTOXY 28, 12
    CMP [jugador_actual], 1
    JE j2_gana_por_rendicion
j1_gana_por_rendicion:
    LEA DX, msg_j1_gana_rendicion
    JMP mostrar_ganador
j2_gana_por_rendicion:
    LEA DX, msg_j2_gana_rendicion
    JMP mostrar_ganador

rendicion_j1_solo:
    GOTOXY 28, 12
    LEA DX, msg_rendirse
    MOV AH, 09h
    INT 21h
    CALL Manejar_Opciones_Fin_Juego
    JMP fin_del_juego

fin_del_juego:
    MOV AX, 4C00h
    INT 21h
INICIO ENDP

Manejar_Opciones_Fin_Juego PROC NEAR
    CALL init_mouse
    mov mouse_was_down, 0
end_game_loop:
    mov ax, 3
    int 33h
    mov [mouse_x], cx
    mov [mouse_y], dx
    cmp bx, 1
    jne end_game_button_released
    cmp mouse_was_down, 1
    je end_game_loop
    mov mouse_was_down, 1
    call check_click_on_menu
    mov al, [menu_click_result]
    cmp al, 2
    jne check_quit_end_game
    call shutdown_mouse
    mov ah, 06h
    mov al, 00h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    GOTOXY 0, 0
    jmp Main_Game_Loop
check_quit_end_game:
    cmp al, 3
    jne end_game_loop
    jmp fin_del_juego
end_game_button_released:
    mov mouse_was_down, 0
    jmp end_game_loop
    RET
Manejar_Opciones_Fin_Juego ENDP

;; --- (RESTAURADO) --- Procedimiento con la lógica de feedback original
Esperar_Input_Jugador_Loop PROC NEAR
    CALL init_mouse
    CALL Determinar_Longitud_Secuencia
    mov [player_input_count], 0
    
    GOTOXY 1, 20
    LEA DX, msg_feedback
    MOV AH, 09h
    INT 21h
    
mouse_input_loop:
    mov ax, 3
    int 33h
    mov [mouse_x], cx
    mov [mouse_y], dx
    
    cmp bx, 1
    jne button_released_main
    
    cmp mouse_was_down, 1
    je mouse_input_loop
    mov mouse_was_down, 1
    
    call check_click_on_menu
    cmp [menu_click_result], 0
    jne handle_menu_click

    mov al, [tipo_juego]
    cmp al, 1
    je check_colores
    cmp al, 2
    je check_emojis
    cmp al, 3
    je check_numeros
    jmp mouse_input_loop

check_colores:
    call check_click_on_colores
    jmp procesar_clic_valido
check_emojis:
    call check_click_on_emojis
    jmp procesar_clic_valido
check_numeros:
    call check_click_on_numeros

procesar_clic_valido:
    cmp [click_valido], 0
    je mouse_input_loop

    mov al, [player_input_count]
    mov ah, 0
    mov si, ax
    
    mov al, [elemento_seleccionado]
    mov [player_sequence_buffer + si], al

    GOTOXY 19, 20
    mov al, [elemento_seleccionado]
    mov ah, 0
    CALL PRINT_NUM_UNS
    PRINT " "
    
    inc [player_input_count]
    mov al, [player_input_count]
    cmp al, [current_seq_length]
    je sequence_complete
    
    jmp mouse_input_loop

handle_menu_click:
    mov al, [menu_click_result]
    cmp al, 1
    jne check_reset
    jmp jugador_se_rinde

check_reset:
    cmp al, 2
    jne check_quit
    call shutdown_mouse
    mov ah, 06h
    mov al, 00h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    GOTOXY 0, 0
    jmp Main_Game_Loop

check_quit:
    cmp al, 3
    jne fin_manejo_clicks
    jmp fin_del_juego

fin_manejo_clicks:
    jmp sequence_complete

button_released_main:
    mov mouse_was_down, 0
    jmp mouse_input_loop

sequence_complete:
    GOTOXY 1, 20
    PRINT "                                  "
    call shutdown_mouse
    RET
Esperar_Input_Jugador_Loop ENDP

;; --- (MODIFICADO) --- El HUD ahora muestra Vidas o Tiempo dinámicamente
Dibujar_HUD PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
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
    PRINT "Jugador: "
    GOTOXY 2, 2
    PRINT "Puntaje: "

    ;; --- Lógica para mostrar datos de J1 o J2 ---
    CMP [jugador_actual], 1
    JE hud_para_j1

hud_para_j2:
    GOTOXY 13, 1
    MOV DX, OFFSET nickname2
    MOV AH, 09h
    INT 21h
    GOTOXY 13, 2
    MOV AX, [puntaje2]
    CALL PRINT_NUM
    JMP hud_modo_juego

hud_para_j1:
    GOTOXY 13, 1
    MOV DX, OFFSET nickname1
    MOV AH, 09h
    INT 21h
    GOTOXY 13, 2
    MOV AX, [puntaje1]
    CALL PRINT_NUM

;HUD que muestra los datos y se ajusta según Vidas o Tiempo
hud_modo_juego:
    CMP [modo_juego], 1
    JE hud_mostrar_tiempo

hud_mostrar_oportunidades:
    GOTOXY 2, 3
    PRINT "Vidas:   " ; Imprime Vidas y espacios para limpiar "Tiempo"
    GOTOXY 13, 3
    CMP [jugador_actual], 1
    JE hud_vidas_j1
    MOV AL, [oportunidades_j2]
    JMP hud_print_vidas
hud_vidas_j1:
    MOV AL, [oportunidades_j1]
hud_print_vidas:
    MOV AH, 0  ; Limpia AH para que PRINT_NUM funcione con el valor de AL
    CALL PRINT_NUM
    JMP fin_hud
    
hud_mostrar_tiempo:
    GOTOXY 2, 3
    PRINT "Tiempo:  "
    GOTOXY 13, 3
    MOV AX, [tiempo_restante]
    CALL PRINT_NUM

fin_hud:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Dibujar_HUD ENDP

Determinar_Longitud_Secuencia PROC NEAR
    mov al, [tipo_juego]
    cmp al, 1
    je set_len_col
    cmp al, 2
    je set_len_emo
    cmp al, 3
    je set_len_num
    ret
set_len_col:
    mov al, [dificultad]
    cmp al, 1
    je set_len_col_e
    cmp al, 2
    je set_len_col_m
    mov bl, COLOR_SEQ_LENGTH_HARD
    jmp fin_set_len
    set_len_col_m:
    mov bl, COLOR_SEQ_LENGTH_MED
    jmp fin_set_len
    set_len_col_e:
    mov bl, COLOR_SEQ_LENGTH_EASY
    jmp fin_set_len
set_len_emo:
    mov al, [dificultad]
    cmp al, 1
    je set_len_emo_e
    cmp al, 2
    je set_len_emo_m
    mov bl, EMOJI_SEQ_LENGTH_HARD
    jmp fin_set_len
    set_len_emo_m:
    mov bl, EMOJI_SEQ_LENGTH_MED
    jmp fin_set_len
    set_len_emo_e:
    mov bl, EMOJI_SEQ_LENGTH_EASY
    jmp fin_set_len
set_len_num:
    mov al, [dificultad]
    cmp al, 1
    je set_len_num_e
    cmp al, 2
    je set_len_num_m
    mov bl, NUMBER_SEQ_LENGTH_HARD
    jmp fin_set_len
    set_len_num_m:
    mov bl, NUMBER_SEQ_LENGTH_MED
    jmp fin_set_len
    set_len_num_e:
    mov bl, NUMBER_SEQ_LENGTH_EASY
fin_set_len:
    mov [current_seq_length], bl
    ret
ENDP

init_mouse PROC NEAR
    mov ax, 0
    int 33h
    mov ax, 1
    int 33h
    ret
ENDP

shutdown_mouse PROC NEAR
    mov ax, 2
    int 33h
    ret
ENDP

check_click_on_colores PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, COL_GRID_Y_START
    jl salir_sin_exito_mouse
    mov ax, COL_GRID_Y_START
    add ax, (COL_GRID_N_FILAS * COL_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, COL_GRID_X_START
    jl salir_sin_exito_mouse
    mov ax, COL_GRID_X_START
    add ax, (COL_GRID_N_COLS * COL_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, COL_GRID_X_START
    xor dx, dx
    mov bx, COL_ANCHO_CELDA
    div bx
    cmp dx, COL_CLICK_BOX_W
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, COL_GRID_Y_START
    xor dx, dx
    mov bx, COL_ALTO_CELDA
    div bx
    cmp dx, COL_CLICK_BOX_H
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, COL_GRID_N_COLS
    mul bl
    add al, ch
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret
salir_sin_exito_mouse:
    mov [click_valido], 0
    ret
ENDP

check_click_on_emojis PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, EMOJI_GRID_Y_START
    jl salir_sin_exito_mouse
    mov ax, EMOJI_GRID_Y_START
    add ax, (EMOJI_GRID_N_FILAS * EMOJI_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, EMOJI_GRID_X_START
    jl salir_sin_exito_mouse
    mov ax, EMOJI_GRID_X_START
    add ax, (EMOJI_GRID_N_COLS * EMOJI_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, EMOJI_GRID_X_START
    xor dx, dx
    mov bx, EMOJI_ANCHO_CELDA
    div bx
    cmp dx, EMOJI_CLICK_BOX_W
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, EMOJI_GRID_Y_START
    xor dx, dx
    mov bx, EMOJI_ALTO_CELDA
    div bx
    cmp dx, EMOJI_CLICK_BOX_H
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, EMOJI_GRID_N_COLS
    mul bl
    add al, ch
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret
ENDP

check_click_on_numeros PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, NUM_GRID_Y_START
    jl salir_sin_exito_mouse
    mov ax, NUM_GRID_Y_START
    add ax, (NUM_GRID_N_FILAS * NUM_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, NUM_GRID_X_START
    jl salir_sin_exito_mouse
    mov ax, NUM_GRID_X_START
    add ax, (NUM_GRID_N_COLS * NUM_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, NUM_GRID_X_START
    xor dx, dx
    mov bx, NUM_ANCHO_CELDA
    div bx
    cmp dx, NUM_CLICK_BOX_W
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, NUM_GRID_Y_START
    xor dx, dx
    mov bx, NUM_ALTO_CELDA
    div bx
    cmp dx, NUM_CLICK_BOX_H
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, NUM_GRID_N_COLS
    mul bl
    add al, ch
    cmp al, 10
    jge salir_sin_exito_mouse
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret
ENDP

check_click_on_menu PROC NEAR
    mov [menu_click_result], 0
    mov cx, mouse_x
    mov dx, mouse_y
    cmp dx, BTN_RENDIRSE_Y
    jl no_menu_click
    mov ax, BTN_RENDIRSE_Y
    add ax, BTN_H
    cmp dx, ax
    jg check_reset_btn
    cmp cx, BTN_RENDIRSE_X
    jl check_reset_btn
    mov ax, BTN_RENDIRSE_X
    add ax, BTN_RENDIRSE_W
    cmp cx, ax
    jg check_reset_btn
    mov [menu_click_result], 1
    ret
check_reset_btn:
    cmp dx, BTN_RESET_Y
    jl no_menu_click
    mov ax, BTN_RESET_Y
    add ax, BTN_H
    cmp dx, ax
    jg check_quit_btn
    cmp cx, BTN_RESET_X
    jl check_quit_btn
    mov ax, BTN_RESET_X
    add ax, BTN_RESET_W
    cmp cx, ax
    jg check_quit_btn
    mov [menu_click_result], 2
    ret
check_quit_btn:
    cmp dx, BTN_QUIT_Y
    jl no_menu_click
    mov ax, BTN_QUIT_Y
    add ax, BTN_H
    cmp dx, ax
    jg no_menu_click
    cmp cx, BTN_QUIT_X
    jl no_menu_click
    mov ax, BTN_QUIT_X
    add ax, BTN_QUIT_W
    cmp cx, ax
    jg no_menu_click
    mov [menu_click_result], 3
    ret
no_menu_click:
    ret
ENDP

Jugar_Secuencia_Colores PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV AH, 2Ch
    INT 21h
    MOV [prng_seed], DX
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    LEA DI, game_sequence_buffer
    MOV CH, 0
    CMP dificultad, 1
    JE  easy_len_color_g
    CMP dificultad, 2
    JE  medium_len_color_g
hard_len_color_g:
    MOV CL, COLOR_SEQ_LENGTH_HARD
    JMP start_color_loop_g
medium_len_color_g:
    MOV CL, COLOR_SEQ_LENGTH_MED
    JMP start_color_loop_g
easy_len_color_g:
    MOV CL, COLOR_SEQ_LENGTH_EASY
start_color_loop_g:
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
    MOV [DI], DL
    INC DI
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Jugar_Secuencia_Colores ENDP

Jugar_Secuencia_Emojis PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA DI, game_sequence_buffer
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
    MOV [DI], AH
    INC DI
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Jugar_Secuencia_Emojis ENDP

MostrarSecuenciaNumeros PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA DI, game_sequence_buffer
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
    MOV [DI], AH
    INC DI
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
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
    JMP ask_mode  ;; --- MODIFICADO: Saltamos a preguntar el modo

invalid_difficulty:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_difficulty

;; --- (NUEVO) --- Preguntar por el modo de juego
ask_mode:
    PRINTN ""
    PRINT "Seleccione el modo (1=Por Tiempo, 2=Por Oportunidades): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL invalid_mode_response
    CMP AL, 2
    JG invalid_mode_response
    MOV [modo_juego], AL
    JMP config_done

invalid_mode_response:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_mode
    
config_done:
    CMP [modo_juego], 1
    JE init_tiempo
    ;llamamos a la rutina de oportunidades 
    CALL Actualizar_Oportunidades_Iniciales
    JMP fin_config
    
init_tiempo:
    CALL Actualizar_Tiempo_Inicial

fin_config:
    PRINTN ""
    PRINTN "--- Configuracion guardada. Preparando el juego... ---"
    RET
Configure_Game_Settings ENDP    

Actualizar_Tiempo_Inicial PROC NEAR
    PUSH AX
    PUSH BX
    MOV AL, [dificultad]
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV AX, [tiempos_iniciales + BX]
    MOV [tiempo_restante], AX
    POP BX
    POP AX
    RET
Actualizar_Tiempo_Inicial ENDP
                      
;Procedimiento para establecer las oportunidades iniciales
Actualizar_Oportunidades_Iniciales PROC NEAR
    PUSH AX
    PUSH BX
    
    MOV AL, [dificultad]
    DEC AL  ; Ajusta el índice (1,2,3 -> 0,1,2)
    MOV AH, 0
    MOV BX, AX
    
    ; Carga el número de oportunidades desde la tabla
    MOV AL, [oportunidades_iniciales + BX]
    
    ; Asigna las oportunidades a ambos jugadores
    MOV [oportunidades_j1], AL
    MOV [oportunidades_j2], AL
    
    POP BX
    POP AX
    RET
Actualizar_Oportunidades_Iniciales ENDP                      
 
Mostrar_Contador PROC NEAR
    PUSH CX
    PUSH DX
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
    POP DX
    POP CX
    RET
Mostrar_Contador ENDP  

Dibujar_Paleta_Colores PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
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

Dibujar_Paleta_Emojis PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV CX, NUM_EMOJIS 
    MOV SI, 0          
emoji_grid_loop:
    PUSH CX
    MOV AX, SI      
    MOV BL, 5       
    DIV BL          
    MOV CH, AL      
    MOV CL, AH      
    MOV AL, 4       
    MUL CH          
    ADD AL, 6       
    MOV DH, AL      
    MOV AL, 8       
    MUL CL         
    ADD AL, 18      
    MOV DL, AL      
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
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Dibujar_Paleta_Emojis ENDP

Dibujar_Paleta_Numeros PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX, 10      
    MOV SI, 0       
num_grid_loop:
    PUSH CX
    MOV AX, SI
    MOV BL, 5       
    DIV BL
    MOV CH, AL      
    MOV CL, AH      
    MOV AL, 4
    MUL CH
    ADD AL, 10      
    MOV DH, AL
    MOV AL, 8
    MUL CL
    ADD AL, 20      
    MOV DL, AL
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    MOV BX, SI
    MOV AL, [_number_chars + BX]
    PUTC AL
    INC SI
    POP CX
    LOOP num_grid_loop
    POP SI
    POP CX
    POP BX
    POP AX
    RET
Dibujar_Paleta_Numeros ENDP

Dibujar_Botones_Menu PROC NEAR
    GOTOXY 15, 24
    PRINT "[ Rendirse ]"
    GOTOXY 35, 24
    PRINT "[ Reset ]"
    GOTOXY 55, 24
    PRINT "[ Quit ]"
    RET
Dibujar_Botones_Menu ENDP

Print_Buffer PROC NEAR
    PUSH AX
    PUSH CX
    PUSH SI
print_buffer_loop:
    MOV AL, [SI]
    MOV AH, 0
    CALL PRINT_NUM_UNS
    PUTC ' '
    INC SI
    LOOP print_buffer_loop
    POP SI
    POP CX
    POP AX
    RET
Print_Buffer ENDP

CODIGO ENDS

DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

END INICIO