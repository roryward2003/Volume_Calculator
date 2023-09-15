class Button {
  int x;
  int y;
  int width;
  int height;
  color colour;
  String label;
  int event;
  
  Button(int x, int y, int width, int height, color colour, String label, int event) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.colour = colour;
    this.label = label;
    this.event = event;
  }
  
  void draw() {
    pushStyle();
    fill(colour);
    stroke(mouseOver() ? HOVER_OUTLINE_COLOR : NORMAL_OUTLINE_COLOR);
    strokeWeight(5);
    rect(x, y, width, height, 10);
    fill(0);
    rectMode(CENTER);
    textAlign(CENTER);
    textSize(20);
    text(label, x+(width/2), y+(2*height/3));
    rectMode(CORNER);
    popStyle();
  }
  
  boolean mouseOver() {
    return(mouseX>x-HITBOX_EXTENSION && mouseX<x+width+HITBOX_EXTENSION && mouseY>y-HITBOX_EXTENSION && mouseY<y+height+HITBOX_EXTENSION);
  }
  
  // Generalised this with events to allow for more buttons, but didn't use any
  void buttonPressed() {
    switch(event)
    {
      case EVENT_BROWSE:
        selectInput("Select a file to process:", "fileSelected");
        break;
    }
  }
}
