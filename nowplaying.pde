#include <LiquidCrystal.h>
#include <SPI.h>
#include <Ethernet.h>
/* #include <JsonParser.h> */
/* using namespace ArduinoJson::Parser; */

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);
byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x1F, 0x6F };
IPAddress ip(192,168,1,99);
EthernetClient client;

char serverHost[] = "music";
boolean requested;
String currentLine = "";            // string to hold the text from server
const unsigned long requestInterval = 10000;  // delay between requests
unsigned long lastAttemptTime = millis() - requestInterval;

void setup()
{
  Serial.begin(9600);
  lcd.begin(16,2);

  display("Connecting...", "");
  if (!Ethernet.begin(mac)) {
    Serial.println("Failed to get an IP address using DHCP, trying manually");
    Ethernet.begin(mac, ip);
  }
  Serial.println(Ethernet.localIP());
  display("Hi", "Joe :)");
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
  if ( currentLine.endsWith("}")) {
    client.stop();
    String chunk;
    chunk = currentLine.substring(currentLine.indexOf("currentartist")+16);
    String artist = chunk.substring(0, chunk.indexOf('"'));
    chunk = currentLine.substring(currentLine.indexOf("currentsong")+14);
    String song = chunk.substring(0, chunk.indexOf('"'));
    display(artist, song);
  }
}

void requestNowPlaying() {
  Serial.println("connecting to server...");
  if (client.connect(serverHost, 80)) {
    Serial.println("making HTTP request...");
    client.println("POST /_player_engine.php HTTP/1.1");
    client.println("HOST: music");
    client.println("Connection: close");
    client.println();
  }
  lastAttemptTime = millis();
}

void display(String line1, String line2) {
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(line1);
  lcd.setCursor(0,1);
  lcd.print(line2);
  Serial.println(line1);
  Serial.println(line2);
}
