# Interrupción 16h - Servicios de Teclado BIOS (8086)

## Descripción General

La interrupción **16h** es la interrupción del BIOS (Basic Input/Output System) que proporciona servicios de teclado. Permite leer teclas del buffer del teclado, verificar la disponibilidad de teclas y obtener el estado de las teclas modificadoras (Shift, Ctrl, Alt, etc.).

## Registro de Función (AH)

El registro **AH** especifica la función a ejecutar. A continuación se detallan todas las funciones disponibles:

---

## Funciones Principales

### AH = 00h - Leer Carácter del Teclado

**Descripción:** Lee un carácter del buffer del teclado. Si no hay teclas disponibles, espera hasta que el usuario presione una tecla.

| Registro | Valor | Descripción |
|----------|-------|-------------|
| AH | 00h | Función |

**Salida:**
| Registro | Descripción |
|----------|-------------|
| AL | Código ASCII del carácter |
| AH | Código de escaneo de la tecla |

**Ejemplo:**
```assembly
MOV AH, 00h    ; Función leer carácter
INT 16h        ; Llamar a la interrupción
; AL = código ASCII, AH = código de escaneo
```

---

### AH = 01h - Verificar si Hay Tecla Disponible

**Descripción:** Verifica si hay una tecla en el buffer del teclado sin esperar. No remueve la tecla del buffer.

| Registro | Valor | Descripción |
|----------|-------|-------------|
| AH | 01h | Función |

**Salida:**
| Flag | Estado | Descripción |
|------|--------|-------------|
| ZF | 0 | Hay una tecla disponible (AL = ASCII, AH = escaneo) |
| ZF | 1 | No hay teclas en el buffer |

**Ejemplo:**
```assembly
MOV AH, 01h    ; Función verificar tecla
INT 16h        ; Llamar a la interrupción
JZ NO_HAY_TECLA ; Saltar si ZF=1 (no hay tecla)
; Si ZF=0, AL = código ASCII, AH = código de escaneo
NO_HAY_TECLA:
```

---

### AH = 02h - Leer Estado de Teclas Modificadoras

**Descripción:** Obtiene el estado actual de las teclas modificadoras (Shift, Ctrl, Alt, etc.).

| Registro | Valor | Descripción |
|----------|-------|-------------|
| AH | 02h | Función |

**Salida:**
| Registro | Descripción |
|----------|-------------|
| AL | Estado de las teclas modificadoras |

**Bits del registro AL:**
| Bit | Tecla | Descripción |
|-----|-------|-------------|
| 0 | Right Shift | Shift derecho presionado |
| 1 | Left Shift | Shift izquierdo presionado |
| 2 | Ctrl | Ctrl presionado |
| 3 | Alt | Alt presionado |
| 4 | Scroll Lock | Scroll Lock activado |
| 5 | Num Lock | Num Lock activado |
| 6 | Caps Lock | Caps Lock activado |
| 7 | Insert | Insert activado |

**Ejemplo:**
```assembly
MOV AH, 02h    ; Función leer estado modificadoras
INT 16h        ; Llamar a la interrupción
; AL = estado de las teclas modificadoras
TEST AL, 04h   ; Verificar si Ctrl está presionado
JNZ CTRL_PRESIONADO
```

---

## Códigos de Escaneo de Teclas Especiales

Las teclas especiales (flechas, función, etc.) devuelven códigos de escaneo en el registro **AH**:

| Tecla | Código ASCII (AL) | Código Escaneo (AH) |
|-------|-------------------|---------------------|
| F1 | 00h | 3Bh |
| F2 | 00h | 3Ch |
| F3 | 00h | 3Dh |
| F4 | 00h | 3Eh |
| F5 | 00h | 3Fh |
| F6 | 00h | 40h |
| F7 | 00h | 41h |
| F8 | 00h | 42h |
| F9 | 00h | 43h |
| F10 | 00h | 44h |
| F11 | 00h | 85h |
| F12 | 00h | 86h |
| Flecha Arriba | 00h | 48h |
| Flecha Abajo | 00h | 50h |
| Flecha Izquierda | 00h | 4Bh |
| Flecha Derecha | 00h | 4Dh |
| Insert | 00h | 52h |
| Delete | 00h | 53h |
| Home | 00h | 47h |
| End | 00h | 4Fh |
| Page Up | 00h | 49h |
| Page Down | 00h | 51h |
| Escape | 1Bh | 01h |
| Enter | 0Dh | 1Ch |
| Backspace | 08h | 0Eh |
| Tab | 09h | 0Fh |

---

## Tabla de Códigos ASCII Comunes

| Tecla | ASCII (AL) | Hex |
|-------|------------|-----|
| 0-9 | 30h-39h | 30-39 |
| A-Z | 41h-5Ah | 41-5A |
| a-z | 61h-7Ah | 61-7A |
| Espacio | 20h | 20 |
| ! | 21h | 21 |
| @ | 40h | 40 |
| # | 23h | 23 |
| $ | 24h | 24 |
| % | 25h | 25 |
| ^ | 5Eh | 5E |
| & | 26h | 26 |
| * | 2Ah | 2A |
| ( | 28h | 28 |
| ) | 29h | 29 |
| - | 2Dh | 2D |
| = | 3Dh | 3D |
| + | 2Bh | 2B |
| [ | 5Bh | 5B |
| ] | 5Dh | 5D |
| { | 7Bh | 7B |
| } | 7Dh | 7D |
| \ | 5Ch | 5C |
| | | 7Ch | 7C |
| ; | 3Bh | 3B |
| : | 3Ah | 3A |
| ' | 27h | 27 |
| " | 22h | 22 |
| , | 2Ch | 2C |
| . | 2Eh | 2E |
| / | 2Fh | 2F |
| ? | 3Fh | 3F |
| < | 3Ch | 3C |
| > | 3Eh | 3E |

---

## Ejemplos Completos

### Ejemplo 1: Leer y Mostrar un Carácter
```assembly
; Leer un carácter del teclado
MOV AH, 00h
INT 16h
; AL contiene el carácter ASCII

; Mostrar el carácter en pantalla
MOV AH, 0Eh
INT 10h
```

### Ejemplo 2: Esperar hasta que se presione Enter
```assembly
ESPERAR_ENTER:
    MOV AH, 00h    ; Leer carácter
    INT 16h
    CMP AL, 0Dh    ; ¿Es Enter?
    JNE ESPERAR_ENTER ; Si no, seguir esperando
```

### Ejemplo 3: Verificar tecla sin bloquear
```assembly
VERIFICAR_TECLA:
    MOV AH, 01h    ; Verificar si hay tecla
    INT 16h
    JZ NO_HAY_TECLA ; Si ZF=1, no hay tecla
    
    ; Hay una tecla, leerla
    MOV AH, 00h
    INT 16h
    ; Procesar la tecla en AL
    
NO_HAY_TECLA:
    ; Continuar con otras tareas
```

### Ejemplo 4: Detectar teclas de flecha
```assembly
LEER_TECLA:
    MOV AH, 00h
    INT 16h
    
    CMP AL, 00h        ; ¿Es tecla especial?
    JNE TECLA_NORMAL
    
    ; Es tecla especial, verificar código de escaneo
    CMP AH, 48h        ; Flecha arriba
    JE FLECHA_ARRIBA
    CMP AH, 50h        ; Flecha abajo
    JE FLECHA_ABAJO
    CMP AH, 4Bh        ; Flecha izquierda
    JE FLECHA_IZQUIERDA
    CMP AH, 4Dh        ; Flecha derecha
    JE FLECHA_DERECHA
    JMP LEER_TECLA
    
FLECHA_ARRIBA:
    ; Código para flecha arriba
    JMP LEER_TECLA
FLECHA_ABAJO:
    ; Código para flecha abajo
    JMP LEER_TECLA
FLECHA_IZQUIERDA:
    ; Código para flecha izquierda
    JMP LEER_TECLA
FLECHA_DERECHA:
    ; Código para flecha derecha
    JMP LEER_TECLA
TECLA_NORMAL:
    ; Procesar tecla normal
```

### Ejemplo 5: Verificar si Ctrl+C fue presionado
```assembly
VERIFICAR_CTRL_C:
    MOV AH, 01h        ; Verificar si hay tecla
    INT 16h
    JZ NO_HAY_TECLA
    
    ; Leer la tecla
    MOV AH, 00h
    INT 16h
    
    ; Verificar si es Ctrl+C
    CMP AL, 03h        ; Código ASCII de Ctrl+C
    JE CTRL_C_PRESIONADO
    
NO_HAY_TECLA:
    ; Continuar
    JMP VERIFICAR_CTRL_C
    
CTRL_C_PRESIONADO:
    ; Manejar Ctrl+C
```

### Ejemplo 6: Leer estado de Caps Lock
```assembly
MOV AH, 02h        ; Leer estado modificadoras
INT 16h
TEST AL, 40h       ; Verificar bit 6 (Caps Lock)
JNZ CAPS_LOCK_ON
; Caps Lock está desactivado
JMP FIN
CAPS_LOCK_ON:
; Caps Lock está activado
FIN:
```

### Ejemplo 7: Menú interactivo con teclas de función
```assembly
MENU_PRINCIPAL:
    ; Mostrar opciones
    ; ...
    
    ; Leer tecla
    MOV AH, 00h
    INT 16h
    
    ; Verificar teclas de función
    CMP AH, 3Bh        ; F1
    JE OPCION_F1
    CMP AH, 3Ch        ; F2
    JE OPCION_F2
    CMP AH, 3Dh        ; F3
    JE OPCION_F3
    CMP AL, 1Bh        ; Escape
    JE SALIR
    JMP MENU_PRINCIPAL
    
OPCION_F1:
    ; Acción para F1
    JMP MENU_PRINCIPAL
OPCION_F2:
    ; Acción para F2
    JMP MENU_PRINCIPAL
OPCION_F3:
    ; Acción para F3
    JMP MENU_PRINCIPAL
SALIR:
    ; Salir del programa
```

### Ejemplo 8: Entrada de texto con retroceso
```assembly
; Buffer para almacenar texto
BUFFER DB 80 DUP(0)
POSICION DW 0

LEER_TEXTO:
    MOV AH, 00h        ; Leer carácter
    INT 16h
    
    CMP AL, 0Dh        ; ¿Enter?
    JE FIN_LECTURA
    
    CMP AL, 08h        ; ¿Backspace?
    JE BORRAR_CARACTER
    
    ; Almacenar carácter
    MOV BX, POSICION
    MOV [BUFFER + BX], AL
    INC POSICION
    
    ; Mostrar carácter
    MOV AH, 0Eh
    INT 10h
    JMP LEER_TEXTO
    
BORRAR_CARACTER:
    CMP POSICION, 0
    JE LEER_TEXTO
    
    DEC POSICION
    ; Mover cursor atrás
    MOV AH, 0Eh
    MOV AL, 08h        ; Backspace
    INT 10h
    MOV AL, ' '        ; Espacio
    INT 10h
    MOV AL, 08h        ; Backspace
    INT 10h
    JMP LEER_TEXTO
    
FIN_LECTURA:
    ; Agregar terminador nulo
    MOV BX, POSICION
    MOV BYTE [BUFFER + BX], 0
```

---

## Notas Importantes

1. **Buffer del Teclado:** El BIOS mantiene un buffer circular de 16 teclas. Si el buffer se llena, las teclas nuevas se pierden.

2. **Teclas Especiales:** Las teclas como flechas, función, Insert, Delete, etc., devuelven 00h en AL y un código de escaneo en AH.

3. **Modificadores:** Las teclas modificadoras (Shift, Ctrl, Alt) no se almacenan en el buffer, pero su estado se puede verificar con AH=02h.

4. **Bloqueo:** La función AH=00h bloquea la ejecución hasta que se presione una tecla. Use AH=01h para verificación no bloqueante.

5. **Case Sensitivity:** El registro AL contiene el carácter con la capitalización correcta según el estado de Caps Lock y Shift.

6. **Compatibilidad:** Estas funciones son compatibles con todos los sistemas x86 que implementan el BIOS estándar.

---

## Tabla Resumen de Funciones

| Función | AH | Descripción | Bloqueante |
|---------|-----|-------------|------------|
| Leer carácter | 00h | Lee tecla del buffer | Sí |
| Verificar tecla | 01h | Verifica disponibilidad | No |
| Leer modificadores | 02h | Estado de Shift/Ctrl/Alt | No |

---

## Relación con Otras Interrupciones

- **INT 10h:** Servicios de video (para mostrar caracteres)
- **INT 21h:** Servicios DOS (funciones de entrada/salida avanzadas)
- **INT 16h:** Servicios de teclado BIOS (esta interrupción)

La interrupción 16h es la forma estándar de leer teclado en programas que funcionan directamente con el BIOS, sin depender del sistema operativo DOS.
