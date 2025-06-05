TITLE PROYECTO

DATOS SEGMENT

    ;Variables :                                                       
    player_count  db 0   
    nickname1  db 11 dup('$')
    nickname2  db 11 dup('$')   
                
    tipo_juego db 0 ;1=colores, 2=emojis, 3=numeros
    dificultad db 0 ;1=fácil, 2=media, 3=difícil
    modo_juego db 0 ;1=tiempo, 2=intentos

    sequence        db 32 dup(0)  ; Secuencia generada
    sequence_len    db 0         ; Longitud de la secuencia
    secuencia_input db 32 dup(0) ; Secuencia ingresada por el jugador

    ;Mensajes :
    msg_welcome     db "BIENVENIDO A SIMON DICE", 0
    msg_askplayers  db "Cantidad de jugadores (1 o 2): ", 0
    msg_nick1       db "Jugador 1 - Nickname (3-10): ", 0
    msg_nick2       db "Jugador 2 - Nickname (3-10): ", 0
    msg_invalid     db "Entrada no valida", 0
    msg_confirm     db "Nicknames registrados:", 0
    msg_tiposeq     db "Tipo de secuencia: 1=Colores 2=Emojis 3=Numeros: ", 0
    msg_dificultad  db "Dificultad: 1=Facil 2=Media 3=Dificil: ", 0
    msg_modo        db "Modo de juego: 1=Tiempo 2=Intentos: ", 0
    msg_config_ok   db "Configuracion completada.", 0
    msg_mostrando   db "Mostrando secuencia:", 0
    msg_ingrese     db "Repite la secuencia: ", 0
    msg_correcto    db "Correcto!", 0
    msg_error       db "Incorrecto!", 0
    crlf db 0Dh,0Ah,0  ;Cadena para nueva línea

DATOS ENDS   
      
PILA SEGMENT 
          
    DB 64 DUP (0)   
 
PILA ENDS    


CODIGO SEGMENT  

INICIO PROC FAR  

    ASSUME DS: DATOS, CS:CODIGO, SS:PILA
    PUSH DS
    MOV  AX,0
    PUSH AX

    MOV  AX, DATOS
    MOV  DS, AX
    MOV  ES, AX ;Necesario para STOSB/MOVSB con DI apuntando a ES

    ;Bienvenida
    mov  dx, offset msg_welcome
    call print_str
    call newline

.ask_players:
    mov  dx, offset msg_askplayers
    call print_str
    call read_char_wait
    call print_char
    cmp  al,"1"
    je .one_player
    cmp  al,"2"
    je .two_players

    mov  dx, offset msg_invalid
    call print_str
    jmp .ask_players

.one_player:
    mov  player_count,1
    mov  dx, offset crlf
    call print_str
    mov  dx, offset msg_nick1
    call print_str
    mov  di, offset nickname1
    call read_nickname 
    call newline
    jmp .show_nicks

.two_players:
    mov  player_count,2
    mov  dx, offset crlf
    call print_str
    mov  dx, offset msg_nick1
    call print_str
    mov  di, offset nickname1
    call read_nickname  

    mov  dx, offset crlf
    call print_str
    mov  dx, offset msg_nick2
    call print_str
    mov  di, offset nickname2
    call read_nickname 
    call newline

.show_nicks:
    mov dx, offset msg_confirm
    call print_str

    mov  dx, offset nickname1
    call print_str_terminated
    mov  dx, offset crlf
    call print_str

    cmp  player_count,2
    jne .config

    mov  dx, offset nickname2
    call print_str_terminated
    mov  dx, offset crlf
    call print_str

.config:
    call configuracion_juego
    call generar_y_mostrar_secuencia
    call leer_y_verificar_secuencia

.exit:
    mov ah, 4Ch
    int 21h

INICIO ENDP
 
 
;SUBRUTINAS:
print_str PROC NEAR
    push ax
    push si
    mov  si,dx
.next_char:
    lodsb
    or   al, al
    jz .done_print      
    mov  ah, 0Eh
    int  10h
    jmp .next_char
.done_print:
    pop  si
    pop  ax
    ret
print_str ENDP

print_str_terminated PROC NEAR
    push ax
    push si
    push cx
    mov  si, dx
    mov  cx, 10
.next_char_term:
    lodsb
    cmp  al, '$'
    je .done_print_term
    mov  ah, 0Eh
    int  10h
    loop .next_char_term
.done_print_term:
    pop  cx
    pop  si
    pop  ax
    ret
print_str_terminated ENDP

set_cursor PROC NEAR
    push ax
    push bx
    mov  ah, 02h
    mov  bh, 0
    int  10h
    pop  bx
    pop  ax
    ret
set_cursor ENDP

read_char_wait PROC NEAR
    mov  ah, 00h
    int  16h
    ret
read_char_wait ENDP

print_char PROC NEAR
    push ax
    mov  ah, 0Eh
    int  10h
    pop  ax
    ret
print_char ENDP

newline PROC NEAR
    push dx
    mov  dx, offset crlf
    call print_str
    pop  dx
    ret
newline ENDP

read_nickname PROC NEAR
    push ax
    push cx
    push si
    mov  si, di
    xor  cx, cx
.read_loop:
    call read_char_wait
    cmp  al, 0Dh
    je .done_read
    cmp  al, 08h
    je .backspace
    cmp  cx, 10
    jae .read_loop
    call print_char
    mov  [si], al
    inc  si
    inc  cx
    jmp  .read_loop
.backspace:
    cmp  cx, 0
    je .read_loop
    dec  si
    dec  cx
    mov  ah, 0Eh
    mov  al, 08h
    int  10h
    mov  al, ' '
    int  10h
    mov  al, 08h
    int  10h
    jmp  .read_loop
.done_read:
    mov  byte ptr [si], '$'
    pop  si
    pop  cx
    pop  ax
    ret
read_nickname ENDP

configuracion_juego PROC NEAR
.ask_tipo:
    mov  dx, offset msg_tiposeq
    call print_str
    call read_char_wait
    call print_char
    call newline
    cmp  al, '1'
    je .tipo_ok
    cmp  al, '2'
    je .tipo_ok
    cmp  al, '3'
    je .tipo_ok
    mov  dx, offset msg_invalid
    call print_str
    jmp .ask_tipo
.tipo_ok:
    sub  al, '0'
    mov  tipo_juego, al
.ask_dif:
    mov dx, offset msg_dificultad
    call print_str
    call read_char_wait
    call print_char
    call newline
    cmp al, '1'
    je .dif_ok
    cmp al, '2'
    je .dif_ok
    cmp al, '3'
    je .dif_ok
    mov dx, offset msg_invalid
    call print_str
    jmp .ask_dif
.dif_ok:
    sub al, '0'
    mov dificultad, al
.ask_modo:
    mov  dx, offset msg_modo
    call print_str
    call read_char_wait
    call print_char
    call newline
    cmp  al, '1'
    je .modo_ok
    cmp  al, '2'
    je .modo_ok
    mov  dx, offset msg_invalid
    call print_str
    jmp .ask_modo
.modo_ok:
    sub  al, '0'
    mov  modo_juego, al
    mov  dx, offset msg_config_ok
    call print_str
    call newline 
    ret
configuracion_juego ENDP

generar_y_mostrar_secuencia PROC NEAR
    mov al, dificultad
    cmp al, 1
    je .dif1
    cmp al, 2
    je .dif2
    mov al, 7
    jmp .set_len
.dif1:
    mov al, 3
    jmp .set_len
.dif2:
    mov al, 5
.set_len:
    mov sequence_len, al
    mov dx, offset msg_mostrando
    call print_str
    call newline
    xor cx, cx
    mov cl, sequence_len
    lea di, sequence
.loop:
    call generar_aleatorio
    mov bl, tipo_juego
    cmp bl, 1
    je .color
    cmp bl, 2
    je .emoji
    cmp bl, 3
    je .numero
.color:
    and al, 0Fh
    add al, 'A'
    jmp .store
.emoji:
    and al, 0Fh
    add al, 'a'
    jmp .store
.numero:
    and al, 09h
    add al, '0'
.store:
    stosb
    call print_char
    call delay_short
    loop .loop
    call newline
    ret

; rutina auxiliar

leer_y_verificar_secuencia PROC NEAR
    call newline
    mov dx, offset msg_ingrese
    call print_str
    call newline
    lea si, sequence
    lea di, secuencia_input
    mov cl, sequence_len
.ingresar:
    call read_char_wait
    call print_char
    mov [di], al
    inc di
    loop .ingresar
    lea si, sequence
    lea di, secuencia_input
    mov cl, sequence_len
    xor bx, bx
.comparar:
    mov al, [si]
    mov ah, [di]
    cmp al, ah
    jne .error
    inc si
    inc di
    inc bx
    loop .comparar
    call newline
    mov dx, offset msg_correcto
    call print_str
    jmp .fin
.error:
    call newline
    mov dx, offset msg_error
    call print_str
.fin:
    ret
leer_y_verificar_secuencia ENDP

generar_aleatorio:
    mov ah, 2Ch
    int 21h
    xor al, dh
    xor al, dl
    ret

delay_short:
    push cx
    mov cx, 0FFFFh
.delay:
    loop .delay
    pop cx
    ret

CODIGO ENDS
END INICIO
