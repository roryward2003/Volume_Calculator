class InputBox {
  int x;
  int y;
  int width;
  int height;
  color colour;
  String defaultLabel;
  String label;
  int event;
  boolean active;
  int tick;
  boolean tickActive;
  
  InputBox(int x, int y, int width, int height, color colour, String defaultLabel, int event) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.colour = colour;
    this.defaultLabel = defaultLabel;
    this.label = defaultLabel;
    this.event = event;
    active = false;
    tick = INPUT_BOX_TICK_RATE;
    tickActive = false;
  }
  
  void draw() {
    if(tick--<=0) {
      tick = 30;
      tickActive = !tickActive;
      if(tickActive && label == "")
        label = "|";
      else if(!tickActive && label == "|")
        label = "";
      tick=INPUT_BOX_TICK_RATE;
    }
    pushStyle();
    fill(colour);
    stroke(mouseOver() ? HOVER_OUTLINE_COLOR : NORMAL_OUTLINE_COLOR);
    strokeWeight(5);
    rect(x, y, width, height, 10);
    rectMode(CENTER);
    textAlign(LEFT);
    textSize(20);
    if(label != defaultLabel && label != "|" && label != "") {
      fill(0);
      text(label+" mm", x+10, y+(2*height/3));
    } else {
      fill(80);
      text(label, x+10, y+(2*height/3));
    }
    rectMode(CORNER);
    popStyle();
  }
  
  boolean mouseOver() {
    return(mouseX>x-HITBOX_EXTENSION && mouseX<x+width+HITBOX_EXTENSION && mouseY>y-HITBOX_EXTENSION && mouseY<y+height+HITBOX_EXTENSION);
  }
  
  void inputBoxPressed() {
    active = true;
    if(label == defaultLabel)
      label = "";
  }
  
  void setDefaultLabel() {
    label = defaultLabel;
  }
  
  void keyPressed(char keyEntered) {
    if(keyEntered == BACKSPACE && label.length()>0 && label != "|")
      label = label.substring(0, max(0, label.length()-1));
    else if(Character.isDigit(keyEntered) && label.length()<MAX_LABEL_LENGTH)
      label += keyEntered;
      if(label.substring(0,0)=="|")
        label=label.substring(1, label.length());
    else if(keyEntered == '.' && !label.contains(".") && label != "" && label != "|" && label.length()<MAX_LABEL_LENGTH)
      label += keyEntered;
  }
}
