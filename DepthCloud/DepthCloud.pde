import org.openkinect.processing.*;

Kinect2 Kinect2;

void setup(){
    size(1024, 848, P3D);
    Kinect2 = new Kinect2(this);
    Kinect2.initDepth();
    Kinect2.initDevice();
}

void draw(){
    background(0);

    PImage img = Kinect2.getDepthImage();

    //convert 2d array to 1d for iteration//
    int skip = 3;
    for (int x=0; x< img.width; x+=skip){
      for (int y = 0; y< img.height; y+=skip){
        int index = x+y*img.width;
        float b = brightness(img.pixels[index]);
        float z = map(b, 0, 255, 250, -250);
        fill(255-b);
        pushMatrix();
        translate(x, y, z);
        rect(x,y,skip,skip);
        popMatrix();
      }
    }
}