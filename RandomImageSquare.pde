class RandomImageSquare {
  float x, y;      // 方形的位置
  float size;      // 方形的初始大小
  float currentWidth, currentHeight;  // 圖片當前的寬度和高度
  PImage img;      // 存放圖片的變數
  boolean isVisible; // 用於控制圖片的顯示
  boolean isShrink; // 是否開始縮小
  float borderSize; // 邊框大小
  int frameCounter = 0;
  // 類別的建構子，初始化方形的隨機屬性
  RandomImageSquare() {
    // 隨機生成位置 (x, y)
    x = random(100,width-100);
    y = random(100,height-100);
    // 隨機生成方形大小，範圍在 40 到 60 之間
    size = random(80, 100);
    // 初始化當前的寬度和高度
    currentWidth = 1; // 從 1 開始
    currentHeight = 1; // 從 1 開始
    borderSize = 1; // 設置邊框大小
    isVisible = true; // 初始時圖片是可見的
    isShrink = false;
    resetImage(new PVector(width/2,height/2)); // 在建構子中呼叫 resetImage()
  }

  // 更新圖片裁切的邏輯
  void update(PVector pos) {
    
    // 將圖片從 1,1 放大到指定的大小
    if (currentWidth < size*2 && currentHeight < size*2 && !isShrink) {
      currentWidth += 20;  // 放大寬度
      currentHeight += 20; // 放大高度
    } else {
      // 當達到指定大小後開始縮小
      isShrink = true;
    }

    // 如果已經開始縮小，則逐漸遞減寬度或高度
    if (isShrink) {
      if (currentWidth > 5 && currentHeight > 5) { // 確保不會縮小到負值
        // 隨機決定是縮小寬度還是高度
        if (random(1) < 0.5) {
          currentWidth -= 5;  // 遞減寬度
        } else {
          currentHeight -= 5;  // 遞減高度
        }
      } else {
        // 如果寬度或高度小於或等於 0，則隱藏圖片並重新載入新圖片
        isVisible = false; // 隱藏圖片
        resetImage(pos); // 重新生成圖片  
      }
    }
  }

  // 重新生成圖片並隨機選擇預先加載的圖像
  void resetImage(PVector p) {
    
    x = p.x+10;
    y = p.y+10;
    currentWidth = 1; // 重置為 1
    currentHeight = 1; // 重置為 1
    isShrink = false;

    // 從隊列中隨機選擇一張預先加載的圖片
    if (imagesLoaded && images.size() > 0) {
      img = images.poll(); // 從隊列中獲取並移除最舊的圖像
      isVisible = true; // 重置後顯示圖片
    } else {
      println("圖片加載失敗");
      img = null; // 加載失敗時設置 img 為 null
    }
  }
  
  // 顯示方形及圖片
  void display() {
    noFill();
    stroke(255);
    strokeWeight(1); 
    rect(x-10, y-10, 15,15);
    if (img != null && isVisible) { // 確保只有在可見時才顯示圖片
      // 計算裁剪位置
      float cropX = (size - currentWidth) / 2;
      float cropY = (size - currentHeight) / 2;

      // 使用 copy() 方法進行裁切
      PImage croppedImg = createImage(int(currentWidth), int(currentHeight), RGB);
      croppedImg.copy(img, int(cropX), int(cropY), int(currentWidth), int(currentHeight), 0, 0, int(currentWidth), int(currentHeight));

      // 將圖片轉換為黑白
      for (int i = 0; i < croppedImg.width; i++) {
        for (int j = 0; j < croppedImg.height; j++) {
          color c = croppedImg.get(i, j);
          float r = red(c);
          float g = green(c);
          float b = blue(c);
          // 計算灰度
          float gray = (r + g + b) / 3;
          croppedImg.set(i, j, color(gray)); // 設置為黑白
        }
      }
      
      // 創建一個新圖像來添加白邊
      PImage borderedImg = createImage(int(currentWidth) + int(borderSize * 2), int(currentHeight) + int(borderSize * 2), RGB); // 設置邊框大小
      borderedImg.loadPixels(); // 加載像素
      for (int i = 0; i < borderedImg.width; i++) {
        for (int j = 0; j < borderedImg.height; j++) {
          if (i < borderSize || i >= borderedImg.width - borderSize || j < borderSize || j >= borderedImg.height - borderSize) {
            borderedImg.set(i, j, color(255)); // 設置邊框為白色
          } else {
            borderedImg.set(i, j, croppedImg.get(i - int(borderSize), j - int(borderSize))); // 將圖片複製到邊框內部
          }
        }
      }
      borderedImg.updatePixels(); // 更新像素
      
      // 顯示帶有白邊的黑白圖片
      image(borderedImg, x, y); // 顯示帶邊框的圖片
      filter(POSTERIZE, random(2,7));
    } else {
      // 如果圖片載入失敗，顯示一個灰色的方形作為替代
      fill(150);
      rect(x, y, currentWidth, currentHeight);
    }
  }
}
