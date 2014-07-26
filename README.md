# Nowplaying

Simple Arduino program that displays what music is currently playing on my home
music server.

Makes an API request to the [Volumio](http://volumio.org/) music server, parses
the JSON, and displays the current artist & song on a connected LCD display.

## My setup

* Arduino Uno
* Ethernet Shield
* [16 x 2 LCD Display](http://oomlout.co.uk/products/lcd-display-16x2-charachters)
* Volumio server with LAN hostname `music`
* 10k Ohm potentiometer to adjust LCD contrast
