// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// 定義一個噪音場類別
class NoiseField {

  // 噪音場是一個二維的PVectors陣列
  PVector[][] field;

  int cols, rows; // 列數和行數
  int resolution; // 每個噪音場單元的大小
  float margin = 100; // 噪音場邊界的邊距

  // 構造函數，接受一個解析度參數
  NoiseField(int r) {
    resolution = r;
    // 根據畫布的寬度和高度計算列和行的數量
    cols = width / resolution;
    rows = height / resolution;
    field = new PVector[cols][rows]; // 初始化噪音場陣列
    init(); // 初始化噪音場
  }

  // 初始化噪音場的向量
  public void init() {
    println("reset noise");
    // 重置噪音種子，生成新的噪音場
    noiseSeed((int)random(4000));
    float offsetValue = random(0.12,0.17);
    float xoff = 0; // x軸的噪音偏移量
    for (int i = 0; i < cols; i++) {
      float yoff = 0; // y軸的噪音偏移量
      for (int j = 0; j < rows; j++) {
        // 使用噪音生成角度
        float theta = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
        
        // 計算當前單元格的位置
        float x = i * resolution;
        float y = j * resolution;

        // 根據位置確定流場方向
        PVector direction;
        if (x > width / 2 && y > height / 2) {
          // 第一象限 (X > 0, Y > 0)
          direction = new PVector(1, 1); // 朝向右上方
        } else if (x < width / 2 && y > height / 2) {
          // 第二象限 (X < 0, Y > 0)
          direction = new PVector(-1, 1); // 朝向左上方
        } else if (x < width / 2 && y < height / 2) {
          // 第三象限 (X < 0, Y < 0)
          direction = new PVector(-1, -1); // 朝向左下方
        } else {
          // 第四象限 (X > 0, Y < 0)
          direction = new PVector(1, -1); // 朝向右下方
        }

        // 結合噪音方向
        PVector noiseVector = new PVector(cos(theta), sin(theta));
        field[i][j] = PVector.add(direction, noiseVector.mult(0.9)); // 結合方向並添加一些噪音影響
        field[i][j].normalize(); // 正規化流場向量

        yoff += offsetValue; // 更新y軸噪音偏移量
      }
      xoff += offsetValue; // 更新x軸噪音偏移量
    }
  }

  // 更新噪音場的狀態（目前未做任何實質改變）
  void update() {
    // 目前不進行任何狀態更新
  }

  // 繪製每個向量
  void display() {
    // 繪製噪音場中的每個向量
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        drawVector(field[i][j], i * resolution + 20, j * resolution + 20, resolution - 2);
      }
    }
  }

  // 繪製向量作為箭頭
  void drawVector(PVector v, float x, float y, float scayl) {
    colorMode(HSB, 360, 100, 100, 100); // 設置顏色模式
    pushMatrix(); // 保存當前矩陣狀態

    translate(x, y); // 移動到繪製位置
    stroke(0, 0, 60, 70); // 設置邊框顏色
    strokeWeight(2); // 設置邊框粗細
    rotate(v.heading2D()); // 根據向量方向旋轉
    float len = v.mag() * scayl / 2; // 計算箭頭的長度
    line(0, 0, len, 0); // 繪製箭頭
    popMatrix(); // 恢復矩陣狀態
  }

  // 根據查找位置返回對應的噪音場向量
  PVector lookup(PVector lookup) {
    // 計算列和行索引，並進行邊界檢查
    int column = int(constrain(lookup.x / resolution, 0, cols - 1));
    int row = int(constrain(lookup.y / resolution, 0, rows - 1));
    return field[column][row].get(); // 返回對應的噪音場向量
  }
}
