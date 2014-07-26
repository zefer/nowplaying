#include <LiquidCrystal.h>

LiquidCrystal lcd(9, 8, 5, 4, 3, 2);

void setup()
{
  Serial.begin(9600);
  lcd.begin(16,2);

  delay(500);

  Serial.println("getting ready...");
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
