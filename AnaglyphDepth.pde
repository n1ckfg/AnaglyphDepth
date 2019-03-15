import gab.opencv.*;
import org.opencv.core.Mat;
import org.opencv.calib3d.StereoBM;
import org.opencv.core.CvType;
import org.opencv.calib3d.StereoSGBM;

OpenCV ocvL, ocvR;
PGraphics gfxL, gfxR;
PImage img, depth1, depth2;
PShader shader_blur;

void setup() {
  size(50, 50, P2D);
  img = loadImage("mountain.jpg");
  surface.setSize(img.width, img.height);
  
  shader_blur = loadShader("lchannel.glsl");
  shader_blur.set("blurSize", 9);
  shader_blur.set("horizontalPass", 1);
  shader_blur.set("sigma", 5.0); 
  
  gfxL = createGraphics(img.width, img.height, P2D);
  gfxL.beginDraw();
  gfxL.tint(255, 0, 0);
  shader_blur.set("texture", img);
  gfxL.filter(shader_blur);
  gfxL.endDraw();
  
  gfxR = createGraphics(img.width, img.height, P2D);
  gfxR.beginDraw();
  gfxR.tint(0, 255, 255);
  gfxR.image(img, 0, 0);
  gfxR.endDraw();  
  
  ocvL = new OpenCV(this, gfxL);
  ocvR = new OpenCV(this, gfxR);

  ocvL.gray();
  ocvR.gray();
  Mat left = ocvL.getGray();
  Mat right = ocvR.getGray();

  Mat disparity = OpenCV.imitate(left);

  StereoSGBM stereo =  new StereoSGBM(0, 32, 3, 128, 256, 20, 16, 1, 100, 20, true);
  stereo.compute(left, right, disparity );

  Mat depthMat = OpenCV.imitate(left);
  disparity.convertTo(depthMat, depthMat.type());

  depth1 = createImage(depthMat.width(), depthMat.height(), RGB);
  ocvL.toPImage(depthMat, depth1);

  StereoBM stereo2 = new StereoBM();
  stereo2.compute(left, right, disparity );
  disparity.convertTo(depthMat, depthMat.type());


  depth2 = createImage(depthMat.width(), depthMat.height(), RGB);
  ocvL.toPImage(depthMat, depth2);
}

void draw() {
  int w = img.width/2;
  int h = img.height/2;
  image(gfxL, 0, 0, w, h);
  image(gfxR, w, 0, w, h);

  image(depth1, 0, h, w, h);
  image(depth2, w, h, w, h);

  fill(255, 0, 0);
  text("left", 10, 20);
  text("right", 10 + gfxL.width, 20);
  text("stereo SGBM", 10, gfxL.height + 20);
  text("stereo BM", 10 + gfxL.width, gfxL.height+ 20);
}
