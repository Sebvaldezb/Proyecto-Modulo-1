# Proyecto Modulo 1 - Visor de Memoria

Proyecto de **Lenguajes de Interfaz (SCC-1014)** realizado en ensamblador x86-64.

## Descripcion

El programa recorre un arreglo de 10 elementos de 64 bits y muestra en consola la direccion de memoria y el valor de cada elemento en formato hexadecimal de 16 digitos.

El arreglo se declara con `DQ`, por lo que cada elemento ocupa 8 bytes. `RBX` se utiliza como puntero y `RCX` como contador.

El acceso al valor actual se realiza mediante direccionamiento indirecto:

```asm
mov rax, [rbx]
```

y el puntero avanza al siguiente elemento con:

```asm
add rbx, 8
```

## Conversion hexadecimal

El procedimiento `print_hex_qword` convierte un valor de 64 bits a 16 caracteres hexadecimales.

Para hacerlo utiliza:

```text
0123456789ABCDEF
```

Se toman 4 bits en cada vuelta usando `AND` con `0Fh` y luego `SHR RAX, 4` para continuar con el siguiente digito.

## Salida en consola

El codigo base del proyecto deja incompleta la parte de `print_string` que realmente muestra el texto.

Para completar esa seccion se utilizaron:

- `GetStdHandle` para obtener el manejador de la salida estandar.
- `WriteFile` para escribir el texto en la consola.

El programa **no utiliza `ExitProcess` ni `MessageBoxA`** y termina mediante `RET`.

### Nota sobre la restriccion de dependencias

El documento contiene una contradiccion: una restriccion indica que no deben utilizarse funciones de la API de Windows, pero el propio codigo de referencia deja pendiente la salida y menciona `WriteFile`, y el apartado de preguntas frecuentes vuelve a mencionar funciones de consola.

En esta implementacion se decidio seguir la solucion sugerida por el codigo de referencia para poder demostrar la salida solicitada. Por esa razon `GetStdHandle` y `WriteFile` requieren `kernel32.dll`.

Si el requisito de "sin API de Windows" se interpreta de forma estricta, esta parte tendria que sustituirse por el mecanismo que indique el profesor.

## Uso de inteligencia artificial

Se utilizo **ChatGPT** como herramienta de apoyo durante el proyecto.

Se utilizo para:

- Revisar el codigo base proporcionado.
- Explicar instrucciones que necesitaban mayor comprension.
- Revisar el funcionamiento de la conversion hexadecimal.
- Detectar la contradiccion entre la restriccion de no usar API y la necesidad de mostrar informacion en consola.
- Analizar la seccion incompleta de `print_string`.
- Apoyar la implementacion de `GetStdHandle` y `WriteFile`.
- Revisar comentarios y documentacion del repositorio.

La IA se utilizo como apoyo para revisar, comprender y completar la parte que el codigo de referencia dejaba pendiente. El codigo fue revisado y adaptado tomando como base las especificaciones del proyecto.

## Compilacion

Ensamblar:

```text
uasm64 -win64 visor_memoria.asm
```

Enlazar:

```text
GoLink /console /entry main visor_memoria.obj kernel32.dll
```

Ejecutar:

```text
visor_memoria.exe
```

## Resultado esperado

La salida tiene una estructura similar a:

```text
Direccion: 00007FF6A9B01000 Valor: 0000000000000005
Direccion: 00007FF6A9B01008 Valor: 000000000000000A
Direccion: 00007FF6A9B01010 Valor: 000000000000000F
```

Las direcciones pueden cambiar entre ejecuciones.

## Captura de pantalla

Agregar aqui una captura de la ejecucion del programa mostrando los 10 elementos.
