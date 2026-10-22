/*
 * TP7 - Entorno gráfico | Informática II | Ingeniería Electrónica
 * Programa del Arduino: lee pulsadores, maneja LEDs y se comunica con Processing.
 *
 * Conexiones:
 *   Pulsador E1 -> D2 y GND   (INPUT_PULLUP, pulsado = LOW)
 *   Pulsador E2 -> D3 y GND
 *   LED L1 -> D8 -> resistencia 220 ohm -> LED -> GND
 *   LED L2 -> D9 -> resistencia 220 ohm -> LED -> GND
 *
 * Protocolo (9600 baudios, líneas terminadas en '\n'):
 *   Arduino -> PC : "S,e1,e2,l1,l2"
 *   PC -> Arduino : "L1:1", "L1:0", "L2:1", "L2:0", "?"
 */

const int PIN_E[2] = {2, 3};
const int PIN_L[2] = {8, 9};

bool led[2]        = {false, false};
bool entrada[2]    = {false, false};   // true = pulsado (ALTO lógico)
bool ultimaLectura[2] = {false, false};
unsigned long tCambio[2] = {0, 0};
const unsigned long REBOTE = 40;       // antirrebote en ms

unsigned long tUltimoEnvio = 0;
String buffer = "";

void enviarEstado() {
  Serial.print("S,");
  Serial.print(entrada[0]); Serial.print(',');
  Serial.print(entrada[1]); Serial.print(',');
  Serial.print(led[0]);     Serial.print(',');
  Serial.println(led[1]);
  tUltimoEnvio = millis();
}

void setLed(int i, bool v) {
  led[i] = v;
  digitalWrite(PIN_L[i], v ? HIGH : LOW);
}

void setup() {
  Serial.begin(9600);
  for (int i = 0; i < 2; i++) {
    pinMode(PIN_E[i], INPUT_PULLUP);
    pinMode(PIN_L[i], OUTPUT);
    digitalWrite(PIN_L[i], LOW);
  }
  enviarEstado();
}

void loop() {
  bool cambio = false;

  // ---- Entradas con antirrebote (Punto 3: pulsar alterna el LED correspondiente) ----
  for (int i = 0; i < 2; i++) {
    bool lectura = (digitalRead(PIN_E[i]) == LOW);     // LOW = pulsado
    if (lectura != ultimaLectura[i]) {
      tCambio[i] = millis();
      ultimaLectura[i] = lectura;
    }
    if ((millis() - tCambio[i]) > REBOTE && lectura != entrada[i]) {
      entrada[i] = lectura;
      if (entrada[i]) setLed(i, !led[i]);              // flanco de subida -> alterna LED
      cambio = true;
    }
  }

  // ---- Comandos desde la PC (Punto 2: clic en el mouse) ----
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') {
      buffer.trim();
      if (buffer == "?") {
        cambio = true;
      } else if (buffer.length() >= 4 && buffer[0] == 'L') {
        int i = buffer[1] - '1';
        if (i >= 0 && i < 2 && buffer[2] == ':') {
          setLed(i, buffer[3] == '1');
          cambio = true;
        }
      }
      buffer = "";
    } else if (buffer.length() < 16) {
      buffer += c;
    }
  }

  // Envía ante cualquier cambio, y cada 1 s como latido
  if (cambio || millis() - tUltimoEnvio > 1000) enviarEstado();
}
