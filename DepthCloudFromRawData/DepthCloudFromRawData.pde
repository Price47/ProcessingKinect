import org.openkinect.processing.*;
import java.nio.*;

Kinect2 K2;

float a = 3.1;

int renderMode = 1;

PGL pgl;
PShader sh;

int vertexVboId;

void setup(){
    size(1024, 848, P3D);
    K2 = new Kinect2(this);
    K2.initDepth();
    K2.initDevice();
    
    sh = loadShader("frag.glsl", "vert.glsl");
    
    PGL pgl = beginPGL();
    
    IntBuffer intBuffer = IntBuffer.allocate(1);
    
    vertexVboId = intBuffer.get(0);
    
    endPGL();
    
    smooth(16);
}

void draw(){
    background(0);
    
    pushMatrix();
    translate(width/2, height/2, 50);
    rotateY(a);

    if(renderMode == 1){
      
      int[] depth = K2.getRawDepth();
      int skip = 2;
      
      stroke(255);
      strokeWeight(2);
      beginShape(POINTS);
      for (int x=0; x< K2.depthWidth; x+=skip){
        for (int y = 0; y< K2.depthHeight; y+=skip){
          int offset = x+y*K2.depthWidth;
          int d = depth[offset];   
          PVector point = depthToPointCloudPos(x,y,d);
          vertex(point.x, point.y, point.z);
        }
    }
    endShape();
    }else if (renderMode==2){
      
      int vertData = K2.depthWidth * K2.depthHeight;
      FloatBuffer depthPositions = K2.getDepthBufferPositions();
      
      pgl = beginPGL();
      sh.bind();
      vertexVboId = pgl.getAttribLocation(sh.glProgram, "Vertex");
      
      pgl.enableVertexAttribArray(vertexVboId);
      
      {
        pgl.bindBuffer(PGL.ARRAY_BUFFER, vertexVboId);
        pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData * 3, depthPositions, PGL.DYNAMIC_DRAW);
        pgl.vertexAttribPointer(vertexVboId, 3, PGL.FLOAT, false, Float.BYTES * 3, 0);
      }
      pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
      pgl.drawArrays(PGL.POINTS, 0, vertData);
      sh.unbind();
      endPGL();
    }
    
    popMatrix();
    
    fill(255, 0, 0); 
    //a += 0.015f;
}

void keyPressed(){
  if(key == '1'){
    renderMode = 1;
  }
  if(key=='2'){
    renderMode = 2;
  }
}

PVector depthToPointCloudPos(int x, int y, float depthValue){
  PVector point = new PVector();
  point.z = (depthValue);
  point.x = (x- CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  
  return point;
}