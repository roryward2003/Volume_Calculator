// Custom class which contains a PShape object and some basic variables
class Shape {
  public PShape pShape;
  public boolean sign;
  public int codeCount;
  public int nestLayer;
  public float w, h;
  
  public Shape(PShape pShape) {
    this.pShape = pShape;
    sign = true;
    nestLayer = 0;
    codeCount = pShape.getVertexCodeCount();
  }
  
  public void setDimensions() {
    float minX = 0;
    float maxX = 0;
    float minY = 0;
    float maxY = 0;
    for(int i=0; i<pShape.getVertexCount(); i++)
    {
      if(pShape.getVertex(i).x>maxX)
        maxX = pShape.getVertex(i).x;
      if(pShape.getVertex(i).x<minX)
        minX = pShape.getVertex(i).x;
      if(pShape.getVertex(i).y>maxY)
        maxY = pShape.getVertex(i).y;
      if(pShape.getVertex(i).y<minY)
        minY = pShape.getVertex(i).y;
    }
    maxX = Math.abs(maxX);
    minX = Math.abs(minX);
    maxY = Math.abs(maxY);
    minY = Math.abs(minY);
    w = (maxX>=minX ? 2*maxX : 2*minX);
    h = (maxY>=minY ? 2*maxY : 2*minY);
  }
  
  public void alternateSign() {
    sign = !sign;
    nestLayer++;
  }
}
