# TP7 – Entorno gráfico (Processing + Arduino)

Informática II – Ingeniería Electrónica – 2026

Interfaz gráfica en **Processing** para monitorear y controlar las entradas/salidas de una placa **Arduino** por USB (puerto serie, 9600 baudios).

## Funcionamiento
1. **Entradas (E1, E2):** se muestran en verde (ALTO, pulsador oprimido) o gris (BAJO).
2. **Salidas (L1, L2):** se muestran en rojo (LED encendido) o gris claro (apagado). Al hacer clic con el mouse sobre un LED, la PC le ordena al Arduino alternar esa salida.
3. **Pulsadores físicos:** al oprimir E*n* el Arduino alterna el LED L*n* y lo informa a la PC.
4. **Comunicación bidireccional** con protocolo de texto:
   - Arduino → PC: `S,e1,e2,l1,l2`
   - PC → Arduino: `L1:1`, `L1:0`, `L2:1`, `L2:0`, `?`

El Arduino es el dueño del estado de los LEDs; la pantalla siempre refleja lo que él informa.

## Conexiones
| Elemento | Pin Arduino |
|---|---|
| Pulsador E1 | D2 – GND (INPUT_PULLUP) |
| Pulsador E2 | D3 – GND (INPUT_PULLUP) |
| LED L1 (+220 Ω) | D8 – GND |
| LED L2 (+220 Ω) | D9 – GND |

(Agregar aquí el esquemático en `esquematico/`.)

## Uso
1. Cargar `TP7_Arduino/TP7_Arduino.ino` en la placa.
2. Cerrar el Monitor Serie del IDE de Arduino.
3. Abrir `TP7_Processing/TP7_Processing.pde` en Processing y ejecutar. Detecta el puerto automáticamente.

Sin placa conectada funciona en **modo simulación** (teclas `1` y `2` como pulsadores).
