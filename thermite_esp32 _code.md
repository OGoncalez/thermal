
#include <WiFi.h>
#include <PubSubClient.h>

// =================== CONFIGURAÇÕES ===================
const char* ssid = "Wokwi-GUEST";
const char* password = "";

const char* mqtt_server = "broker.emqx.io";
const int mqtt_port = 1883;

#define LED_GREEN_PIN 2
#define LED_RED_PIN 15
#define LED_YELLOW_PIN 4

// HC-SR04 pins (ajuste conforme seu circuito)
#define TRIGGER_PIN 21
#define ECHO_PIN 22

WiFiClient espClient;
PubSubClient client(espClient);

bool sensorActive = false;
unsigned long lastTempMillis = 0;
unsigned long lastDistanceMillis = 0;

// Função chamada automaticamente quando chega uma mensagem
void callback(char* topic, byte* payload, unsigned int length) {
  String mensagem = "";

  for (unsigned int i = 0; i < length; i++) {
    mensagem += (char)payload[i];
  }

  Serial.print("Mensagem recebida: ");
  Serial.println(mensagem);

  if (mensagem == "ligar_led_verde") {
    digitalWrite(LED_GREEN_PIN, HIGH);
    Serial.println("LED VERDE LIGADO");
  } else if (mensagem == "desligar_led_verde") {
    digitalWrite(LED_GREEN_PIN, LOW);
    Serial.println("LED VERDE DESLIGADO");
  } else if (mensagem == "ligar_led_vermelho") {
    digitalWrite(LED_RED_PIN, HIGH);
    Serial.println("LED VERMELHO LIGADO");
  } else if (mensagem == "desligar_led_vermelho") {
    digitalWrite(LED_RED_PIN, LOW);
    Serial.println("LED VERMELHO DESLIGADO");
  } else if (mensagem == "ligar_led_amarelo") {
    digitalWrite(LED_YELLOW_PIN, HIGH);
    Serial.println("LED AMARELO LIGADO");
  } else if (mensagem == "desligar_led_amarelo") {
    digitalWrite(LED_YELLOW_PIN, LOW);
    Serial.println("LED AMARELO DESLIGADO");
  } else if (mensagem == "ativar_sensor") {
    sensorActive = true;
    Serial.println("Sensor ativado");
  } else if (mensagem == "desativar_sensor") {
    sensorActive = false;
    Serial.println("Sensor desativado");
  }
}

void setup_wifi() {
  Serial.print("Conectando ao WiFi");
  WiFi.begin(ssid, password);

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    if (millis() - start > 15000) { // timeout 15s
      Serial.println();
      Serial.println("Timeout WiFi; continuando sem conexão");
      return;
    }
  }
  Serial.println("\nWiFi conectado!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  // Loop até se conectar ao broker MQTT
  while (!client.connected()) {
    Serial.print("Conectando ao MQTT...");
    String clientId = "DANIEL_REIS_" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("conectado!");
      client.subscribe("iot/comando");
    } else {
      Serial.print("falhou, rc=");
      Serial.print(client.state());
      Serial.println(" tentando novamente em 5s");
      delay(5000);
    }
  }
}

// leitura HC-SR04
float readUltrasonicDistance() {
  digitalWrite(TRIGGER_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  if (duration == 0) return -1.0;
  float distance = (duration / 2.0) * 0.0343;
  return distance;
}

// publica temperatura simulada
void publishTemperature() {
  float temp = 20.0 + (random(0, 100) / 10.0);
  char buf[16];
  dtostrf(temp, 4, 1, buf);
  if (client.connected()) {
    client.publish("iot/otavio", buf);
    Serial.print("Temp publicada: "); Serial.println(buf);
  }
}

void publishDistance() {
  float d = readUltrasonicDistance();
  if (d < 0) {
    Serial.println("Leitura HC-SR04 inválida");
    return;
  }
  char buf[16];
  dtostrf(d, 5, 1, buf);
  if (client.connected()) {
    client.publish("iot/distancia", buf);
    Serial.print("Dist publicada: "); Serial.println(buf);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);
  pinMode(LED_YELLOW_PIN, OUTPUT);
  digitalWrite(LED_GREEN_PIN, LOW);
  digitalWrite(LED_RED_PIN, LOW);
  digitalWrite(LED_YELLOW_PIN, LOW);
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  randomSeed(analogRead(0));

  setup_wifi();

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (WiFi.status() == WL_CONNECTED && !client.connected()) {
    reconnect();
  }

  if (client.connected()) client.loop();

  unsigned long now = millis();
  if (now - lastTempMillis > 10000) {
    publishTemperature();
    lastTempMillis = now;
  }

  if (sensorActive && (now - lastDistanceMillis > 1500)) {
    publishDistance();
    lastDistanceMillis = now;
  }
}