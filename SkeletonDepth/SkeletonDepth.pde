import org.openkinect.processing.*;
import java.nio.*;

Kinect2 K2;

PImage img;
PImage img2;


void setup(){
    size(1024,800);
    K2 = new Kinect2(this);
    K2.initDepth();
    K2.initDevice();
    img2 = createImage(K2.depthWidth, K2.depthHeight, RGB);
    
}

void draw(){
    background(0);
    float dangerThreshold = 750;
    float warningThreshold = 900;
    float distanceThreshold = 3500;
    color dangerColor = color(249, 27 , 27);
    color warningColor = color(249, 249, 27);
    color safeColor = color(27, 249, 27);
    
    int[] depth2 = K2.getRawDepth();
    int [] skeletonValues;
   
    int average = getMeanDepth(depth2);
    int[] skeletonPoints = getSkeleton(depth2, average);
    int shoulderHeight = (skeletonPoints[1]) * (7/8);
    for (int x=0; x< K2.depthWidth; x++){
       for (int y = 0; y< K2.depthHeight; y++){
          int offset = x+y*K2.depthWidth;
          int d = depth2[offset];    
          if(d>average-200 && d<average+200){
            img2.pixels[offset] = color(255,255,255);
          }else if( d>300 && d<dangerThreshold){   
            img2.pixels[offset] = dangerColor;
          }
          else if( d>dangerThreshold && d<warningThreshold){   
            img2.pixels[offset] = warningColor;
          }
          else if( d>warningThreshold && d<distanceThreshold){   
            img2.pixels[offset] = safeColor;
          }else{
            img2.pixels[offset] = color(0, 0, 0);
          }
        }
    }
    
    img2.updatePixels();
    image(img2, 0,0);
    
    stroke(155);
    strokeWeight(4);
    line(skeletonPoints[0],skeletonPoints[1],skeletonPoints[2],skeletonPoints[3]);
    stroke(155);
    strokeWeight(3);
    //line(skeletonPoints[4], shoulderHeight, skeletonPoints[5], shoulderHeight);
    line(skeletonPoints[4],(int)(skeletonPoints[3]*(7/8)),skeletonPoints[5],(int)(skeletonPoints[3]*(7/8)));
    
}
    
int getMeanDepth(int[] depth){
  int total = 0;
  int sumDepth = 0;
    for (int x=0; x< K2.depthWidth; x++){
       for (int y = 0; y< K2.depthHeight; y++){
          int offset = x+y*K2.depthWidth;
          int d = depth[offset];
          total++;
          sumDepth += d;     
       }    
    }
    return (sumDepth / total); 
}

int[] getSkeleton(int[] depth, int average){
  int  topY = 0, leftX=0, bottomY = K2.depthHeight, rightX = K2.depthWidth;
  for (int x=0+150; x< K2.depthWidth-150; x++){
       for (int y = 0; y< K2.depthHeight; y++){
             int offset = x+y*K2.depthWidth;
             if(depth[offset]<(average+200) & depth[offset]>(average-200)){
              if(x>leftX){
                   leftX = x;
                 }  
               if(y<bottomY){
                 bottomY = y;
               }   
               if(x<rightX){
                   rightX = x;
                 } 
               if(y>topY){
                 topY= y;
               }
             }
               
       }    
    }
    int averageX = (leftX + rightX)/2;
    int[] returnValues = {averageX, topY, averageX, bottomY, leftX, rightX};
   
    
    return returnValues;
}
  
    