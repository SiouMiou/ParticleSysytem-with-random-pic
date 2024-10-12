// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// 定義 Points 類別
class Points {

  // 物體的基本屬性
  private PVector position;
  private PVector velocity;
  private PVector acceleration;

  private float radius;
  private float maxForce;    // 最大 steering 力
  private float maxSpeed;    // 最大速度
  private float lifeTime;
  private boolean isSeparating = false;
  private float separatingSpeed = 3.5;

  private color colorV;
  private float spotLightSelect = 0;
  private float vHue = 180;
  private float vS = 0;
  private float vAlpha = 40;

  private int lifeTimeCount = 0; // 生命週期計數
  int frameCount = 0; // 當前幀計數
  
  // 建構式
  Points(PVector position, float maxSpeed, float maxForce) {
    colorMode(HSB, 360, 100, 100, 100);
    this.position = position.get();
    this.radius = 3.0f;
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    this.acceleration = new PVector(0, 0);
    this.velocity = new PVector(0, 0);

    resetLifeTime(); // 重置生命週期
    colorV = color(vHue, vS, 50, vAlpha); // 預設顏色
  }

  // 運行物體的邏輯
  public void run() {
    update(); // 更新位置
    borders(); // 檢查邊界
    updateBrightness(); // 更新亮度
    display(); // 繪製物體
    checkIfDead(); // 檢查是否死亡
    frameCount++; // 增加幀計數
    if (frameCount % 200 == 0) { // 每 10 幀檢查一次
      checkBrightnessRange(); // 檢查亮度範圍
      frameCount = 0;
    }
  }

  // 讓粒子跟隨噪音場
  void follow(NoiseField flow) {
    PVector desired = flow.lookup(position); // 獲取噪音場的向量
    desired.mult(maxSpeed); // 乘以最大速度
    PVector steer = PVector.sub(desired, velocity); // 計算 steering 力
    steer.limit(maxForce);  // 限制最大 steering 力
    applyForce(steer); // 應用力
  }

  // 將力添加到加速度中
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  // 更新位置的方法
  void update() {
    velocity.add(acceleration); // 更新速度

    if (isSeparating) {
      isSeparating = false; // 重置分離狀態
      velocity.limit(separatingSpeed); // 限制速度
    } else {
      velocity.limit(maxSpeed); // 限制速度
    }

    position.add(velocity); // 更新位置
    acceleration.mult(0); // 重置加速度
    lifeTime -= 1; // 減少生命週期
    lifeTimeCount++; // 增加生命週期計數
  }
  
  // 繪製粒子
  void display() {
    colorMode(HSB, 360, 100, 100, 100);
    stroke(colorV); // 使用顏色繪製
    strokeWeight(3);
    pushMatrix();
    translate(position.x, position.y);
    point(0, 0); // 繪製點
    popMatrix();
  }
  
  // 更新亮度
  void updateBrightness() {
    if (lifeTimeCount == 30) {
      colorV = color(vHue, vS, 100, vAlpha);
    }
    
    float brightnessValue = brightness(colorV); // 獲取當前亮度
    if (brightnessValue > 50) {
      // 如果亮度大於 50，則每一幀遞減 1
      float newBrightness = brightnessValue - 1;
      colorV = color(vHue, vS, newBrightness, vAlpha); // 更新顏色
    }
  }

  // 檢查粒子是否進入特定範圍，並將亮度設置為 100
 // 檢查粒子是否進入特定範圍，並將亮度設置為 100
void checkBrightnessRange() {
    float rangeRadius = random(30, 60); // 範圍半徑
    
    // 定義四個中心點
    PVector[] centers = {
        new PVector(500, 300), // 第一個點
        new PVector(1000, 200), // 第二個點
        new PVector(500, 750), // 第三個點
        new PVector(1000, 600)  // 第四個點
    };

    // 檢查粒子是否在範圍內
    for (PVector center : centers) {
        if (PVector.dist(position, center) < rangeRadius) {
            colorV = color(vHue, vS, random(80, 100), vAlpha); // 隨機設置亮度
            break; // 如果進入任一範圍，則退出循環
        }
    }
}

  // 檢查生命週期
  void checkIfDead() {
    if (lifeTime < 0 || isTouchingEdge()) {
      resetLifeTime(); // 重置生命週期
      // 隨機生成角度
      float angle = random(TWO_PI);
      // 隨機生成半徑
      float r = random(100);
      // 計算 x 和 y 坐標
      float x = r * cos(angle);
      float y = r * sin(angle);
      //position = new PVector(random(width / 2 - 150, width / 2+150), random(height / 2 - 150, height / 2 + 150)); // 隨機重置位置
      position = new PVector(x+width/2,y+height/2);
     }
  }

  // 檢查邊界
  void borders() {
    if (position.x < -radius) position.x = width + radius;
    if (position.y < -radius) position.y = height + radius;
    if (position.x > width + radius) position.x = -radius;
    if (position.y > height + radius) position.y = -radius;
  }

  // 檢查粒子的位置是否超出邊界
  boolean isTouchingEdge() {
    return (position.x < 0 || position.x > width || position.y < 0 || position.y > height);
  }

  // 重置生命週期
  void resetLifeTime() {
    lifeTime = random(80, 100); // 隨機設置生命週期
    lifeTimeCount = 0; // 重置計數
  }
}
