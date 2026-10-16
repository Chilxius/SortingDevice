// Bennett Ritchie

//***************************
// Sorting Machine
//    and
// Number Generator
//    with Strategy Pattern
//***************************

import java.util.LinkedList;

SorterConsole console;

void setup()
{
  fullScreen();
  rectMode(CENTER);
  textFont( createFont("DroidSansMono.ttf",128) );
  frameRate(240);
  
  console = new SorterConsole();
}

void draw()
{
  background(100);
  console.update();
  console.display();
}

void mousePressed()
{
  console.resolveClick();
}

void mouseReleased()
{
  console.resolveRelease();
}
