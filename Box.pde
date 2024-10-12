class Box {
  PVector position; // 方框的位置
  float size; // 方框的大小
  int timer; // 用於計時
  int lifeTime;
  // 構造函數，初始化方框
  Box() {
    size = 15; // 設置方框大小
    position =new PVector(width/2,height/2); // 初始化位置
    timer = 0; // 初始化計時器
    lifeTime = (int)random(50,80);
  }

  // 更新方框位置
  void update(PVector p) {
    timer++;
    if (timer > lifeTime) { // 每60幀更換一次位置
      position = p; // 隨機獲取新位置
      timer = 0; // 重置計時器
      lifeTime = (int)random(30,50);
    }
  }

 

  // 顯示方框
  void display() {
    noFill(); // 透明
    stroke(200); // 邊框顏色為白色
    strokeWeight(1); // 邊框粗細為1
    rect(position.x - size / 2, position.y - size / 2, size, size); // 繪製方框
  }
}
