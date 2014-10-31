#include <LiquidCrystal.h>
#include <SPI.h>
#include <Ethernet.h>
#define BACKLIGHT_PIN 7

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);
byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x1F, 0x6F };
IPAddress ip(192,168,1,99);
EthernetClient client;

char MPDHost[] = "music";
const unsigned int MPDPort = 6600;
String currentLine = "";
const unsigned long requestInterval = 10000;
unsigned long lastAttemptTime = millis()-requestInterval;
const unsigned int maxLen = 16;

// Dim the backlight if the display hasn't changed
const unsigned long backlightTimeout = 25000;
unsigned long lastDisplayChange = 0;
String lastDisplay = "";

String artist, title, file;

void setup()
{
  Serial.begin(9600);
  lcd.begin(maxLen,2);
  pinMode(BACKLIGHT_PIN, OUTPUT);
  digitalWrite(BACKLIGHT_PIN, HIGH);

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

  if (inChar == '\n') {
    // We have a full line, read & act on it.
    readLine(currentLine);
    currentLine = "";
  } else {
    currentLine += inChar;
  }
}

void endOfResponse() {
  client.stop();
  if ( artist != "" ) {
    display(artist, title);
  } else {
    // Fallback: display the start & end of the file string.
    int len = file.length();
    display(
      file.substring(0, min(15, len)),
      file.substring((max(0, len-16)), len)
    );
  }
}

// Reads a line of an MPD response, could be an attribute, or an EOM.
void readLine(String l) {
  if (l == "OK") {
    // EOM. We're probably going to display something.
    endOfResponse();
    artist = "";
    title = "";
    file = "";
  } else if (l.startsWith("Artist: ")) {
    artist = l.substring(8);
  } else if (l.startsWith("Title: ")) {
    title = l.substring(7);
  } else if (l.startsWith("file: ")) {
    file = l.substring(6);
  }
}

void requestNowPlaying() {
  if (client.connect(MPDHost, MPDPort)) {
    Serial.println("Requesting MPD...");
    // MPD has a simple proto: http://www.musicpd.org/doc/protocol/syntax.html
    client.println("currentsong\nclose");
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

  // Backlight on if song/display changed.
  if(line1 + line2 != lastDisplay) {
    digitalWrite(BACKLIGHT_PIN, HIGH);
    lastDisplayChange = millis();
    lastDisplay = line1 + line2;
  }
  // Backlight off if song/display hasn't changed since timeout period.
  if (millis() - lastDisplayChange > backlightTimeout) {
    digitalWrite(BACKLIGHT_PIN, LOW);
  }
}
