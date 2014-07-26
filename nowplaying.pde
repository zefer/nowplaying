#include <LiquidCrystal.h>
#include <SPI.h>
#include <Ethernet.h>

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);
byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x1F, 0x6F };
IPAddress ip(192,168,1,99);
EthernetClient client;

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

void display(char* line1, char* line2)
{
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(line1);
  lcd.setCursor(0,1);
  lcd.print(line2);

  Serial.println(line1);
  Serial.println(line2);
}

void loop()
{
}
