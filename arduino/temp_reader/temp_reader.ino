/*
 * Leitura de temperatura usando um termistor
 */

// Conexão do termistor
const int pinTermistor = A0;

// Parâmetros do termistor
const double beta = 3600.0;
const double r0 = 10000.0;
const double t0 = 273.15 + 25.0;
const double rx = r0 * exp(-beta/t0);

// Parâmetros do circuito
const double vcc = 5.0;
const double R = 10000.0;

// Numero de amostras na leitura
const int numberOfSamples = 5;

double readTemperatureInCelsius() {
  // Reads multiple samples from the termistor and averages them
  int sum = 0;
  for (int i = 0; i < numberOfSamples; i++) {
    sum += analogRead(pinTermistor);
    delay(10);
  }

  // Determines the resistance of the termistor
  double v = (vcc * sum) / (numberOfSamples * 1023.0);
  double rt = (vcc * R) / v - R;

  // Calcula a temperatura em graus Celsius
  double t = beta / log(rt / rx);
  return t - 273.15;
}

// Initialization
void setup() {
  Serial.begin(9600);
}

// Infinite loop
void loop() {
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();

    // Simple request/response protocol
    if (command == "READ") {
      double temperatureCelsius = readTemperatureInCelsius();
      Serial.println(temperatureCelsius, 2);
    } else {
      Serial.println("ERR");
    }
  }
}