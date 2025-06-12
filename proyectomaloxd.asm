INCLUDE 'emu8086.inc'

DATOS SEGMENT
    ; --- Mensajes (se usarán menos gracias a la librería) ---
    
    ; --- Variables de estado del juego ---
    player_count  db 0
    nickname1     db 11 dup('$')
    nickname2     db 11 dup('$')
    
    tipo_juego    db 0 ; 1=Colores, 2=Emojis, 3=Numeros
    dificultad    db 0 ; 1=Facil, 2=Intermedio, 3=Dificil
    modo_juego    db 0 ; 1=Tiempo, 2=Intentos
    
    current_player db 1
    score1        dw 0
    score2        dw 0
    opportunities dw 0
    timer_seconds dw 0
    
    ; --- Secuencias ---
    sequence      db 32 dup(0)
    sequence_len  db 0
    
    ; --- Coordenadas y paleta para la UI Gráfica (se usarán después) ---
    color_palette   db 04h, 01h, 02h, 0Eh, 06h, 05h, 0Fh, 0Ch, 09h, 0Ah, 0Bh, 0Dh, 03h, 07h, 08h ; 15 colores
    option_boxes    dw 15 DUP(0, 0, 0, 0) ; (x1, y1, x2, y2)                                                          
    mouse_x DW 0
    mouse_y DW 0
    player_input DB 0

DATOS ENDS

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

CODIGO SEGMENT
    ASSUME DS:DATOS, CS:CODIGO, SS:PILA

INICIO PROC FAR
    ; --- Forzar modo de texto 80x25 para la configuración inicial ---
    MOV AH, 00h
    MOV AL, 03h
    INT 10h          ;

    ; --- Configuración de segmentos (una sola vez) ---
    MOV AX, DATOS
    MOV DS, AX
    MOV ES, AX

    ; --- Llamada ÚNICA al bucle principal del juego ---
    CALL Main_Game_Loop
    
    ; --- Salir del programa al DOS ---
    MOV AX, 4C00h    ; Función para terminar programa.
    INT 21h
INICIO ENDP
                      

Init_Mouse PROC NEAR
    MOV AX, 0       ; Función 0: inicializar mouse
    INT 33h
    CMP AX, 0
    JE no_mouse     ; Si no hay mouse, saltar

    ; Función 1: mostrar cursor
    MOV AX, 1
    INT 33h

    RET
no_mouse:
    ; Aquí puedes manejar error o simplemente seguir sin mouse
    RET
Init_Mouse ENDP
                    
Get_Player_Input_Mouse PROC NEAR
    ; Esperar click izquierdo
wait_click:
    MOV AX, 3       ; Función 3: obtener estado y posición del mouse
    INT 33h
    TEST BX, 1      ; Bit 0 = botón izquierdo presionado
    JZ wait_click   ; Si no está presionado, esperar

    ; Guardamos la posición del mouse
    MOV CX, DX      ; CX = X
    MOV DX, BP      ; DX = Y  (ajusta según convención, en algunos docs es AX=buttons, CX=X, DX=Y)

    ; Nota: Para INT 33h, función 3h retorna:
    ; BX = button status
    ; CX = X coord
    ; DX = Y coord

    ; Aquí corregimos:
    MOV CX, CX      ; X ya está en CX
    MOV DX, DX      ; Y ya está en DX

    ; Guardar posiciones en variables
    MOV mouse_x, CX
    MOV mouse_y, DX

    ; Mapear posición a botón
    ; Por ejemplo, tu UI tiene botones en estas áreas (en pixeles):
    ; Botón 1: x=10-50, y=10-50
    ; Botón 2: x=60-100, y=10-50
    ; Botón 3: x=110-150, y=10-50
    ; Ajusta estos valores a tu UI real

    CMP CX, 10
    JL invalid_click
    CMP CX, 50
    JG check_button_2
    CMP DX, 10
    JL invalid_click
    CMP DX, 50
    JG invalid_click

    MOV player_input, 1
    JMP input_done

check_button_2:
    CMP CX, 60
    JL invalid_click
    CMP CX, 100
    JG check_button_3
    CMP DX, 10
    JL invalid_click
    CMP DX, 50
    JG invalid_click

    MOV player_input, 2
    JMP input_done

check_button_3:
    CMP CX, 110
    JL invalid_click
    CMP CX, 150
    JG invalid_click
    CMP DX, 10
    JL invalid_click
    CMP DX, 50
    JG invalid_click

    MOV player_input, 3
    JMP input_done

invalid_click:
    ; Click fuera de botones válidos, esperar otro click
    JMP wait_click

input_done:
    ; Aquí ya tienes player_input con el botón (1, 2, o 3)
    RET
Get_Player_Input_Mouse ENDP

; =======================================================
; BUCLE PRINCIPAL Y GESTIÓN DEL JUEGO
; =======================================================
Main_Game_Loop PROC NEAR
    ; --- Configuración inicial ---
    CALL Initial_Setup_Players
    CALL Configure_Game_Settings
    CALL Clear_Keyboard_Buffer
    CALL Init_Graphics_Mode  
    CALL Init_Mouse
    CALL Draw_Game_UI

    ; Inicializamos variables importantes
    MOV current_player, 1
    MOV score1, 0
    MOV score2, 0

game_loop_start:
    ; Generar la secuencia nueva para este turno
    CALL Generate_Sequence

    ; Mostrar la secuencia gráfica
    CALL Display_Sequence_Graphics

    ; Configurar número de intentos o tiempo según modo
    MOV AL, modo_juego
    CMP AL, 1          ; Modo tiempo
    JE set_timer_mode
    CMP AL, 2          ; Modo intentos
    JE set_attempts_mode

    JMP start_input_loop

set_timer_mode:
    ; Por ejemplo, 30 segundos (ajustar según dificultad)
    MOV timer_seconds, 30
    JMP start_input_loop

set_attempts_mode:
    ; Por ejemplo, 3 oportunidades
    MOV opportunities, 3
    JMP start_input_loop

start_input_loop:
    ; CX = longitud de la secuencia a validar
    MOV CL, sequence_len

input_loop:
    ; Esperar y obtener la entrada del jugador
    CALL Get_Player_Input_Mouse
    
    ; Validar la entrada contra la secuencia actual
    CALL Check_Player_Input

    ; Aquí se debería actualizar oportunidades o timer según resultado
    ; Y mostrar puntajes y estado en pantalla

    ; Comprobar si terminó el turno o se acabaron oportunidades/tiempo
    ; (Procedimiento para detectar fin de turno - pendiente)

    ; Por ahora sólo decrementamos CX para salir del loop
    LOOP input_loop

    ; Cambiar de jugador si hay dos
    CMP player_count, 2
    JNE game_loop_continue

    ; Cambiar jugador
    MOV AL, current_player
    CMP AL, 1
    JE set_player_2
    MOV current_player, 1
    JMP game_loop_continue

set_player_2:
    MOV current_player, 2

game_loop_continue:
    ; Repetir el juego indefinidamente (puedes agregar condición de salida)
    JMP game_loop_start

Main_Game_Loop ENDP

; =======================================================
; PROCEDIMIENTOS DE CONFIGURACIÓN (SIN CAMBIOS)
; =======================================================

Initial_Setup_Players PROC NEAR
    ; ... (tu código existente aquí, no necesita cambios)
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
    ; ... (tu código existente aquí, no necesita cambios)
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
    ; ... (tu código existente aquí, no necesita cambios)
    PUSH AX
    MOV AH, 09h
    INT 21h
    PRINTN ""
    POP AX
    RET
Print_Nickname ENDP


Configure_Game_Settings PROC NEAR
    ; ... (tu código existente aquí, no necesita cambios)
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
    JMP ask_mode

invalid_difficulty:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_difficulty

ask_mode:
    PRINTN ""
    PRINT "Seleccione el modo de juego (1=Por Tiempo, 2=Por Intentos): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL invalid_mode
    CMP AL, 2
    JG invalid_mode
    MOV modo_juego, AL
    JMP config_done

invalid_mode:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP ask_mode

config_done:
    PRINTN ""
    PRINTN "--- Configuracion guardada. Preparando el juego... ---"
    RET
Configure_Game_Settings ENDP    

Clear_Keyboard_Buffer PROC NEAR
    ; Limpia cualquier caracter residual en el búfer del teclado.
    PUSH AX
flush_loop:
    MOV AH, 01h      ; Función: Comprobar si hay tecla en el búfer.
    INT 16h
    JZ end_flush     ; Si ZF=1, no hay teclas, el búfer está limpio. Salir.
    
    MOV AH, 00h      ; Si ZF=0, hay una tecla. La leemos para descartarla.
    INT 16h
    JMP flush_loop   ; Comprobar de nuevo.
end_flush:
    POP AX
    RET
Clear_Keyboard_Buffer ENDP

; =======================================================
; PROCEDIMIENTOS GRÁFICOS Y DE LÓGICA (OPTIMIZADOS)
; =======================================================
                  
Init_Graphics_Mode PROC NEAR
    MOV AH, 00h
    MOV AL, 13h
    INT 10h
    RET
Init_Graphics_Mode ENDP


Draw_Rect PROC NEAR
    ; Dibuja un rectángulo relleno escribiendo directamente en la memoria de video.
    ; Es mucho más rápido que dibujar píxel por píxel.
    ; Entrada (Pila): PUSH color, PUSH y2, PUSH x2, PUSH y1, PUSH x1
    PUSH BP
    MOV BP, SP

    PUSHA ; Guarda todos los registros generales (AX, CX, DX, BX, SP, BP, SI, DI)

    MOV AX, 0A000h
    MOV ES, AX       ; ES apunta al segmento de memoria de video.

    MOV AL, [BP+12]  ; Color
    MOV DX, [BP+6]   ; Y1 (fila inicial)
    
y_loop_fast:
    ; Calcular la dirección de inicio de la línea: offset = y * 320 + x
    MOV CX, DX       ; CX = y
    MOV AX, 320
    MUL CX           ; AX = y * 320
    ADD AX, [BP+4]   ; AX = y * 320 + x1
    MOV DI, AX       ; DI es nuestro puntero de destino en la memoria de video.

    ; Calcular el ancho del rectángulo
    MOV CX, [BP+8]   ; CX = x2
    SUB CX, [BP+4]   ; CX = x2 - x1
    INC CX           ; +1 para incluir el último píxel

    CLD              ; Asegura que la dirección de procesamiento sea hacia adelante.
    REP STOSB        ; Rellena CX bytes en ES:DI con el valor de AL (el color).

    INC DX           ; Siguiente fila
    CMP DX, [BP+10]  ; ¿Hemos llegado a y2?
    JNAE y_loop_fast

    POPA ; Restaura todos los registros generales
    MOV SP, BP
    POP BP
    RET 10 
Draw_Rect ENDP


Draw_Game_UI PROC NEAR
    ; Dibuja la interfaz gráfica principal usando el nuevo Draw_Rect rápido.
    ; El uso es el mismo: PUSH color, PUSH y2, PUSH x2, PUSH y1, PUSH x1.
    
    PUSH 8; PUSH 199; PUSH 319; PUSH 0; PUSH 0; CALL Draw_Rect ; Fondo
    PUSH 1; PUSH 20;  PUSH 319; PUSH 0; PUSH 0; CALL Draw_Rect ; Panel Superior
    PUSH 1; PUSH 199; PUSH 319; PUSH 180;PUSH 0; CALL Draw_Rect ; Panel Inferior
    PUSH 0; PUSH 170; PUSH 220; PUSH 30; PUSH 10; CALL Draw_Rect ; Área de Juego
    PUSH 6; PUSH 170; PUSH 309; PUSH 30; PUSH 230;CALL Draw_Rect ; Panel de Estado

    RET
Draw_Game_UI ENDP


Generate_Sequence PROC NEAR
    ; ... (tu código existente aquí, no necesita cambios)
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV AL, dificultad
    CMP AL, 1
    JE set_len_easy
    CMP AL, 2
    JE set_len_medium

    MOV sequence_len, 12
    JMP set_range

set_len_easy:
    MOV sequence_len, 5
    JMP set_range
set_len_medium:
    MOV sequence_len, 8
    JMP set_range

set_range:
    MOV AL, tipo_juego
    CMP AL, 1
    JE range_colors
    CMP AL, 2
    JE range_emojis

    MOV BL, 10
    JMP generate_loop

range_colors:
    MOV BL, 15
    JMP generate_loop
range_emojis:
    MOV BL, 15

generate_loop:
    LEA SI, sequence
    MOV CL, sequence_len
    XOR CH, CH
    
gen_single_number:
    MOV AH, 00h
    INT 1Ah
    
    MOV AX, DX
    XOR DX, DX
    DIV BL
    
    MOV [SI], AH
    INC SI
    
    LOOP gen_single_number

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Generate_Sequence ENDP


Display_Sequence_Graphics PROC NEAR
    RET            

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA SI, sequence         ; SI apunta a la secuencia
    MOV CL, sequence_len     ; Número de ítems a mostrar

    MOV BL, tipo_juego       ; Guarda tipo de juego (1=Colores, 2=Emojis, 3=Numeros)

    XOR CH, CH               ; CH:CL = contador total

next_item:
    ; --- Limpia el área de juego ---
    PUSH 0                   ; color negro (0)
    PUSH 170                 ; y2
    PUSH 220                 ; x2
    PUSH 30                  ; y1
    PUSH 10                  ; x1
    CALL Draw_Rect

    ; --- Mostrar el ítem actual ---
    MOV AL, [SI]             ; AL = valor del ítem actual

    ; Calcular posición del recuadro
    MOV DX, 80               ; x1
    MOV BX, 80               ; y1

    ; Dibuja según tipo de juego
    CMP BL, 1                ; ¿Colores?
    JE draw_color

    CMP BL, 2                ; ¿Emojis?
    JE draw_emoji

    ; Por defecto: Números
    JMP draw_number

draw_color:
    ; Dibuja un cuadrado del color indicado por AL
    ; Convertir AL en índice a color_palette[AL]
    MOV BX, 0
    MOV BL, AL
    MOV AL, color_palette[BX]

    PUSH AX                  ; color
    PUSH 120                 ; y2 = y1 + 40
    PUSH 120                 ; x2 = x1 + 40
    PUSH 80                  ; y1
    PUSH 80                  ; x1
    CALL Draw_Rect

    JMP wait_and_next

draw_emoji:
    ; Simularemos con colores (emoji = color + letra más adelante)
    MOV BX, 0
    MOV BL, AL
    MOV AL, color_palette[BX]

    PUSH AX                  ; color
    PUSH 120
    PUSH 120
    PUSH 80
    PUSH 80
    CALL Draw_Rect

    JMP wait_and_next

draw_number:
    ; Cuadro blanco con el número dentro (no implementamos texto aún)
    MOV AL, 0Fh              ; Blanco

    PUSH AX
    PUSH 120
    PUSH 120
    PUSH 80
    PUSH 80
    CALL Draw_Rect

    ; Futuro: dibujar el número en el centro

wait_and_next:
    ; Esperar 0.5 segundos = 500 ms
    ; Usamos INT 15h / AH=86h (espera basada en reloj)
    MOV AH, 86h
    MOV CX, 0                ; Alta parte (ms / 65536)
    MOV DX, 500              ; 500 ms
    INT 15h

    INC SI                  ; siguiente ítem
    LOOP next_item

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET     
    
Display_Sequence_Graphics ENDP
        


Check_Player_Input PROC NEAR
    RET
Check_Player_Input ENDP

Show_High_Scores PROC NEAR
    RET
Show_High_Scores ENDP

CODIGO ENDS
END INICIO