PShape currSvg;
Shape[] currShapes;
float scaleConstant;
float depthInMm;
float currentArea;
float currentVolume;
boolean fileActive;
boolean validDepth;
Button browseButton;
InputBox inputBox;

void settings() {
  size(SCREEN_X, SCREEN_Y);
}

void setup() {  
  shapeMode(CENTER);
  frameRate(FRAME_RATE);
  textAlign(CORNER);
  fileActive = false;
  validDepth = false;
  browseButton = new Button(100, 100, 200, 40, BUTTON_COLOR, "Browse for SVG", EVENT_BROWSE);
  inputBox = new InputBox(100, 180, 200, 40, BUTTON_COLOR, "Enter depth in mm", EVENT_DEPTH);
}

void draw() {
  background(BACKGROUND_COLOR);
  fill(0);
  stroke(0);
  browseButton.draw();
  inputBox.draw();
  if(fileActive) {
    pushStyle();
    strokeWeight(3/scaleConstant);
    for(Shape s : currShapes) {
      fill(s.sign ? IMAGE_COLOR : BACKGROUND_COLOR);
      shape(s.pShape, SCREEN_X-DISPLAY_BOX_BORDER-(DISPLAY_BOX_SIZE/2), SCREEN_Y/2);
    }
    popStyle();
    
    textSize(25);
    text("Area = "+currentArea+" cm^2", 100, 300);
    if(validDepth)
      text("Volume = "+currentVolume+" ml", 100, 500);
  }
  textSize(25);
  if(validDepth)
    text("Depth = "+depthInMm+" mm", 100, 400);
}

void mousePressed() {
  if(browseButton.mouseOver())
    browseButton.buttonPressed();
  if(inputBox.mouseOver()) {
    inputBox.inputBoxPressed();
  }
  else {
    if(inputBox.label == "" || inputBox.label == "|")
      inputBox.setDefaultLabel();
    inputBox.active = false;
  }
}

void keyPressed() {
  if(inputBox.active) {
    inputBox.keyPressed(key);
    validDepth = isDepthValid();
    if(validDepth && fileActive)
      currentVolume = getVolume(depthInMm);
  }
}

public boolean isDepthValid() {
  if(inputBox.label != inputBox.defaultLabel && inputBox.label != "" && inputBox.label != "|") { 
    if(inputBox.label.charAt(0)=='|')
      inputBox.label=inputBox.label.substring(1, inputBox.label.length());
    depthInMm = Float.parseFloat(inputBox.label);
    return true;
  }
  return false;
}

void fileSelected(File selection) {
  noLoop();
  if (selection != null && (selection.getAbsolutePath().substring(selection.getAbsolutePath().length()-3, selection.getAbsolutePath().length()).equals("svg"))) {
    currSvg = loadShape(selection.getAbsolutePath());
    currSvg.disableStyle();
    fileActive = true;
    currShapes = cullChildren(currSvg.getChildren());
    calculateSigns(currShapes);
    currShapes = sortByNestLayer(currShapes);
    currentArea = getCompositeArea(currSvg);
    if(validDepth)
      currentVolume = getVolume(depthInMm);
    setScale(currShapes);
    scaleShapes(currShapes, scaleConstant);
  }
  loop();
}

void setScale(Shape[] shapes) {
  for(Shape s : shapes)
    s.setDimensions();
  float max = 0;
  for(Shape s : shapes) {
    if(s.h > max)
      max = s.h;
    if(s.w > max)
      max = s.w;
  }
  scaleConstant = DISPLAY_BOX_SIZE/max;
}

// Very Accurately calculates the volume of a toolpath given an svg and a depth in mm
float getVolume(float depthInMm) {
  return (depthInMm/10)*currentArea;
}

// Calculates total enclosed area of an svg file (in cm^2), accounting for oddeven
float getCompositeArea(PShape initialSvg) {
  Float area = 0.0;
  Shape[] culledSvg = cullChildren(initialSvg.getChildren());
  calculateSigns(culledSvg);
  for(Shape s : culledSvg)
    area += getArea(s);
  return area;
}

// Calculates the area enclosed by one closed vector, accounting for odd even
float getArea(Shape shape) {
  float area = 0;
  int codeCount = shape.codeCount;
  float x1 = (shape.pShape.getVertex(0).x/10);
  float y1 = (shape.pShape.getVertex(0).y/10);
  float x2, y2, bX, bY, cX, cY;
  
  int v=0; // Used to iterate through all vertices, instead of just the anchor points
  for(int i=1; i<codeCount; i++)
  {
    if(shape.pShape.getVertexCode(i)==1) {
      bX = (shape.pShape.getVertex(v+1).x/10);
      bY = (shape.pShape.getVertex(v+1).y/10);
      cX = (shape.pShape.getVertex(v+2).x/10);
      cY = (shape.pShape.getVertex(v+2).y/10);
      x2 = (shape.pShape.getVertex(v+3).x/10);
      y2 = (shape.pShape.getVertex(v+3).y/10);
      area += getAreaUnderBezier(x1, y1, bX, bY, cX, cY, x2, y2);
      x1 = x2;
      y1 = y2;
      v+=3;
    } else {
      x2 = shape.pShape.getVertex(v+1).x/10;
      y2 = shape.pShape.getVertex(v+1).y/10;
      area += (x2-x1)*((y1+y2)/2);
      x1 = x2;
      y1 = y2;
      v++;
    }
  }
  return (shape.sign ? Math.abs(area) : -Math.abs(area));
}

// Function to repeatedly sample a bezier curve and calculate the area of its low poly equivalent
// This function uses the units passed to it (mm->mm^2, cm->cm^2, etc.)
float getAreaUnderBezier(float x1, float y1, float bX, float bY, float cX, float cY, float x2, float y2) {
  float area = 0;
  float xOne = x1;
  float yOne = y1;
  float xTwo, yTwo, t;
  
  // scale increment to increase/decrease precision
  float increment = 1 / (BEZIER_PRECISION*(sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)))));
  
  for(t=0; t<1; t+=increment)
  {
    xTwo = bezierPoint(x1, bX, cX, x2, t);
    yTwo = bezierPoint(y1, bY, cY, y2, t);
    area += (xTwo-xOne)*((yOne+yTwo)/2);
    xOne = xTwo;
    yOne = yTwo;
  }
  xTwo = x2;
  yTwo = y2;
  area += (x2-xOne)*((yOne+y2)/2);
  // This final line closes the gap from the last t value to t=1
  
  return area;
}

void scaleShapes(Shape[] shapes, float scale) {
  for(Shape s : shapes)
    s.pShape.scale(scale);
}

// Loops through all pairs of vectors in the svg and assigns each shape a sign based on oddeven
// This is achieved by alternating the sign of the first vector if all its points are inside the fill of the second
// The function Shape.alternateSign() also tracks the nestLayer to prevent overlapping visuals later
// Yes I know this code is ugly. Looping through all pairs of vectors then looping through all the points of
// the first vector requires a lot of loops. This code could also be far more efficient but I'm focusing more on
// how robust it is as I don't want any mistakes, even if that means checking every point instead of just a small sample
public void calculateSigns(Shape[] shapes) {
  boolean allPointsInside;
  for(int i=0; i<shapes.length; i++) {
    for(int n=0; n<shapes.length; n++) {
      if(i!=n) {
        allPointsInside = true;
        int v=0; // Used to iterate through all vertices, instead of just the anchor points
        for(int m=1; m<shapes[i].codeCount; m++) {
          if(shapes[i].pShape.getVertexCode(m)==1) {
            if(!shapes[n].pShape.contains(shapes[i].pShape.getVertex(v).x, shapes[i].pShape.getVertex(v).y))
              allPointsInside=false;
            v+=3;
          } else {
            if(!shapes[n].pShape.contains(shapes[i].pShape.getVertex(v).x, shapes[i].pShape.getVertex(v).y))
              allPointsInside=false;
            v++;
          }
        }
        if(allPointsInside)
          shapes[i].alternateSign();
      }
    }
  }
}

Shape[] sortByNestLayer(Shape[] shapes) {
  Shape[] sorted = new Shape[shapes.length];
  int shapesSorted = 0;
  for(int i=0; shapesSorted<shapes.length; i++)
  {
    for(Shape s : shapes)
    {
      if(s.nestLayer==i && shapesSorted<shapes.length)
        sorted[shapesSorted++]=s;
    }
  }
  return sorted;
}

// Removes all empty children from the svg and stores the non empty children in a linear array of Shapes
Shape[] cullChildren(PShape[] kids) {
  Shape[] output = new Shape[0];
  for(PShape k : kids)
  {
    Shape kid = new Shape(k);
    if(kid.pShape.getChildCount()!=0)
    {
      output = merge(output, cullChildren(kid.pShape.getChildren()));
    }
    else if(kid.pShape.getVertexCodeCount()!=0)
    {
      output = merge(output, kid);
    }
  }
  return output;
}

// The below functions would be unnecessary if I used ArrayLists instead of Arrays

// Merges the two passed Shape arrays
Shape[] merge(Shape[] p1, Shape[] p2) {
  Shape[] output = new Shape[p1.length+p2.length];
  for(int i=0; i<p1.length; i++)
    output[i] = p1[i];
  for(int i=p1.length; i<output.length; i++)
    output[i] = p2[i-p1.length];
  return output;
}

// Extends the passed Shape array with the passed Shape at the end
Shape[] merge(Shape[] p1, Shape p2) {
  Shape[] output = new Shape[p1.length+1];
  for(int i=0; i<p1.length; i++)
    output[i] = p1[i];
  output[output.length-1] = p2;
  return output;
}
