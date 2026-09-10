; ------------------------------------------------------------
; Proyecto Modulo 1 - Visor de Memoria
; Lenguajes de Interfaz (SCC-1014)
;
; Descripcion: Recorre un arreglo de 10 elementos y muestra
; su direccion y valor en hexadecimal.
;
; Nota:
; El codigo base del proyecto dejaba pendiente la salida en consola.
; Para completar esa parte se uso GetStdHandle + WriteFile, siguiendo
; la misma idea mencionada en los comentarios del documento.
; ------------------------------------------------------------

option casemap:none

; Funciones externas necesarias solamente para mostrar la salida
extrn GetStdHandle:proc
extrn WriteFile:proc

.data

; ---- Arreglo de 10 elementos ----
; DQ = 64 bits = 8 bytes por elemento
arreglo DQ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50

; CR + LF + null
newline DB 13, 10, 0

; Buffer temporal para guardar los 16 digitos hexadecimales
buffer DB 32 DUP (0)

; Tabla de conversion a hexadecimal
hex_chars DB '0123456789ABCDEF'

; Textos para formar la salida
texto_direccion DB 'Direccion: ', 0
texto_valor     DB ' Valor: ', 0

.code


; ------------------------------------------------------------
; Funcion: print_hex_qword
; Convierte un QWord de 64 bits a hexadecimal con 16 digitos.
;
; Entrada:
;   RAX = valor a convertir
;   RDI = puntero al buffer donde se escribira
;
; Salida:
;   RDI vuelve al inicio de los 16 caracteres generados.
; ------------------------------------------------------------

print_hex_qword proc

    push rbx
    push rcx
    push rdx

    ; Recorremos 16 digitos hexadecimales
    ; porque 64 bits / 4 bits = 16 digitos
    mov rcx, 16

    ; Empezamos desde el final de las 16 posiciones
    ; porque los digitos se generan de derecha a izquierda
    add rdi, 15

    ; Mascara para quedarnos con los 4 bits bajos
    mov rbx, 0Fh

hex_loop:

    ; Copiamos el valor actual
    mov rdx, rax

    ; Extraemos solamente los 4 bits bajos
    and rdx, rbx

    ; RDX queda entre 0 y 15.
    ; Ese valor sirve como indice dentro de hex_chars.
    movzx rdx, byte ptr [hex_chars + rdx]

    ; Guardamos el caracter obtenido en el buffer
    mov [rdi], dl

    ; Nos movemos una posicion hacia la izquierda
    dec rdi

    ; Desplazamos el numero 4 bits para procesar
    ; el siguiente digito hexadecimal
    shr rax, 4

    loop hex_loop

    ; Despues de las 16 vueltas RDI queda una posicion
    ; antes del inicio, asi que lo regresamos
    add rdi, 1

    pop rdx
    pop rcx
    pop rbx

    ret

print_hex_qword endp


; ------------------------------------------------------------
; Funcion: print_string
; Imprime una cadena terminada en 0.
;
; Entrada:
;   RDI = puntero a la cadena
;
; El codigo original calculaba la longitud, pero dejaba
; pendiente la llamada que realmente escribe en consola.
; Aqui se completo esa parte con GetStdHandle y WriteFile.
; ------------------------------------------------------------

print_string proc

    push rcx
    push rdx
    push r8
    push r9

    ; Reservamos espacio para la convencion de Windows x64,
    ; el quinto parametro de WriteFile y datos temporales.
    sub rsp, 38h

    ; Obtener el manejador real de la salida estandar.
    ; -11 corresponde a STD_OUTPUT_HANDLE.
    ;
    ; El comentario original mencionaba "Handle = 1 = stdout",
    ; pero en Windows usamos GetStdHandle para obtenerlo.
    mov ecx, -11
    call GetStdHandle

    ; Guardamos el handle temporalmente
    mov qword ptr [rsp + 28h], rax

    ; ------------------------------------------------------------
    ; Calcular la longitud de la cadena
    ; ------------------------------------------------------------
    mov rcx, -1
    xor al, al

    ; Buscar el byte 0 que marca el final
    repne scasb

    not rcx
    dec rcx                 ; RCX = longitud

    ; Ahora RDI apunta despues del final, necesitamos restaurarlo
    sub rdi, rcx
    sub rdi, 1

    ; ------------------------------------------------------------
    ; Llamada para escribir en consola (Windows)
    ;
    ; El documento dejo esta parte para completar.
    ; Usamos WriteFile, que requiere kernel32.dll.
    ;
    ; Parametros en Windows x64:
    ; RCX = handle de salida
    ; RDX = direccion del texto
    ; R8  = numero de bytes
    ; R9  = direccion que recibe los bytes escritos
    ; 5to parametro = 0
    ; ------------------------------------------------------------

    ; La longitud calculada estaba en RCX, la pasamos a R8
    mov r8, rcx

    ; Primer parametro: handle de stdout
    mov rcx, qword ptr [rsp + 28h]

    ; Segundo parametro: direccion de la cadena
    mov rdx, rdi

    ; Cuarto parametro: espacio para guardar bytes escritos
    lea r9, [rsp + 30h]

    ; Quinto parametro: NULL
    mov qword ptr [rsp + 20h], 0

    call WriteFile

    ; Restauramos la pila
    add rsp, 38h

    pop r9
    pop r8
    pop rdx
    pop rcx

    ret

print_string endp


; ------------------------------------------------------------
; Funcion principal
; ------------------------------------------------------------

main proc

    sub rsp, 28h

    ; ------------------------------------------------------------
    ; 1. Recorrer el arreglo
    ; ------------------------------------------------------------

    ; RBX guarda la direccion del primer elemento
    lea rbx, arreglo

    ; RCX sera el contador de los 10 elementos
    mov rcx, 10

recorrer_arreglo:

    ; ------------------------------------------------------------
    ; 2. Mostrar la direccion del elemento actual
    ; ------------------------------------------------------------

    lea rdi, texto_direccion
    call print_string

    ; RBX contiene la direccion actual.
    ; La copiamos a RAX para convertirla a hexadecimal.
    mov rax, rbx

    lea rdi, buffer
    call print_hex_qword

    lea rdi, buffer
    call print_string

    ; ------------------------------------------------------------
    ; 3. Mostrar el valor almacenado en esa direccion
    ; ------------------------------------------------------------

    lea rdi, texto_valor
    call print_string

    ; Direccionamiento indirecto:
    ; [RBX] significa acceder al contenido de la direccion
    ; que esta almacenada en RBX.
    mov rax, [rbx]

    lea rdi, buffer
    call print_hex_qword

    lea rdi, buffer
    call print_string

    ; Salto de linea para el siguiente elemento
    lea rdi, newline
    call print_string

    ; ------------------------------------------------------------
    ; 4. Avanzar al siguiente elemento
    ; ------------------------------------------------------------

    ; Cada DQ ocupa 8 bytes
    add rbx, 8

    ; LOOP disminuye RCX y repite mientras RCX no sea 0
    loop recorrer_arreglo

    ; ------------------------------------------------------------
    ; 5. Terminar
    ; ------------------------------------------------------------

    xor eax, eax
    add rsp, 28h

    ; No usamos ExitProcess; terminamos con RET como pide el proyecto
    ret

main endp

end
