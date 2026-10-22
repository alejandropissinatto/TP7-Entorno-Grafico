/*
 * TP7 - Entorno gráfico | Informática II | Ingeniería Electrónica
 * Interfaz Processing para controlar E/S de una placa Arduino.
 *
 * Protocolo (texto, 9600 baudios, líneas terminadas en '\n'):
 *   Arduino -> PC : "S,e1,e2,l1,l2"   (estado de entradas y LEDs, 0/1)
 *   PC -> Arduino : "L1:1" / "L1:0"   (encender/apagar LED 1)
 *                   "L2:1" / "L2:0"   (encender/apagar LED 2)
 *                   "?"               (pedir estado)
 *
 * Sin placa conectada el programa entra en MODO SIMULACIÓN:
 * las teclas '1' y '2' hacen de pulsadores E1 y E2.
 */
import processing.serial.*;

Serial puerto;
boolean conectado = false;

boolean[] entradas = new boolean[2];   // true = ALTO (pulsado)
boolean[] leds     = new boolean[2];   // true = encendido

// Geometría de la interfaz
int[] ex = {300, 450};  int ey = 100;  int ew = 100, eh = 50;   // casilleros E1, E2
int[] lx = {350, 500};  int ly = 280;  int lr = 40;             // LEDs L1, L2 (centro y radio)

void setup() {
  size(700, 400);
  textAlign(CENTER, CENTER);
  textSize(22);
  conectarArduino();
}

void conectarArduino() {
  String[] lista = Serial.list();
  println("Puertos disponibles:");
  printArray(lista);
  // Busca un puerto típico de Arduino (Linux, Mac o Windows)
  for (String p : lista) {
    if (p.contains("ttyACM") || p.contains("ttyUSB") || p.contains("usbmodem")
        || p.contains("usbserial") || p.startsWith("COM")) {
      try {
        puerto = new Serial(this, p, 9600);
        puerto.bufferUntil('\n');
        conectado = true;
        println("Conectado a " + p);
        delay(2000);            // el Arduino se reinicia al abrir el puerto
        puerto.write("?\n");
        return;
      } catch (Exception e) {
        println("No se pudo abrir " + p);
      }
    }
  }
  println("Sin placa: MODO SIMULACIÓN (teclas 1 y 2)");
}

void draw() {
  background(255);
  stroke(0); strokeWeight(1); noFill();
  rect(5, 5, width - 10, height - 10);

  // Etiquetas de sector
  fill(140, 170, 210); stroke(100);
  rect(80, 100, 150, 50);
  fill(250, 225, 210);
  rect(80, 255, 150, 50);
  fill(0); noStroke();
  text("Entradas", 155, 125);
  text("Salidas", 155, 280);

  // Entradas: verde = ALTO, gris oscuro = BAJO
  for (int i = 0; i < 2; i++) {
    stroke(0); strokeWeight(2);
    fill(entradas[i] ? color(60, 200, 80) : color(90));
    rect(ex[i], ey, ew, eh);
    fill(255); noStroke();
    text("E" + (i + 1), ex[i] + ew / 2, ey + eh / 2 - 8);
    textSize(13);
    text(entradas[i] ? "ALTO" : "BAJO", ex[i] + ew / 2, ey + eh / 2 + 12);
    textSize(22);
  }

  // Salidas: rojo = encendido, gris claro = apagado
  for (int i = 0; i < 2; i++) {
    stroke(0); strokeWeight(3);
    fill(leds[i] ? color(255, 50, 50) : color(225));
    ellipse(lx[i], ly, lr * 2, lr * 2);
    fill(leds[i] ? 255 : 0); noStroke();
    text("L" + (i + 1), lx[i], ly);
  }

  // Estado de la conexión
  fill(conectado ? color(0, 140, 0) : color(200, 0, 0));
  textSize(13);
  text(conectado ? "Arduino conectado" : "Modo simulación (teclas 1 y 2)", width / 2, height - 20);
  textSize(22);
}

// ---------- Punto 2: clic del mouse sobre la salida ----------
void mousePressed() {
  for (int i = 0; i < 2; i++) {
    if (dist(mouseX, mouseY, lx[i], ly) <= lr) {
      cambiarLed(i, !leds[i]);
    }
  }
}

void cambiarLed(int i, boolean valor) {
  if (conectado) {
    // El estado real lo informa el Arduino (se actualiza en serialEvent)
    puerto.write("L" + (i + 1) + ":" + (valor ? 1 : 0) + "\n");
  } else {
    leds[i] = valor;            // simulación local
  }
}

// ---------- Recepción desde Arduino ----------
void serialEvent(Serial p) {
  String linea = p.readStringUntil('\n');
  if (linea == null) return;
  linea = trim(linea);
  String[] campos = split(linea, ',');
  if (campos.length == 5 && campos[0].equals("S")) {
    entradas[0] = campos[1].equals("1");
    entradas[1] = campos[2].equals("1");
    leds[0]     = campos[3].equals("1");
    leds[1]     = campos[4].equals("1");
  }
}

// ---------- Simulación sin placa (Punto 3 emulado) ----------
void keyPressed() {
  if (conectado) return;
  if (key == '1' && !entradas[0]) { entradas[0] = true; leds[0] = !leds[0]; }
  if (key == '2' && !entradas[1]) { entradas[1] = true; leds[1] = !leds[1]; }
}

void keyReleased() {
  if (conectado) return;
  if (key == '1') entradas[0] = false;
  if (key == '2') entradas[1] = false;
}
