# PONG - 8086

Pong clásico implementado completamente en ensamblador x86 (8086) para DOS. Ejecútalo en tu navegador con WebAssembly o en cualquier emulador DOS.

**[Jugar en el navegador](https://jesus-mmm.github.io/8086-pong/)**

---

## Controles

| Acción | Jugador 1 | Jugador 2 |
|---|---|---|
| Mover paleta arriba | `W` | `↑` |
| Mover paleta abajo | `S` | `↓` |
| Empezar / Jugar de nuevo | `Enter` | `Enter` |
| Salir | `Esc` | `Esc` |

El primer jugador en alcanzar **5 puntos** gana.

---

## Características

- Modo de video 13h (320×200, 256 colores)
- Pelota con aceleración progresiva cada 3 rebotes
- Efectos de sonido por PC speaker (rebote en paleta, rebote en pared, punto anotado)
- Pantalla de menú principal y pantalla de game over
- Velocidad de juego sincronizada con el reloj del sistema

---

## Compilación

Requiere un ensamblador MASM-compatible (MASM, TASM o JWASM) y un linker de16 bits.

### Con MASM (DOS / Windows)

```bat
ml /AT /Zd pong.asm
link /TINY pong.obj
```

### Con JWASM (Linux)

```bash
jwasm -m1 pong.asm
# Vincular con OpenWatcom wlink o similar
```

---

## Jugar en el navegador

El proyecto incluye una vista previa web que ejecuta el juego a través de [js-dos](https://js-dos.com) (DOSBox compilado a WebAssembly).

### Pre-requisitos

- `PONG.EXE` compilado en la raíz del proyecto
- Python 3 (para el script de build)

### Build local

```bash
bash web/build.sh
cd web && python3 -m http.server 8080
```

Abrir `http://localhost:8080` en el navegador.

### Deploy automático

El workflow de GitHub Actions (`deploy-pages.yml`) ejecuta el build y despliega a GitHub Pages automáticamente en cada push a `main`/`master`.

**Configurar en GitHub:**
1. Ir a **Settings > Pages**
2. En **Source**, seleccionar **GitHub Actions**

---

## Estructura del proyecto

```
8086-pong/
├── pong.asm                  # Código fuente del juego
├── PONG.EXE                  # Ejecutable DOS compilado
├── MASM.EXE                  # Ensamblador Microsoft Macro
├── TASM.EXE                  # Turbo Assembler (Borland)
├── LINK.EXE                  # Linker de Microsoft
├── web/
│   ├── index.html            # Página web con js-dos WASM
│   └── build.sh              # Script de build para el bundle web
├── docs/
│   ├── interrupcion_10h.md   # Documentación INT 10h (Video)
│   ├── interrupcion_16h.md   # Documentación INT 16h (Teclado)
│   ├── interrupcion_21h.md   # Documentación INT 21h (DOS)
│   ├── clear_screen.md       # Documentación limpieza de pantalla
│   └── informe_proyecto_final_de_curso.pdf
└── .github/
    └── workflows/
        └── deploy-pages.yml  # CI/CD para GitHub Pages
```

---

## Interrupciones utilizadas

| Interrupción | Servicio | Uso en el juego |
|---|---|---|
| `INT 10h` | Video BIOS | Modo de video, dibujar pixels, posicionar cursor |
| `INT 16h` | Teclado BIOS | Leer teclas presionadas |
| `INT 21h` | DOS | Obtener hora del sistema, mostrar cadenas, salir del programa |
| I/O Puerto `42h/43h/61h` | Speaker PC | Efectos de sonido por hardware |

---

## Licencia

Este es un proyecto educativo. Consulta el archivo de informe del curso para más detalles.
