#include <LiquidCrystal.h>
#include <SPI.h>
#include <Ethernet.h>

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);
byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x1F, 0x6F };
IPAddress ip(192,168,1,99);
EthernetClient client;

char serverHost[] = "music";
String currentLine = "";
const unsigned long requestInterval = 10000;
unsigned long lastAttemptTime = millis()-requestInterval;
const unsigned int maxLen = 16;

void setup()
{
  Serial.begin(9600);
  lcd.begin(maxLen,2);

  display("Connecting...", "");
  if (!Ethernet.begin(mac)) {
    Serial.println("DHCP failed, connecting with static IP.");
    Ethernet.begin(mac, ip);
  }
  Serial.println(Ethernet.localIP());
}

void loop() {
  if (!client.connected()) {
    if (millis() - lastAttemptTime > requestInterval) {
      requestNowPlaying();
    }
    return;
  }
  if (!client.available()) {
    return;
  }

  char inChar = client.read();
  currentLine += inChar;
  if (inChar == '\n') {
    currentLine = "";
  }

  // We have JSON, parse it
  if (currentLine.endsWith("}")) {
    client.stop();
    String line1;
    String line2;

    line1 = extractField("currentartist", 16);
    line2 = extractField("currentsong", 14);

    display(line1, line2);
  }
}

// Returns the specified field value from the json.
String extractField(String fieldName, int offset) {
  int chunkStart = currentLine.indexOf(fieldName) + offset;
  String chunk = currentLine.substring(chunkStart, chunkStart + maxLen);
  int chunkEnd = chunk.indexOf('"');
  String value = chunk.substring(0, min(maxLen, chunkEnd));
  // Handle nulls
  if (value == "ull,") {
    value = "";
  }
  return(value);
}

void requestNowPlaying() {
  if (client.connect(serverHost, 80)) {
    Serial.println("making HTTP request...");
    client.println("POST /_player_engine.php HTTP/1.1");
    client.println("HOST: music");
    client.println("Connection: close");
    client.println();
  }
  lastAttemptTime = millis();
}

// TODO: consider scrolling output to allow displaying long lines
void display(String line1, String line2) {
  Serial.println(line1);
  Serial.println(line2);
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(line1.substring(0, maxLen));
  lcd.setCursor(0,1);
  lcd.print(line2.substring(0, maxLen));
}
