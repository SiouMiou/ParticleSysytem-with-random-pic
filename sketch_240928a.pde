
import spout.*;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
ArrayList<RandomImageSquare> squares = new ArrayList<RandomImageSquare>();
Queue<PImage> images = new LinkedList<PImage>();
boolean imagesLoaded = false; // 用於標記圖像是否已加載
final int MAX_IMAGES = 10; // 最大圖像數量
// NoiseField object
NoiseField noiseField;
// An ArrayList of points
ArrayList<Points> points;
ArrayList<Box> boxes = new ArrayList<Box>(); // 存放方框的列表
// Spout sender
Spout spout;

void setup() {
  size(1600, 1000, P2D);
  // 使用解析度為30的噪音場初始化
  noiseField = new NoiseField(10);
  points = new ArrayList<Points>();

  // 初始化 Spout sender
  spout = new Spout(this);
  spout.setSenderName("Spout Sender");
  // 創建30000個隨機的點（points），每個點具有隨機的最大速度和最大施加力
  for (int i = 0; i < 5000; i++) {
      float angle = random(TWO_PI);
      // 隨機生成半徑
      float r = random(100);
      // 計算 x 和 y 坐標
      float x = r * cos(angle);
      float y = r * sin(angle);
      //position = new PVector(random(width / 2 - 150, width / 2+150), random(height / 2 - 150, height / 2 + 150)); // 隨機重置位置
      PVector position = new PVector(x+width/2,y+height/2);
    //PVector position = new PVector(random(width / 2 - 100, width / 2+100), random(height / 2 - 100, height / 2 + 100)); // 隨機重置位置
    points.add(new Points(position, random(2, 5), random(0.5, 0.8)));
  }
  for (int i = 0; i < 5; i++) { // 這裡創建5個方框
    boxes.add(new Box());
  }
  // 隨機生成多個方形
  for (int i = 0; i < 1; i++) {
    squares.add(new RandomImageSquare());
  }
  // 加載初始圖像
  while(images.size() < MAX_IMAGES) {
     PImage img = loadImage("https://picsum.photos/" + (int)random(40, 60) + "/" + (int)random(40, 60) + ".jpg?random");
      if (img != null && img.width > 0 && img.height > 0) {
        synchronized (images) { // 使用同步來保護隊列
          images.add(img); // 將有效圖像添加到隊列
          println("圖片加載:"+images.size());
        }
      } else {
        println("圖片加載失敗");
      }
  }
   imagesLoaded = true; 
}

void draw() {
  colorMode(HSB, 360, 100, 100, 100); // 設置顏色模式
  background(0, 0, 0, 0); // 設置背景顏色為黑色
  
  // 告訴所有的points跟隨噪音場
  for (Points p : points) {
    p.follow(noiseField); // 讓點跟隨噪音場的方向
    p.run(); // 更新點的狀態並繪製
  }
  for (Box box : boxes) {
    PVector pos = points.get((int)random(5000)).position;
    box.update(pos); // 更新方框位置
    box.display(); // 顯示方框
  }
  if (imagesLoaded) {
    for (RandomImageSquare square : squares) {
      PVector pos = points.get((int)random(5000)).position;
      square.update(pos);
      square.display();
    }
    
    // 檢查圖像數量，如果少於最大數量，則加載新圖像
    if (images.size() < MAX_IMAGES) {
      loadImages();
      noiseField.init();
    }
  } else {
    fill(255);
    text("正在加載圖像...", width / 2 - 50, height / 2); // 顯示加載信息
  }
  // 將畫面發送到 Spout
   spout.sendTexture();

  // noiseField.display(); // 繪製噪音場
}
void loadImages() {
  if(images.size() < MAX_IMAGES) {
    // 使用新線程加載圖像
    new Thread(() -> {
      PImage img = loadImage("https://picsum.photos/" + (int)random(40, 60) + "/" + (int)random(40, 60) + ".jpg?random");
      if (img != null && img.width > 0 && img.height > 0) {
        synchronized (images) { // 使用同步來保護隊列
          images.add(img); // 將有效圖像添加到隊列
        }
      } else {
        println("圖片加載失敗");
      }
    }).start(); // 啟動線程
  }
  
  imagesLoaded = true; // 設置標記為已加載
}
void exit() {
  // 在退出時關閉 Spout 發送器
  spout.closeSender();
}
