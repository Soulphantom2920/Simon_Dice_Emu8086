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

; =======================================================
; BUCLE PRINCIPAL Y GESTIÓN DEL JUEGO
; =======================================================
Main_Game_Loop PROC NEAR
    ; --- PASO 1: Configuración en MODO TEXTO ---
    CALL Initial_Setup_Players
    CALL Configure_Game_Settings

    ; --- PASO 2: Limpiar el búfer del teclado ---
    CALL Clear_Keyboard_Buffer

    ; --- PASO 3: Cambiar a MODO GRÁFICO ---
    CALL Init_Graphics_Mode

    ; --- PASO 4: Limpiar la pantalla de forma RÁPIDA ---
    ; Escribimos directamente en la memoria de video para pintar todo de azul.
    MOV AX, 0A000h
    MOV ES, AX       ; ES apunta al segmento de video.
    XOR DI, DI       ; Empezar en el offset 0 (píxel superior izquierdo).
    MOV AL, 1        ; Color Azul.
    MOV CX, 64000    ; 320*200 píxeles.
    CLD              ; Dirección hacia adelante.
    REP STOSB        ; Rellena toda la pantalla con el color en AL.

    ; --- PASO 5: Bucle infinito INTENCIONAL para detener el programa ---
    ; Esto nos permite ver la pantalla azul sin que el programa termine o haga algo más.
    ; Para salir, deberás cerrar el emulador manualmente.
wait_loop:
    JMP wait_loop

    ; El RET queda inalcanzable por ahora, lo cual es correcto para esta prueba.
    RET
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
Display_Sequence_Graphics ENDP

Get_Player_Input_Mouse PROC NEAR
    RET
Get_Player_Input_Mouse ENDP

Check_Player_Input PROC NEAR
    RET
Check_Player_Input ENDP

Show_High_Scores PROC NEAR
    RET
Show_High_Scores ENDP

CODIGO ENDS
END INICIO