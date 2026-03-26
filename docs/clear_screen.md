# Clear Screen - Funcionamiento Detallado

Este documento explica en detalle cómo funciona la limpieza de pantalla en modo gráfico DOS (modo 13h), incluyendo diferentes métodos y su implementación.

## Contexto: Modo de Video 13h

El modo 13h es un modo gráfico de 320×200 píxeles con 256 colores. Cada píxel se almacena como un byte en la memoria de video, comenzando en la dirección **0A000h:0000h**.

```
Memoria de Video (0A000h:0000h - 0A000h:FFFFh)
┌─────────────────────────────────────────────┐
│ Píxel 0   │ Píxel 1   │ ... │ Píxel 319     │  Fila 0
├─────────────────────────────────────────────┤
│ Píxel 320 │ Píxel 321 │ ... │ Píxel 639     │  Fila 1
├─────────────────────────────────────────────┤
│ ...       │ ...       │ ... │ ...           │
├─────────────────────────────────────────────┤
│ Píxel 63680│ Píxel 63681│ ... │ Píxel 63999 │  Fila 199
└─────────────────────────────────────────────┘
Total: 320 × 200 = 64,000 bytes
```

## Método 1: Reiniciar Modo de Video

### Código
```assembly
; Limpiar pantalla reiniciando modo de video
MOV AH, 00h      ; Función: Establecer modo de video
MOV AL, 13h      ; Modo 13h (320x200, 256 colores)
INT 10h          ; Llamar a BIOS

MOV AH, 0Bh      ; Función: Establecer paleta/color de fondo
MOV BH, 00h      ; Subfunción: Color de fondo
MOV BL, 00h      ; Color negro
INT 10h          ; Llamar a BIOS
```

### Funcionamiento Paso a Paso

#### Paso 1: Establecer Modo de Video
```
INT 10h, AH=00h, AL=13h
┌─────────────────────────────────────────┐
│ 1. BIOS resetea el controlador de video │
│ 2. Configura resolución 320×200         │
│ 3. Inicializa paleta de 256 colores     │
│ 4. Limpia toda la memoria de video      │
│ 5. Establece página de video activa     │
└─────────────────────────────────────────┘
```

**Detalles:**
- **AH = 00h**: Función "Set Video Mode"
- **AL = 13h**: Modo gráfico 320×200, 256 colores
- **INT 10h**: Interrupción de video del BIOS
- El BIOS automáticamente limpia toda la memoria de video (64,000 bytes) a 0

#### Paso 2: Establecer Color de Fondo
```
INT 10h, AH=0Bh, BH=00h, BL=00h
┌─────────────────────────────────────────┐
│ 1. BIOS lee parámetros                  │
│ 2. BH=00h indica "color de fondo"       │
│ 3. BL=00h es el color negro             │
│ 4. Establece color de fondo de pantalla │
└─────────────────────────────────────────┘
```

**Detalles:**
- **AH = 0Bh**: Función "Set Color Palette"
- **BH = 00h**: Subfunción "Set Background Color"
- **BL = 00h**: Color negro (índice 0 de la paleta)

### Ventajas y Desventajas

| Ventajas | Desventajas |
|----------|-------------|
| Simple de implementar | Muy lento |
| Limpia toda la pantalla | Reinicia configuración de video |
| No requiere cálculos | Pierde paleta de colores personalizada |
| Funciona siempre | Parpadeo visible en pantalla |

### Cuándo Usar Este Método
- Al inicio del programa
- Cuando necesitas cambiar de modo de video
- Cuando no te importa el parpadeo
- Para pruebas simples

---

## Método 2: REP STOSB (String Operations)

### Código
```assembly
; Limpiar pantalla con REP STOSB
MOV AX, 0A000h   ; Segmento de memoria de video
MOV ES, AX       ; ES = 0A000h
MOV DI, 0        ; Offset inicial (primer píxel)
MOV AL, 00h      ; Color negro (valor a escribir)
MOV CX, 64000    ; 320 × 200 = 64,000 bytes
CLD              ; Dirección hacia adelante
REP STOSB        ; Llenar memoria de video
```

### Funcionamiento Paso a Paso

#### Paso 1: Configurar Segmento de Video
```assembly
MOV AX, 0A000h   ; AX = 0A000h
MOV ES, AX       ; ES = 0A000h
```
```
Memoria:
┌─────────────┐
│ ES = 0A000h │ → Segmento de video
└─────────────┘
```
- **0A000h** es el segmento donde el modo 13h almacena píxeles
- **ES** (Extra Segment) se usa para operaciones de string
- ES:DI formará la dirección completa de escritura

#### Paso 2: Configurar Offset Inicial
```assembly
MOV DI, 0        ; DI = 0
```
```
ES:DI = 0A000h:0000h
┌─────────────────┐
│ Primer píxel    │ ← DI apunta aquí
└─────────────────┘
```
- **DI** (Destination Index) apunta al primer byte
- ES:DI = 0A000h:0000h = dirección del primer píxel

#### Paso 3: Configurar Color
```assembly
MOV AL, 00h      ; AL = 00h (negro)
```
```
┌─────────┐
│ AL=00h  │ → Valor a escribir en cada byte
└─────────┘
```
- **AL** contiene el valor del byte a escribir
- 00h = negro en la paleta de colores
- Este valor se copiará a cada posición de memoria

#### Paso 4: Configurar Contador
```assembly
MOV CX, 64000    ; CX = 64,000
```
```
┌──────────┐
│ CX=64000 │ → Número de bytes a escribir
└──────────┘
```
- **CX** es el contador para REP
- 320 × 200 = 64,000 píxeles (bytes)
- REP decrementará CX hasta llegar a 0

#### Paso 5: Configurar Dirección
```assembly
CLD              ; Clear Direction Flag (DF = 0)
```
```
┌─────────┐
│ DF = 0  │ → Dirección hacia adelante
└─────────┘
```
- **CLD** establece la dirección hacia adelante
- Con DF = 0, DI se incrementa después de cada operación
- Si usaras **STD**, DI se decrementaría

#### Paso 6: Ejecutar Limpieza
```assembly
REP STOSB        ; Repetir STOSB hasta CX = 0
```

### ¿Qué Hace STOSB?

**STOSB** (Store String Byte) ejecuta:
```
ES:[DI] = AL     ; Copiar AL a la dirección ES:DI
DI = DI + 1      ; Incrementar DI (si DF = 0)
```

### ¿Qué Hace REP?

**REP** (Repeat) ejecuta:
```
while (CX > 0) {
    ejecutar siguiente instrucción (STOSB)
    CX = CX - 1
}
```

### Ejecución Completa

```
Inicio:
ES = 0A000h
DI = 0000h
AL = 00h (negro)
CX = 64000
DF = 0 (dirección hacia adelante)

Iteración 1:
  ES:[DI] = AL  →  Memoria[0A000h:0000h] = 00h
  DI = DI + 1   →  DI = 0001h
  CX = CX - 1   →  CX = 63999

Iteración 2:
  ES:[DI] = AL  →  Memoria[0A000h:0001h] = 00h
  DI = DI + 1   →  DI = 0002h
  CX = CX - 1   →  CX = 63998

... (63,996 iteraciones más)

Iteración 64000:
  ES:[DI] = AL  →  Memoria[0A000h:FFFFh] = 00h
  DI = DI + 1   →  DI = 0000h (overflow)
  CX = CX - 1   →  CX = 0

FIN: CX = 0, REP termina
```

### Diagrama de Memoria

```
Antes de REP STOSB:
0A000h:0000h ┌──────────┐
             │ ?? ?? ?? │  Contenido anterior
0A000h:0003h ├──────────┤
             │ ?? ?? ?? │
             ├──────────┤
             │ ...      │
0A000h:FFFFh └──────────┘

Después de REP STOSB:
0A000h:0000h ┌──────────┐
             │ 00 00 00 │  Todo negro
0A000h:0003h ├──────────┤
             │ 00 00 00 │
             ├──────────┤
             │ ...      │
0A000h:FFFFh └──────────┘
```

### ¿Por Qué Es Tan Rápido?

| Método | Instrucciones por píxel | Total instrucciones | Ciclos aproximados |
|--------|------------------------|---------------------|-------------------|
| Loop + INT 10h | 5-10 | 320,000-640,000 | ~3,200,000 |
| Loop + MOV | 3 | 192,000 | ~576,000 |
| **REP STOSB** | **1** | **1** | **~64,000** |

**REP STOSB** es más rápido porque:
1. No necesita decodificar instrucciones en cada iteración
2. Usa el bus de datos de manera eficiente
3. Optimizado a nivel de hardware/microcódigo
4. Una sola instrucción controla todo el proceso

### Ventajas y Desventajas

| Ventajas | Desventajas |
|----------|-------------|
| Muy rápido | Requiere conocer dirección de video |
| Eficiente en CPU | Solo para modo gráfico |
| No parpadea | Requiere configurar registros |
| Control total | Más complejo que INT 10h |

---

## Método 3: Scroll de Ventana (INT 10h, AH=06h)

### Código
```assembly
; Limpiar pantalla con scroll
MOV AH, 06h      ; Función: Scroll ventana hacia arriba
MOV AL, 0        ; 0 = limpiar toda la ventana
MOV BH, 00h      ; Atributo (color negro)
MOV CH, 0        ; Fila superior
MOV CL, 0        ; Columna izquierda
MOV DH, 24       ; Fila inferior (25 filas - 1)
MOV DL, 79       ; Columna derecha (80 columnas - 1)
INT 10h          ; Ejecutar
```

### Funcionamiento Paso a Paso

#### Paso 1: Configurar Función
```assembly
MOV AH, 06h      ; Scroll hacia arriba
MOV AL, 0        ; Limpiar (no scroll)
```
- **AH = 06h**: Función "Scroll Window Up"
- **AL = 0**: Número de líneas a hacer scroll (0 = limpiar)

#### Paso 2: Configurar Color
```assembly
MOV BH, 00h      ; Color negro
```
- **BH**: Atributo de color para líneas vacías
- 00h = negro (fondo negro, texto negro)

#### Paso 3: Definir Ventana
```assembly
MOV CH, 0        ; Fila superior (0)
MOV CL, 0        ; Columna izquierda (0)
MOV DH, 24       ; Fila inferior (24)
MOV DL, 79       ; Columna derecha (79)
```
```
Ventana definida:
(0,0) ────────────────── (0,79)
  │                        │
  │    Área a limpiar      │
  │                        │
(24,0) ────────────────── (24,79)
```

#### Paso 4: Ejecutar
```assembly
INT 10h          ; BIOS ejecuta limpieza
```

### ¿Cómo Funciona Internamente?

```
INT 10h, AH=06h, AL=00h:
┌─────────────────────────────────────────┐
│ 1. BIOS lee parámetros de ventana       │
│ 2. Calcula dirección de memoria         │
│ 3. Llena área con color especificado    │
│ 4. No mueve contenido (AL=0)            │
│ 5. Actualiza cursor si es necesario     │
└─────────────────────────────────────────┘
```

### Ventajas y Desventajas

| Ventajas | Desventajas |
|----------|-------------|
| Simple | Solo para modo texto |
| Rápido | No funciona bien en modo gráfico |
| No requiere cálculos | Limitado a 80×25 |
| Soportado por BIOS | Menos control |

---

## Método 4: Dibujar Rectángulo Pixel por Pixel

### Código
```assembly
; Limpiar pantalla dibujando píxeles
MOV AH, 0Ch      ; Función: Dibujar píxel
MOV AL, 00h      ; Color negro
MOV BH, 00h      ; Página de video

MOV DX, 0        ; Y inicial (fila)

LOOP_FILA:
    MOV CX, 0    ; X inicial (columna)
    
LOOP_COLUMNA:
    INT 10h      ; Dibujar píxel en (CX, DX)
    INC CX       ; Siguiente columna
    CMP CX, 320  ; ¿Llegamos al final?
    JNE LOOP_COLUMNA
    
    INC DX       ; Siguiente fila
    CMP DX, 200  ; ¿Llegamos al final?
    JNE LOOP_FILA
```

### Funcionamiento Paso a Paso

#### Paso 1: Configurar Función
```assembly
MOV AH, 0Ch      ; Dibujar píxel
MOV AL, 00h      ; Color negro
MOV BH, 00h      ; Página 0
```

#### Paso 2: Bucle de Filas
```assembly
MOV DX, 0        ; Y = 0 (primera fila)

LOOP_FILA:
    ; ... código de columnas ...
    INC DX       ; Siguiente fila
    CMP DX, 200  ; ¿Terminamos?
    JNE LOOP_FILA
```

#### Paso 3: Bucle de Columnas
```assembly
MOV CX, 0        ; X = 0 (primera columna)

LOOP_COLUMNA:
    INT 10h      ; Dibujar píxel
    INC CX       ; Siguiente columna
    CMP CX, 320  ; ¿Terminamos fila?
    JNE LOOP_COLUMNA
```

### Ejecución

```
Fila 0:
  X=0, Y=0 → INT 10h → Dibujar píxel negro
  X=1, Y=0 → INT 10h → Dibujar píxel negro
  ...
  X=319, Y=0 → INT 10h → Dibujar píxel negro

Fila 1:
  X=0, Y=1 → INT 10h → Dibujar píxel negro
  X=1, Y=1 → INT 10h → Dibujar píxel negro
  ...
  X=319, Y=1 → INT 10h → Dibujar píxel negro

... (198 filas más)

Fila 199:
  X=0, Y=199 → INT 10h → Dibujar píxel negro
  ...
  X=319, Y=199 → INT 10h → Dibujar píxel negro
```

### Ventajas y Desventajas

| Ventajas | Desventajas |
|----------|-------------|
| Fácil de entender | Muy lento |
| Funciona en cualquier modo | 64,000 llamadas a INT 10h |
| No requiere conocimiento de memoria | Alto uso de CPU |
| Bueno para aprender | Parpadeo visible |

---

## Comparación de Métodos

### Tabla Comparativa

| Método | Velocidad | Complejidad | Uso de CPU | Parpadeo | Control |
|--------|-----------|-------------|------------|----------|---------|
| Reiniciar modo | Lento | Baja | Alto | Sí | Bajo |
| REP STOSB | Muy rápido | Media | Muy bajo | No | Alto |
| Scroll ventana | Rápido | Baja | Bajo | No | Medio |
| Pixel por pixel | Muy lento | Baja | Muy alto | Sí | Medio |

### Recomendaciones

| Escenario | Método Recomendado |
|-----------|-------------------|
| Inicio de programa | Reiniciar modo |
| Bucle de juego (60 FPS) | REP STOSB |
| Prototipo rápido | Scroll ventana |
| Aprendizaje | Pixel por pixel |
| Máximo rendimiento | REP STOSB |

---

## Implementación para PONG

### Versión con REP STOSB (Recomendada)
```assembly
; clear_screen.asm
; Limpia la pantalla usando REP STOSB

clear_screen PROC NEAR
    PUSH AX        ; Guardar registros
    PUSH CX
    PUSH DI
    PUSH ES
    
    MOV AX, 0A000h ; Segmento de video
    MOV ES, AX
    MOV DI, 0      ; Offset inicial
    MOV AL, 00h    ; Color negro
    MOV CX, 64000  ; 320×200 bytes
    CLD            ; Dirección hacia adelante
    REP STOSB      ; Llenar memoria
    
    POP ES         ; Restaurar registros
    POP DI
    POP CX
    POP AX
    RET
clear_screen ENDP
```

### Versión con Scroll (Alternativa)
```assembly
; clear_screen_scroll.asm
; Limpia la pantalla usando scroll

clear_screen PROC NEAR
    PUSH AX        ; Guardar registros
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AH, 06h    ; Scroll hacia arriba
    MOV AL, 0      ; Limpiar (no scroll)
    MOV BH, 00h    ; Color negro
    MOV CH, 0      ; Fila inicio
    MOV CL, 0      ; Columna inicio
    MOV DH, 24     ; Fila fin
    MOV DL, 79     ; Columna fin
    INT 10h        ; Ejecutar
    
    POP DX         ; Restaurar registros
    POP CX
    POP BX
    POP AX
    RET
clear_screen ENDP
```

### Uso en Bucle Principal
```assembly
; Bucle principal del juego
GAME_LOOP:
    CALL clear_screen    ; Limpiar pantalla
    CALL update_ball     ; Actualizar posición de pelota
    CALL draw_ball       ; Dibujar pelota
    CALL delay           ; Esperar para controlar FPS
    JMP GAME_LOOP        ; Repetir
```

---

## Notas Importantes

1. **Memoria de Video**: En modo 13h, la memoria de video está en 0A000h:0000h
2. **Paleta de Colores**: El color 00h es negro por defecto
3. **Página de Video**: Usar página 0 (BH=00h) para la mayoría de aplicaciones
4. **Preservar Registros**: Siempre guardar y restaurar registros en procedimientos
5. **Direction Flag**: Usar CLD para dirección hacia adelante, STD para atrás
6. **Rendimiento**: REP STOSB es ~50x más rápido que loop con INT 10h

## Referencias

- [Interrupción 10h - BIOS Video Services](interrupcion_10h.md)
- [Interrupción 21h - DOS Services](interrupcion_21h.md)
- Modo de Video 13h: 320×200, 256 colores
- Memoria de Video: 0A000h:0000h - 0A000h:FFFFh (64KB)
