INCLUDE "emu8086.inc"

DATOS SEGMENT  
    
    ;___Mensajes___
    msg_acierto   DB '¡Correcto! Siguiente ronda...', '$'
    msg_fallo     DB '¡Fallaste!', '$'
    msg_rendirse  DB 'Te has rendido. Fin del juego.', '$'
    msg_feedback  DB 'Entrada Jugador:      ', '$'
    
    msg_j1_gana     DB 'Resultado: GANA JUGADOR 1 !!!', '$'
    msg_j2_gana     DB 'Resultado: GANA JUGADOR 2 !!!', '$'
    msg_empate      DB 'Resultado: ES UN EMPATE.', '$'
    msg_j1_gana_rendicion DB 'J2 se rinde. GANA JUGADOR 1!', '$'
    msg_j2_gana_rendicion DB 'J1 se rinde. GANA JUGADOR 2!', '$'
     
    ;___Variables de juego y jugadores___
    cantidad_jugadores    db 0
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
           
    ;___Constantes de pantalla___          
    ANCHO_PANTALLA    EQU 80
    ALTO_PANTALLA   EQU 25

    ;___Emojis___
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
    punteros_emojis DW emoji1, emoji2, emoji3, emoji4, emoji5, emoji6, emoji7, emoji8, emoji9, emoji10
                    DW emoji11, emoji12, emoji13, emoji14, emoji15, emoji16, emoji17, emoji18, emoji19, emoji20
    ;___Numeros___
    CANTIDAD_NUMEROS      EQU 10
    caracteres_numericos   DB '0123456789'
    
    ;___Paleta de colores___
    TAMANO_PALETA_COLOR  EQU 15
    semilla_prng    DW  ?
    paleta_colores   DB  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    paleta_caracteres   DB 'A', 'R', 'V', 'M', 'N', 'C', 'G', 'B', 'Z', 'F', 'Q', 'T', 'L', 'P', 'S'
    
    ;___Buffers y longitudes de secuencia___
    Longitud_Facil_Emoji   DB 50 DUP(?)
    buffer_secuencia_jugador DB 50 DUP(?)
    contador_entrada_jugador     DB 0
    longitud_secuencia_actual     DB ?
      
    LONGITUD_SEC_COLOR_FACIL   EQU 5
    LONGITUD_SEC_COLOR_MEDIO    EQU 8
    LONGITUD_SEC_COLOR_DIFICIL   EQU 12  
    
    LONGITUD_SEC_EMOJI_FACIL   EQU 5
    LONGITUD_SEC_EMOJI_MEDIO    EQU 8
    LONGITUD_SEC_EMOJI_DIFICIL   EQU 12
    
    LONGITUD_SEC_NUMERO_FACIL  EQU 7
    LONGITUD_SEC_NUMERO_MEDIO   EQU 10
    LONGITUD_SEC_NUMERO_DIFICIL  EQU 14
    
    
    ;___Tiempos y oportunidades iniciales___
    retardos_tiempo_h   DW 13h,   0Bh,   03h
    retardos_tiempo_l   DW 12D0h, 71B0h, 0D480h 

    tiempos_iniciales   dw 10, 8, 5
    oportunidades_iniciales DB 3, 2, 1 
    
    ;___Para interfaz de usuario___
    PIXELES_POR_CARACTER   EQU 8  
    
    COL_CUADRICULA_C_COL    EQU 20
    COL_CUADRICULA_C_FILA    EQU 8   
    COL_CUADRICULA_ESP_H     EQU 5
    COL_CUADRICULA_ESP_V     EQU 4
    COL_CUADRICULA_N_FILAS  EQU 3
    COL_CUADRICULA_N_COLS   EQU 5
    COL_CAJA_CLIC_ANCHO   EQU 2 * PIXELES_POR_CARACTER
    COL_CAJA_CLIC_ALTO   EQU 2 * PIXELES_POR_CARACTER
    COL_CUADRICULA_X_INICIO  DW COL_CUADRICULA_C_COL * PIXELES_POR_CARACTER
    COL_CUADRICULA_Y_INICIO  DW COL_CUADRICULA_C_FILA * PIXELES_POR_CARACTER
    COL_ANCHO_CELDA   EQU COL_CUADRICULA_ESP_H * PIXELES_POR_CARACTER
    COL_ALTO_CELDA    EQU COL_CUADRICULA_ESP_V * PIXELES_POR_CARACTER
    
    EMOJI_CUADRICULA_C_COL  EQU 18
    EMOJI_CUADRICULA_C_FILA  EQU 6
    EMOJI_CUADRICULA_ESP_H   EQU 8
    EMOJI_CUADRICULA_ESP_V   EQU 4
    EMOJI_CUADRICULA_N_FILAS EQU 4
    EMOJI_CUADRICULA_N_COLS  EQU 5
    EMOJI_CAJA_CLIC_ANCHO  EQU 4 * PIXELES_POR_CARACTER
    EMOJI_CAJA_CLIC_ALTO  EQU 2 * PIXELES_POR_CARACTER
    EMOJI_CUADRICULA_X_INICIO DW EMOJI_CUADRICULA_C_COL * PIXELES_POR_CARACTER
    EMOJI_CUADRICULA_Y_INICIO DW EMOJI_CUADRICULA_C_FILA * PIXELES_POR_CARACTER
    EMOJI_ANCHO_CELDA  EQU EMOJI_CUADRICULA_ESP_H * PIXELES_POR_CARACTER
    EMOJI_ALTO_CELDA   EQU EMOJI_CUADRICULA_ESP_V * PIXELES_POR_CARACTER

    NUM_CUADRICULA_C_COL    EQU 20
    NUM_CUADRICULA_C_FILA    EQU 10
    NUM_CUADRICULA_ESP_H     EQU 8
    NUM_CUADRICULA_ESP_V     EQU 4
    NUM_CUADRICULA_N_FILAS  EQU 2
    NUM_CUADRICULA_N_COLS   EQU 5
    NUM_CAJA_CLIC_ANCHO   EQU 2 * PIXELES_POR_CARACTER
    NUM_CAJA_CLIC_ALTO   EQU 2 * PIXELES_POR_CARACTER
    NUM_CUADRICULA_X_INICIO  DW NUM_CUADRICULA_C_COL * PIXELES_POR_CARACTER
    NUM_CUADRICULA_Y_INICIO  DW NUM_CUADRICULA_C_FILA * PIXELES_POR_CARACTER
    NUM_ANCHO_CELDA   EQU NUM_CUADRICULA_ESP_H * PIXELES_POR_CARACTER
    NUM_ALTO_CELDA    EQU NUM_CUADRICULA_ESP_V * PIXELES_POR_CARACTER
    
    BTN_RENDIRSE_X DW 15 * PIXELES_POR_CARACTER
    BTN_RENDIRSE_Y DW 24 * PIXELES_POR_CARACTER
    BTN_RENDIRSE_W DW 12 * PIXELES_POR_CARACTER
    BTN_RESET_X    DW 35 * PIXELES_POR_CARACTER
    BTN_RESET_Y    DW 24 * PIXELES_POR_CARACTER
    BTN_RESET_W    DW 9 * PIXELES_POR_CARACTER
    BTN_QUIT_X     DW 55 * PIXELES_POR_CARACTER
    BTN_QUIT_Y     DW 24 * PIXELES_POR_CARACTER
    BTN_QUIT_W     DW 8 * PIXELES_POR_CARACTER
    BTN_ALTO       DW 1 * PIXELES_POR_CARACTER

    mouse_estaba_presionado    db 0
    click_valido      db 0
    elemento_seleccionado db ?
    mouse_x           dw ?
    mouse_y           dw ?
    resultado_clic_menu db 0 
    
DATOS ENDS

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

CODIGO SEGMENT
    ASSUME DS:DATOS, CS:CODIGO, SS:PILA

;_________________________________________________________; 

INICIO PROC FAR
    MOV AX, DATOS
    MOV DS, AX
    MOV ES, AX
    
Bucle_Principal_Juego:
    MOV [estado_j1], 1
    MOV [estado_j2], 1
    MOV [jugador_actual], 1
    MOV [puntaje1], 0
    MOV [puntaje2], 0

    CALL Configuracion_Inicial_Jugadores
    CALL Configurar_Ajustes_Juego
        
Ronda_Juego:
    CALL Dibujar_HUD
    CALL Mostrar_Contador
    
    CMP tipo_juego, 1
    JE Jugar_Colores_Principal
    CMP tipo_juego, 2
    JE Jugar_Emojis_Principal
    CMP tipo_juego, 3
    JE Jugar_Numeros_Principal
    JMP fin_del_juego
Jugar_Colores_Principal:
    CALL Jugar_Secuencia_Colores
    JMP Post_Secuencia
Jugar_Emojis_Principal:
    CALL Jugar_Secuencia_Emojis
    JMP Post_Secuencia
Jugar_Numeros_Principal:
    CALL Mostrar_Secuencia_Numeros
Post_Secuencia:
    CALL Dibujar_HUD
    CMP tipo_juego, 1
    JE  Dibuja_Paleta_Colores
    CMP tipo_juego, 2
    JE  Dibuja_Paleta_Emojis
    CMP tipo_juego, 3
    JE  Dibuja_Paleta_Numeros
    JMP Dibujar_Botones
Dibuja_Paleta_Colores:
    CALL Dibujar_Paleta_Colores
    JMP Dibujar_Botones
Dibuja_Paleta_Emojis:
    CALL Dibujar_Paleta_Emojis
    JMP Dibujar_Botones
Dibuja_Paleta_Numeros:
    CALL Dibujar_Paleta_Numeros
Dibujar_Botones:
    CALL Dibujar_Botones_Menu
    
    CALL Esperar_Input_Jugador_Loop
        
    LEA SI, Longitud_Facil_Emoji
    LEA DI, buffer_secuencia_jugador
    MOV CL, [longitud_secuencia_actual]
    MOV CH, 0
    JCXZ ronda_ganada

    Verificar_Bucle_Enlinea:
        MOV AL, [SI]
        MOV BL, [DI]
        CMP AL, BL
        JNE Ronda_Perdida
        INC SI
        INC DI
        LOOP Verificar_Bucle_Enlinea
        JMP ronda_ganada
        
;___Logica de ronda perdida que maneja ambos modos de juego___
Ronda_Perdida:
    GOTOXY 28, 12
    LEA DX, msg_fallo
    MOV AH, 09h
    INT 21h
    
    ;___da el feedback de las secuencias___
    GOTOXY 0, 21
    PRINT "Simon Dice: "
    LEA SI, Longitud_Facil_Emoji
    MOV CL, [longitud_secuencia_actual]
    MOV CH, 0
    CALL Imprimir_Buffer
        
    GOTOXY 0, 22
    PRINT "Tu Dijiste: "
    LEA SI, buffer_secuencia_jugador
    MOV CL, [contador_entrada_jugador]
    MOV CH, 0
    CALL Imprimir_Buffer
    
    ;___Comprueba el modo de juego para decidir que hacer___
    CMP [modo_juego], 1
    JE Modo_Tiempo_Perdida      ;Si es 1, es por tiempo

;___Para modo por vidas___
modo_oportunidades_perdida:
    CMP [jugador_actual], 1
    JE restar_oportunidad_j1
    
restar_oportunidad_j2:
    DEC [oportunidades_j2]      ;Resta una vida al J2
    CALL Dibujar_HUD            ;Actualiza el HUD
    CMP [oportunidades_j2], 0
    JNE cambiar_de_turno        ;Si aún tiene vidas, solo cambia el turno
    MOV [estado_j2], 0          ;Si no, queda fuera de juego
    JMP chequear_fin_partida    ;Y revisa si la partida terminó

restar_oportunidad_j1:
    DEC [oportunidades_j1]      ; Resta una vida al J1
    CALL Dibujar_HUD            ; Actualiza el HUD para mostrar el nuevo total de vidas
    CMP [oportunidades_j1], 0
    JNE cambiar_de_turno        ; Si aún tiene vidas, solo cambia el turno
    
    ; Si el jugador se quedó sin vidas:
    MOV [estado_j1], 0
    CMP [cantidad_jugadores], 1
    JE fin_de_partida_individual ; Es 1 jugador, vamos a la pantalla de fin de juego
    JMP chequear_fin_partida     ; Es 2 jugadores, revisamos quién ganó
    
Modo_Tiempo_Perdida:
    CMP [cantidad_jugadores], 1
    JE fin_juego_individual

    CMP [jugador_actual], 1
    JE marcar_j1_fuera_directo

marcar_j2_fuera_directo:
    MOV [estado_j2], 0
    JMP chequear_fin_partida

marcar_j1_fuera_directo:
    MOV [estado_j1], 0

chequear_fin_partida:
    CMP [estado_j1], 1
    JE p1_sigue_activo
    ;Si llegamos aquí, J1 está fuera.
    CMP [estado_j2], 1
    JNE declarar_ganador ;Ambos están fuera (empate)
    ;J1 está fuera, pero J2 sigue activo, por lo tanto, J2 gana.
    GOTOXY 28, 13
    LEA DX, msg_j2_gana
    JMP mostrar_ganador

p1_sigue_activo:
    ;J1 está activo, verificamos a J2.
    CMP [estado_j2], 1
    JE cambiar_de_turno ;Ambos siguen activos, solo cambiamos de turno.
    ;J1 está activo, pero J2 está fuera, por lo tanto, J1 gana.
    GOTOXY 28, 13
    LEA DX, msg_j1_gana
    JMP mostrar_ganador

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
    CMP [cantidad_jugadores], 2
    JNE Ronda_Juego

    CMP [jugador_actual], 1
    JE chequear_estado_j2

chequear_estado_j1:
    CMP [estado_j1], 1
    JNE Ronda_Juego 
    MOV [jugador_actual], 1
    JMP Ronda_Juego

chequear_estado_j2:
    CMP [estado_j2], 1
    JNE Ronda_Juego 
    MOV [jugador_actual], 2
    JMP Ronda_Juego

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

fin_de_partida_individual:
    GOTOXY 28, 12
    LEA DX, msg_fallo
    MOV AH, 09h
    INT 21h ;Muestra el mensaje "¡Fallaste!"
    
    CALL Dibujar_Botones_Menu    ;Dibuja los botones [Rendirse] [Reset] [Quit]
    CALL Manejar_Opciones_Fin_Juego ;Espera a que el usuario haga clic en una opción
    JMP fin_del_juego           
           
jugador_se_rinde:
    CMP [cantidad_jugadores], 1
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
    CALL Iniciar_Mouse
    mov mouse_estaba_presionado, 0   
    
Bucle_Fin_Juego:
    mov ax, 3
    int 33h
    mov [mouse_x], cx
    mov [mouse_y], dx
    cmp bx, 1
    jne Lanzar_Boton_Fin_Juego
    cmp mouse_estaba_presionado, 1
    je Bucle_Fin_Juego
    mov mouse_estaba_presionado, 1
    call Verificar_Clic_Menu
    mov al, [resultado_clic_menu]
    cmp al, 2
    jne Verificar_Salir_Fin_Juego
    call Apagar_Mouse
    mov ah, 06h
    mov al, 00h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    GOTOXY 0, 0
    jmp Bucle_Principal_Juego

Verificar_Salir_Fin_Juego:
    cmp al, 3
    jne Bucle_Fin_Juego
    jmp fin_del_juego  
    
Lanzar_Boton_Fin_Juego:
    mov mouse_estaba_presionado, 0
    jmp Bucle_Fin_Juego
    RET
Manejar_Opciones_Fin_Juego ENDP

;_________________________________________________________;           
          
;___Procedimiento para darle el feedback___
Esperar_Input_Jugador_Loop PROC NEAR
    CALL Iniciar_Mouse
    CALL Determinar_Longitud_Secuencia
    mov [contador_entrada_jugador], 0
    
    GOTOXY 1, 20
    LEA DX, msg_feedback
    MOV AH, 09h
    INT 21h
    
Bucle_Entrada_Mouse:
    mov ax, 3
    int 33h
    mov [mouse_x], cx
    mov [mouse_y], dx
    
    cmp bx, 1
    jne Lanzar_Boton_Principal
    
    cmp mouse_estaba_presionado, 1
    je Bucle_Entrada_Mouse
    mov mouse_estaba_presionado, 1
    
    call Verificar_Clic_Menu
    cmp [resultado_clic_menu], 0
    jne Manejar_Clic_Menu

    mov al, [tipo_juego]
    cmp al, 1
    je check_colores
    cmp al, 2
    je check_emojis
    cmp al, 3
    je check_numeros
    jmp Bucle_Entrada_Mouse

check_colores:
    call Verificar_Clic_Colores
    jmp procesar_clic_valido
check_emojis:
    call Verificar_Clic_Emojis
    jmp procesar_clic_valido
check_numeros:
    call Verificar_Clic_Numeros

procesar_clic_valido:
    cmp [click_valido], 0
    je Bucle_Entrada_Mouse

    mov al, [contador_entrada_jugador]
    mov ah, 0
    mov si, ax
    
    mov al, [elemento_seleccionado]
    mov [buffer_secuencia_jugador + si], al

    GOTOXY 19, 20
    mov al, [elemento_seleccionado]
    mov ah, 0
    CALL PRINT_NUM_UNS
    PRINT " "
    
    inc [contador_entrada_jugador]
    mov al, [contador_entrada_jugador]
    cmp al, [longitud_secuencia_actual]
    je Secuencia_Completa
    
    jmp Bucle_Entrada_Mouse

Manejar_Clic_Menu:
    mov al, [resultado_clic_menu]
    cmp al, 1
    jne Verificar_Reset
    jmp jugador_se_rinde

Verificar_Reset:
    cmp al, 2
    jne Verificar_Quit
    call Apagar_Mouse
    mov ah, 06h
    mov al, 00h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    GOTOXY 0, 0
    jmp Bucle_Principal_Juego

Verificar_Quit:
    cmp al, 3
    jne fin_manejo_clicks
    jmp fin_del_juego

fin_manejo_clicks:
    jmp Secuencia_Completa

Lanzar_Boton_Principal:
    mov mouse_estaba_presionado, 0
    jmp Bucle_Entrada_Mouse

Secuencia_Completa:
    GOTOXY 1, 20
    PRINT "                                  "
    call Apagar_Mouse
    RET
Esperar_Input_Jugador_Loop ENDP

;_________________________________________________________; 

;___HUD___
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
    Linea_Superior_HUD:
        PUTC '_'
    LOOP Linea_Superior_HUD
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
    Linea_Inferior_HUD:
        PUTC '_'
    LOOP Linea_Inferior_HUD
    
    GOTOXY 2, 1
    PRINT "Jugador: "
    GOTOXY 2, 2
    PRINT "Puntaje: "

    ;___Para mostrar datos de J1 o J2___
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

;___HUD que muestra los datos según vidas o tiempo___
hud_modo_juego:
    CMP [modo_juego], 1
    JE hud_mostrar_tiempo

hud_mostrar_oportunidades:
    GOTOXY 2, 3
    PRINT "Vidas:   " ;Imprime vidas y espacios para limpiar "tiempo"
    GOTOXY 13, 3
    CMP [jugador_actual], 1
    JE hud_vidas_j1
    MOV AL, [oportunidades_j2]
    JMP hud_print_vidas 
    
hud_vidas_j1:
    MOV AL, [oportunidades_j1] 
    
hud_print_vidas:
    MOV AH, 0  ;Limpia AH para que PRINT_NUM funcione con el valor de AL
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
   
;_________________________________________________________; 
   
Determinar_Longitud_Secuencia PROC NEAR
    mov al, [tipo_juego]
    cmp al, 1
    je Establecer_Long_Col
    cmp al, 2
    je establecer_long_emo
    cmp al, 3
    je establecer_long_num
    ret         
    
Establecer_Long_Col:
    mov al, [dificultad]
    cmp al, 1
    je Establecer_Long_Col_e
    cmp al, 2
    je Establecer_Long_Col_m
    mov bl, LONGITUD_SEC_COLOR_DIFICIL
    jmp establecer_longitud_fin
    Establecer_Long_Col_m:
    mov bl, LONGITUD_SEC_COLOR_MEDIO
    jmp establecer_longitud_fin
    Establecer_Long_Col_e:
    mov bl, LONGITUD_SEC_COLOR_FACIL
    jmp establecer_longitud_fin  
    
establecer_long_emo:
    mov al, [dificultad]
    cmp al, 1
    je establecer_long_emo_e
    cmp al, 2
    je establecer_long_emo_m
    mov bl, LONGITUD_SEC_EMOJI_DIFICIL
    jmp establecer_longitud_fin
    establecer_long_emo_m:
    mov bl, LONGITUD_SEC_EMOJI_MEDIO
    jmp establecer_longitud_fin
    establecer_long_emo_e:
    mov bl, LONGITUD_SEC_EMOJI_FACIL
    jmp establecer_longitud_fin 
    
establecer_long_num:
    mov al, [dificultad]
    cmp al, 1
    je establecer_long_num_e
    cmp al, 2
    je establecer_long_num_m
    mov bl, LONGITUD_SEC_NUMERO_DIFICIL
    jmp establecer_longitud_fin
    establecer_long_num_m:
    mov bl, LONGITUD_SEC_NUMERO_MEDIO
    jmp establecer_longitud_fin
    establecer_long_num_e:
    mov bl, LONGITUD_SEC_NUMERO_FACIL 
    
establecer_longitud_fin:
    mov [longitud_secuencia_actual], bl
    ret
Determinar_Longitud_Secuencia ENDP
                     
;_________________________________________________________; 
                     
Iniciar_Mouse PROC NEAR
    mov ax, 0
    int 33h
    mov ax, 1
    int 33h
    ret
Iniciar_Mouse ENDP
        
;_________________________________________________________;
        
Apagar_Mouse PROC NEAR
    mov ax, 2
    int 33h
    ret
Apagar_Mouse ENDP
      
;_________________________________________________________;  
      
Verificar_Clic_Colores PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, COL_CUADRICULA_Y_INICIO
    jl salir_sin_exito_mouse
    mov ax, COL_CUADRICULA_Y_INICIO
    add ax, (COL_CUADRICULA_N_FILAS * COL_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, COL_CUADRICULA_X_INICIO
    jl salir_sin_exito_mouse
    mov ax, COL_CUADRICULA_X_INICIO
    add ax, (COL_CUADRICULA_N_COLS * COL_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, COL_CUADRICULA_X_INICIO
    xor dx, dx
    mov bx, COL_ANCHO_CELDA
    div bx
    cmp dx, COL_CAJA_CLIC_ANCHO
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, COL_CUADRICULA_Y_INICIO
    xor dx, dx
    mov bx, COL_ALTO_CELDA
    div bx
    cmp dx, COL_CAJA_CLIC_ALTO
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, COL_CUADRICULA_N_COLS
    mul bl
    add al, ch
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret      
    
salir_sin_exito_mouse:
    mov [click_valido], 0
    ret
Verificar_Clic_Colores ENDP
                            
;_________________________________________________________; 
                            
Verificar_Clic_Emojis PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, EMOJI_CUADRICULA_Y_INICIO
    jl salir_sin_exito_mouse
    mov ax, EMOJI_CUADRICULA_Y_INICIO
    add ax, (EMOJI_CUADRICULA_N_FILAS * EMOJI_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, EMOJI_CUADRICULA_X_INICIO
    jl salir_sin_exito_mouse
    mov ax, EMOJI_CUADRICULA_X_INICIO
    add ax, (EMOJI_CUADRICULA_N_COLS * EMOJI_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, EMOJI_CUADRICULA_X_INICIO
    xor dx, dx
    mov bx, EMOJI_ANCHO_CELDA
    div bx
    cmp dx, EMOJI_CAJA_CLIC_ANCHO
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, EMOJI_CUADRICULA_Y_INICIO
    xor dx, dx
    mov bx, EMOJI_ALTO_CELDA
    div bx
    cmp dx, EMOJI_CAJA_CLIC_ALTO
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, EMOJI_CUADRICULA_N_COLS
    mul bl
    add al, ch
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret
Verificar_Clic_Emojis ENDP
                         
;_________________________________________________________; 
                         
Verificar_Clic_Numeros PROC NEAR
    mov cx, [mouse_x]
    mov dx, [mouse_y]
    cmp dx, NUM_CUADRICULA_Y_INICIO
    jl salir_sin_exito_mouse
    mov ax, NUM_CUADRICULA_Y_INICIO
    add ax, (NUM_CUADRICULA_N_FILAS * NUM_ALTO_CELDA)
    cmp dx, ax
    jge salir_sin_exito_mouse
    cmp cx, NUM_CUADRICULA_X_INICIO
    jl salir_sin_exito_mouse
    mov ax, NUM_CUADRICULA_X_INICIO
    add ax, (NUM_CUADRICULA_N_COLS * NUM_ANCHO_CELDA)
    cmp cx, ax
    jge salir_sin_exito_mouse
    mov ax, cx
    sub ax, NUM_CUADRICULA_X_INICIO
    xor dx, dx
    mov bx, NUM_ANCHO_CELDA
    div bx
    cmp dx, NUM_CAJA_CLIC_ANCHO
    jge salir_sin_exito_mouse
    mov ch, al
    mov ax, [mouse_y]
    sub ax, NUM_CUADRICULA_Y_INICIO
    xor dx, dx
    mov bx, NUM_ALTO_CELDA
    div bx
    cmp dx, NUM_CAJA_CLIC_ALTO
    jge salir_sin_exito_mouse
    mov cl, al
    mov al, cl
    mov bl, NUM_CUADRICULA_N_COLS
    mul bl
    add al, ch
    cmp al, 10
    jge salir_sin_exito_mouse
    mov [elemento_seleccionado], al
    mov [click_valido], 1
    ret
Verificar_Clic_Numeros ENDP
                    
;_________________________________________________________; 
                    
Verificar_Clic_Menu PROC NEAR
    mov [resultado_clic_menu], 0
    mov cx, mouse_x
    mov dx, mouse_y
    cmp dx, BTN_RENDIRSE_Y
    jl no_menu_click
    mov ax, BTN_RENDIRSE_Y
    add ax, BTN_ALTO
    cmp dx, ax
    jg Verificar_Reset_btn
    cmp cx, BTN_RENDIRSE_X
    jl Verificar_Reset_btn
    mov ax, BTN_RENDIRSE_X
    add ax, BTN_RENDIRSE_W
    cmp cx, ax
    jg Verificar_Reset_btn
    mov [resultado_clic_menu], 1
    ret      
    
Verificar_Reset_btn:
    cmp dx, BTN_RESET_Y
    jl no_menu_click
    mov ax, BTN_RESET_Y
    add ax, BTN_ALTO
    cmp dx, ax
    jg Verificar_Quit_btn
    cmp cx, BTN_RESET_X
    jl Verificar_Quit_btn
    mov ax, BTN_RESET_X
    add ax, BTN_RESET_W
    cmp cx, ax
    jg Verificar_Quit_btn
    mov [resultado_clic_menu], 2
    ret      
    
Verificar_Quit_btn:
    cmp dx, BTN_QUIT_Y
    jl no_menu_click
    mov ax, BTN_QUIT_Y
    add ax, BTN_ALTO
    cmp dx, ax
    jg no_menu_click
    cmp cx, BTN_QUIT_X
    jl no_menu_click
    mov ax, BTN_QUIT_X
    add ax, BTN_QUIT_W
    cmp cx, ax
    jg no_menu_click
    mov [resultado_clic_menu], 3
    ret  
    
no_menu_click:
    ret
Verificar_Clic_Menu ENDP
                        
;_________________________________________________________;  
                        
Jugar_Secuencia_Colores PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV AH, 2Ch
    INT 21h
    MOV [semilla_prng], DX
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    LEA DI, Longitud_Facil_Emoji
    MOV CH, 0
    CMP dificultad, 1
    JE  Longitud_Facil_Color_G
    CMP dificultad, 2
    JE  Longitud_Media_Color_G  
    
Longitud_Dificil_Color_G:
    MOV CL, LONGITUD_SEC_COLOR_DIFICIL
    JMP Iniciar_Bucle_Color_G      
    
Longitud_Media_Color_G:
    MOV CL, LONGITUD_SEC_COLOR_MEDIO
    JMP Iniciar_Bucle_Color_G       
    
Longitud_Facil_Color_G:
    MOV CL, LONGITUD_SEC_COLOR_FACIL  
    
Iniciar_Bucle_Color_G:
Bucle_Secuencia_Color:
    PUSH CX
    MOV AX, [semilla_prng]
    MOV BX, 12345
    MUL BX
    ADD AX, 54321
    MOV [semilla_prng], AX
    MOV DX, 0
    MOV BX, TAMANO_PALETA_COLOR
    DIV BX
    MOV [DI], DL
    INC DI
    LEA SI, paleta_colores
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
    MOV CX, [retardos_tiempo_h + BX]
    MOV DX, [retardos_tiempo_l + BX]
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
    LOOP Bucle_Secuencia_Color
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Jugar_Secuencia_Colores ENDP
               
;_________________________________________________________; 
               
Jugar_Secuencia_Emojis PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA DI, Longitud_Facil_Emoji
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
    JE  Longitud_Media_Emoji  
    
Longitud_Dificil_Emoji:
    MOV CX, LONGITUD_SEC_EMOJI_DIFICIL
    JMP Iniciar_Bucle_Emoji 
    
Longitud_Media_Emoji:
    MOV CX, LONGITUD_SEC_EMOJI_MEDIO
    JMP Iniciar_Bucle_Emoji 
    
easy_len_emoji:
    MOV CX, LONGITUD_SEC_EMOJI_FACIL   
    
Iniciar_Bucle_Emoji:
Bucle_Secuencia_Emoji:
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
    LEA SI, punteros_emojis
    ADD SI, BX
    MOV SI, [SI]
    MOV DL, 38
    MOV DH, 12
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    CALL Imprimir_Emoji
    MOV AL, dificultad
    DEC AL
    MOV AH, 0
    SHL AX, 1
    MOV BX, AX
    MOV CX, [retardos_tiempo_h + BX]
    MOV DX, [retardos_tiempo_l + BX]
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
    LOOP Bucle_Secuencia_Emoji
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Jugar_Secuencia_Emojis ENDP
     
;_________________________________________________________; 
     
Mostrar_Secuencia_Numeros PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA DI, Longitud_Facil_Emoji
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
    JE  Longitud_Facil_Num
    CMP dificultad, 2
    JE  Longitud_Media_Num  
    
Longitud_Dificil_Num:
    MOV CX, LONGITUD_SEC_NUMERO_DIFICIL
    JMP Iniciar_Bucle_Num   
    
Longitud_Media_Num:
    MOV CX, LONGITUD_SEC_NUMERO_MEDIO
    JMP Iniciar_Bucle_Num    
    
Longitud_Facil_Num:
    MOV CX, LONGITUD_SEC_NUMERO_FACIL
    
Iniciar_Bucle_Num:
Bucle_Secuencia_Num:
    PUSH CX
    MOV AH, 2Ch
    INT 21h
    MOV AL, DL
    MOV AH, 0
    MOV BL, CANTIDAD_NUMEROS
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
    MOV CX, [retardos_tiempo_h + BX]
    MOV DX, [retardos_tiempo_l + BX]
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
    LOOP Bucle_Secuencia_Num
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Mostrar_Secuencia_Numeros ENDP
                 
;_________________________________________________________;                  
                 
Imprimir_Emoji PROC NEAR
    PUSH AX
    PUSH SI  
    
Imprimir_Caracter_Emoji:
    MOV AL, [SI]
    CMP AL, 0
    JE  Fin_Imprimir_Emoji
    MOV AH, 0Eh
    INT 10h
    INC SI
    JMP Imprimir_Caracter_Emoji  
    
Fin_Imprimir_Emoji:
    POP SI
    POP AX
    RET
Imprimir_Emoji ENDP
                  
;_________________________________________________________;                   
                  
Configuracion_Inicial_Jugadores PROC NEAR
    PRINTN "BIENVENIDO A SIMON DICE"
    PRINTN "______________________________"   
    
Preguntar_Jugadores:
    PRINT "Cantidad de jugadores (1 o 2): "
    MOV AH, 01h
    INT 21h
    CMP AL, '1'
    JE Un_Jugador
    CMP AL, '2'
    JE Dos_Jugadores
    PRINTN ""
    PRINTN "Entrada no valida. Por favor, ingrese 1 o 2:"
    JMP Preguntar_Jugadores  
    
Un_Jugador:
    MOV cantidad_jugadores, 1
    PRINTN ""
    PRINT "Jugador 1 - Nickname (3-10 caracteres): "
    LEA DI, nickname1
    CALL Read_Nickname
    JMP Mostrar_Nicknames  
    
Dos_Jugadores:
    MOV cantidad_jugadores, 2
    PRINTN ""
    PRINT "Jugador 1 - Nickname (3-10 caracteres): "
    LEA DI, nickname1
    CALL Read_Nickname
    PRINTN ""
    PRINT "Jugador 2 - Nickname (3-10 caracteres): "
    LEA DI, nickname2
    CALL Read_Nickname   
    
Mostrar_Nicknames:
    PRINTN ""
    PRINTN "--- Nicknames Registrados ---"
    PRINT "Jugador 1: "
    MOV DX, OFFSET nickname1
    CALL Print_Nickname
    CMP cantidad_jugadores, 2
    JNE Configuracion_Lista
    PRINT "Jugador 2: "
    MOV DX, OFFSET nickname2
    CALL Print_Nickname 
    
Configuracion_Lista:
    PRINTN "______________________________"
    PRINTN ""
    RET       
    
Configuracion_Inicial_Jugadores ENDP
            
;_________________________________________________________;             
            
Read_Nickname PROC NEAR
    PUSH AX
    PUSH CX
    PUSH BX
    MOV CX, 10
    XOR BX, BX 
    
leer_bucle:
    MOV AH, 00h
    INT 16h
    CMP AL, 0Dh
    JE Verificar_Longitud
    CMP AL, 08h
    JE Retroceder
    CMP BL, 10
    JAE leer_bucle
    MOV AH, 0Eh
    INT 10h
    MOV [DI + BX], AL
    INC BX
    JMP leer_bucle  
    
Retroceder:
    CMP BX, 0
    JE leer_bucle
    DEC BX
    PUTC 08h
    PUTC ' '
    PUTC 08h
    JMP leer_bucle
    
Verificar_Longitud:
    CMP BX, 3
    JB Demasiado_Corto
    MOV BYTE PTR [DI + BX], '$'
    POP BX
    POP CX
    POP AX
    RET     
    
Demasiado_Corto:
    PRINTN ""
    PRINT "El nickname debe tener entre 3 y 10 caracteres. Intente de nuevo: "
    MOV CX, BX    
    
    Limpiar_Bucle:
        PUTC 08h
        PUTC ' '
        PUTC 08h
    LOOP Limpiar_Bucle
    XOR BX, BX
    JMP leer_bucle
Read_Nickname ENDP
                   
;_________________________________________________________;                    
                   
Print_Nickname PROC NEAR
    PUSH AX
    MOV AH, 09h
    INT 21h
    PRINTN ""
    POP AX
    RET
Print_Nickname ENDP
          
;_________________________________________________________;           
          
Configurar_Ajustes_Juego PROC NEAR
Preguntar_Tipo:
    PRINT "Seleccione el tipo de secuencia (1=Colores, 2=Emojis, 3=Numeros): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL Tipo_Invalido
    CMP AL, 3
    JG Tipo_Invalido
    MOV tipo_juego, AL
    JMP Preguntar_Dificultad        
    
Tipo_Invalido:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP Preguntar_Tipo

Preguntar_Dificultad:
    PRINTN ""
    PRINT "Seleccione la dificultad (1=Facil, 2=Intermedio, 3=Dificil): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL Dificultad_Invalida
    CMP AL, 3
    JG Dificultad_Invalida
    MOV dificultad, AL
    JMP Preguntar_Modo  

Dificultad_Invalida:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP Preguntar_Dificultad

;___Preguntar por el modo de juego___
Preguntar_Modo:
    PRINTN ""
    PRINT "Seleccione el modo (1=Por Tiempo, 2=Por Oportunidades): "
    MOV AH, 01h
    INT 21h
    PUTC ' '
    SUB AL, '0'
    CMP AL, 1
    JL Respuesta_Modo_Invalida
    CMP AL, 2
    JG Respuesta_Modo_Invalida
    MOV [modo_juego], AL
    JMP Configuracion_Completada

Respuesta_Modo_Invalida:
    PRINTN ""
    PRINTN "Opcion invalida."
    JMP Preguntar_Modo
    
Configuracion_Completada:
    CMP [modo_juego], 1
    JE Iniciar_Tiempo
    ;se llama a la rutina de oportunidades 
    CALL Actualizar_Oportunidades_Iniciales
    JMP fin_config
    
Iniciar_Tiempo:
    CALL Actualizar_Tiempo_Inicial

fin_config:
    PRINTN ""
    PRINTN "--- Configuracion guardada. Preparando el juego... ---"
    RET
Configurar_Ajustes_Juego ENDP    
                
;_________________________________________________________;                 
                
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
        
;_________________________________________________________;         
                      
;___Para establecer las oportunidades iniciales___
Actualizar_Oportunidades_Iniciales PROC NEAR
    PUSH AX
    PUSH BX
    
    MOV AL, [dificultad]
    DEC AL  ; Ajusta el índice (1,2,3 -> 0,1,2)
    MOV AH, 0
    MOV BX, AX
    
    MOV AL, [oportunidades_iniciales + BX]  ;Carga el número de oportunidades desde la tabla
    
    MOV [oportunidades_j1], AL  ;Asigna las oportunidades a ambos jugadores
    MOV [oportunidades_j2], AL
    
    POP BX
    POP AX
    RET
Actualizar_Oportunidades_Iniciales ENDP                      
    
;_________________________________________________________; 
    
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
   
;_________________________________________________________;    
   
Dibujar_Paleta_Colores PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV SI, 0
    MOV DH, 8 
    
Dibujar_Fila:
    MOV DI, 0
    MOV DL, 20  
    
Dibujar_Columna:
    MOV AH, 02h
    MOV BH, 0
    INT 10h
    CALL Dibujar_Recuadro_Color
    INC SI
    ADD DL, 5
    INC DI
    CMP DI, 5
    JNE Dibujar_Columna
    ADD DH, 4
    CMP DH, 20
    JNE Dibujar_Fila
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Dibujar_Paleta_Colores ENDP
              
;_________________________________________________________;               
              
Dibujar_Recuadro_Color PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, SI
    MOV AL, [paleta_caracteres + BX]
    MOV BL, [paleta_colores + BX]
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
                  
;_________________________________________________________; 
                  
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
    MOV DI, [punteros_emojis + BX]
    PUSH DI
    POP SI          
    CALL Imprimir_Emoji
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
            
;_________________________________________________________; 
            
Dibujar_Paleta_Numeros PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    MOV CX, 10      
    MOV SI, 0   
        
bucle_numero_cuadricula:
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
    MOV AL, [caracteres_numericos + BX]
    PUTC AL
    INC SI
    POP CX
    LOOP bucle_numero_cuadricula
    POP SI
    POP CX
    POP BX
    POP AX
    RET
Dibujar_Paleta_Numeros ENDP
                            
;_________________________________________________________;                             
                            
Dibujar_Botones_Menu PROC NEAR
    GOTOXY 15, 24
    PRINT "[ Rendirse ]"
    GOTOXY 35, 24
    PRINT "[ Reset ]"
    GOTOXY 55, 24
    PRINT "[ Quit ]"
    RET
Dibujar_Botones_Menu ENDP
              
;_________________________________________________________;               
              
Imprimir_Buffer PROC NEAR
    PUSH AX
    PUSH CX
    PUSH SI   
    
Imprimir_Buffer_loop:
    MOV AL, [SI]
    MOV AH, 0
    CALL PRINT_NUM_UNS
    PUTC ' '
    INC SI
    LOOP Imprimir_Buffer_loop
    POP SI
    POP CX
    POP AX
    RET
Imprimir_Buffer ENDP
        
;_________________________________________________________;         
        
CODIGO ENDS

DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

END INICIO