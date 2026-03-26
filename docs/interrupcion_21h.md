# Interrupción 21h - DOS Services

La interrupción 21h es la interrupción principal del DOS para servicios del sistema. Se invoca con `INT 21h` y el número de función en el registro AH.

## Funciones Comunes

### 01h - Leer Carácter del Teclado con Eco
Lee un carácter del teclado y lo muestra en pantalla.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 01h |
| **Retorno** | |
| AL | Carácter leído |

```assembly
MOV AH, 01h
INT 21h        ; AL = carácter leído
```

### 02h - Mostrar Carácter
Muestra un carácter en pantalla.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 02h |
| DL | Carácter a mostrar |

```assembly
MOV AH, 02h
MOV DL, 'A'    ; Carácter a mostrar
INT 21h
```

### 06h - Entrada/Salida Directa de Consola
Lee o escribe un carácter sin esperar.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 06h |
| DL | FFh para leer, otro valor para escribir |
| **Retorno (si DL=FFh)** | |
| ZF | 1 si no hay carácter, 0 si hay |
| AL | Carácter leído (si ZF=0) |

```assembly
; Leer carácter sin esperar
MOV AH, 06h
MOV DL, 0FFh
INT 21h
JZ NO_HAY_CARACTER  ; Saltar si no hay carácter
; AL = carácter leído

; Escribir carácter
MOV AH, 06h
MOV DL, 'B'
INT 21h
```

### 07h - Leer Carácter del Teclado sin Eco
Lee un carácter sin mostrarlo en pantalla.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 07h |
| **Retorno** | |
| AL | Carácter leído |

```assembly
MOV AH, 07h
INT 21h        ; AL = carácter leído (sin eco)
```

### 08h - Leer Carácter del Teclado sin Espera
Lee un carácter sin eco y sin esperar (similar a 07h).

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 08h |
| **Retorno** | |
| AL | Carácter leído |

```assembly
MOV AH, 08h
INT 21h        ; AL = carácter leído
```

### 09h - Mostrar Cadena de Caracteres
Muestra una cadena terminada en '$'.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 09h |
| DS:DX | Dirección de la cadena (terminada en '$') |

```assembly
MOV AH, 09h
MOV DX, OFFSET MI_CADENA
INT 21h

MI_CADENA DB 'Hola Mundo$'
```

### 0Ah - Leer Cadena del Teclado
Lee una línea de texto del teclado.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 0Ah |
| DS:DX | Dirección del buffer de entrada |
| **Buffer** | |
| Byte 0 | Longitud máxima del buffer |
| Byte 1 | (Salida) Longitud real leída |
| Byte 2+ | Carácteres leídos |

```assembly
MOV AH, 0Ah
MOV DX, OFFSET BUFFER
INT 21h

BUFFER DB 20      ; Longitud máxima
       DB ?       ; Longitud real (se llena automáticamente)
       DB 20 DUP(?)  ; Espacio para los carácteres
```

### 0Bh - Verificar Estado del Teclado
Verifica si hay un carácter disponible en el buffer del teclado.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 0Bh |
| **Retorno** | |
| AL | FFh si hay carácter, 00h si no |

```assembly
MOV AH, 0Bh
INT 21h
CMP AL, 0FFh
JE HAY_CARACTER
```

### 0Ch - Limpiar Buffer y Leer
Limpia el buffer del teclado y luego lee un carácter.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 0Ch |
| AL | Función de lectura (01h, 06h, 07h, 08h, 0Ah) |

```assembly
MOV AH, 0Ch
MOV AL, 01h    ; Limpiar buffer y leer con eco
INT 21h
```

### 2Ch - Obtener Tiempo del Sistema
Obtiene la hora actual del sistema.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 2Ch |
| **Retorno** | |
| CH | Hora (0-23) |
| CL | Minutos (0-59) |
| DH | Segundos (0-59) |
| DL | Centésimas de segundo (0-99) |

```assembly
MOV AH, 2Ch
INT 21h        ; CH=hora, CL=minutos, DH=segundos, DL=centésimas

; Ejemplo: Guardar tiempo en variables
MOV HORA, CH
MOV MINUTOS, CL
MOV SEGUNDOS, DH
MOV CENTESIMAS, DL
```

### 25h - Establecer Vector de Interrupción
Establece el manejador de una interrupción.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 25h |
| AL | Número de interrupción |
| DS:DX | Dirección del manejador |

```assembly
MOV AH, 25h
MOV AL, 08h                ; Interrupción del timer
MOV DX, OFFSET MI_MANEJADOR
INT 21h
```

### 35h - Obtener Vector de Interrupción
Obtiene la dirección del manejador de una interrupción.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 35h |
| AL | Número de interrupción |
| **Retorno** | |
| ES:BX | Dirección del manejador actual |

```assembly
MOV AH, 35h
MOV AL, 08h
INT 21h        ; ES:BX = dirección del manejador actual
```

### 4Ch - Terminar Programa
Termina el programa y retorna al DOS.

| Registro | Valor/Descripción |
|----------|-------------------|
| AH | 4Ch |
| AL | Código de retorno |

```assembly
MOV AH, 4Ch
MOV AL, 0      ; Código de retorno (0 = éxito)
INT 21h
```

## Tabla Resumen de Funciones Comunes

| AH | Función | Descripción |
|----|---------|-------------|
| 01h | Leer carácter con eco | Lee un carácter del teclado y lo muestra |
| 02h | Mostrar carácter | Muestra un carácter en pantalla |
| 06h | I/O directa | Lee/escribe carácter sin esperar |
| 07h | Leer sin eco | Lee carácter sin mostrarlo |
| 08h | Leer sin eco | Similar a 07h |
| 09h | Mostrar cadena | Muestra cadena terminada en '$' |
| 0Ah | Leer cadena | Lee línea de texto del teclado |
| 0Bh | Verificar teclado | Verifica si hay carácter disponible |
| 0Ch | Limpiar y leer | Limpia buffer y lee carácter |
| 2Ch | Obtener tiempo | Obtiene hora del sistema |
| 25h | Establecer vector | Establece manejador de interrupción |
| 35h | Obtener vector | Obtiene manejador de interrupción |
| 4Ch | Terminar programa | Termina programa y retorna al DOS |

## Ejemplos de Uso

### Ejemplo 1: Leer y Mostrar un Carácter
```assembly
MOV AH, 01h        ; Leer carácter con eco
INT 21h            ; AL = carácter leído

MOV AH, 02h        ; Mostrar carácter
MOV DL, AL         ; DL = carácter a mostrar
INT 21h
```

### Ejemplo 2: Mostrar un Mensaje
```assembly
MOV AH, 09h
MOV DX, OFFSET MENSAJE
INT 21h

MENSAJE DB 'Hola, Mundo!$'
```

### Ejemplo 3: Leer una Cadena
```assembly
MOV AH, 0Ah
MOV DX, OFFSET BUFFER
INT 21h

BUFFER DB 50       ; Longitud máxima
       DB ?        ; Longitud real
       DB 50 DUP(?)  ; Espacio para la cadena
```

### Ejemplo 4: Terminar Programa
```assembly
MOV AH, 4Ch
MOV AL, 0          ; Código de retorno
INT 21h
```

## Notas Importantes

1. **Código de retorno**: Siempre usar `INT 21h` con AH=4Ch para terminar programas correctamente
2. **Cadena terminada en '$'**: La función 09h requiere que la cadena termine con el carácter '$' (24h)
3. **Preservar registros**: Algunas funciones modifican registros; guardar valores importantes antes de llamar a INT 21h
4. **Buffer de entrada**: La función 0Ah requiere un buffer con formato específico (máximo, real, datos)
5. **Carácter de eco**: Las funciones 01h y 0Ah muestran el carácter en pantalla; usar 07h/08h para lectura sin eco
