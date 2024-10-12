class RandomImageSquare {
  float x, y;      // Position of the square
  float size;      // Initial size of the square
  float currentWidth, currentHeight;  // Current width and height of the image
  PImage img;      // Variable to store the image
  boolean isVisible; // Controls whether the image is visible
  boolean isShrink; // Determines if the image should start shrinking
  float borderSize; // Border size
  int frameCounter = 0;

  // Constructor: Initializes random attributes like position and size, and loads the first image
  RandomImageSquare() {
    x = random(100, width - 100);
    y = random(100, height - 100);
    size = random(80, 100); // Random size between 80 and 100
    currentWidth = 1; // Start small and grow
    currentHeight = 1;
    borderSize = 1; // Border width
    isVisible = true; // Image is visible initially
    isShrink = false;
    resetImage(new PVector(width / 2, height / 2)); // Load an image during initialization
  }

  // Updates the image size, makes it grow first, then shrink after reaching the desired size
  void update(PVector pos) {
    if (currentWidth < size * 2 && currentHeight < size * 2 && !isShrink) {
      // Grow the image until it reaches its maximum size
      currentWidth += 20;
      currentHeight += 20;
    } else {
      // Start shrinking after reaching the maximum size
      isShrink = true;
    }

    // Shrink the image step by step, and reload a new one once it's too small
    if (isShrink) {
      if (currentWidth > 5 && currentHeight > 5) {
        // Randomly decide whether to shrink width or height
        if (random(1) < 0.5) {
          currentWidth -= 5;
        } else {
          currentHeight -= 5;
        }
      } else {
        isVisible = false; // Hide the image once it's too small
        resetImage(pos); // Load a new image
      }
    }
  }

  // Loads a new image from the preloaded queue and resets size
  void resetImage(PVector p) {
    x = p.x + 10;
    y = p.y + 10;
    currentWidth = 1; // Reset to the starting size
    currentHeight = 1;
    isShrink = false; // Reset shrinking state

    // Pull an image from the queue if available, or log a failure
    if (imagesLoaded && images.size() > 0) {
      img = images.poll(); // Get and remove the oldest image from the queue
      isVisible = true; // Make the image visible again
    } else {
      println("Image load failed");
      img = null;
    }
  }

  // Displays the square with the image, first adding a white border and converting it to grayscale
  void display() {
    noFill();
    stroke(255);
    strokeWeight(1);
    rect(x - 10, y - 10, 15, 15); // Draw the surrounding square
    if (img != null && isVisible) {
      // Crop the image and convert it to grayscale
      float cropX = (size - currentWidth) / 2;
      float cropY = (size - currentHeight) / 2;
      PImage croppedImg = createImage(int(currentWidth), int(currentHeight), RGB);
      croppedImg.copy(img, int(cropX), int(cropY), int(currentWidth), int(currentHeight), 0, 0, int(currentWidth), int(currentHeight));

      // Convert the cropped image to grayscale
      for (int i = 0; i < croppedImg.width; i++) {
        for (int j = 0; j < croppedImg.height; j++) {
          color c = croppedImg.get(i, j);
          float r = red(c), g = green(c), b = blue(c);
          float gray = (r + g + b) / 3;
          croppedImg.set(i, j, color(gray)); // Set grayscale color
        }
      }

      // Add a white border around the grayscale image
      PImage borderedImg = createImage(int(currentWidth) + int(borderSize * 2), int(currentHeight) + int(borderSize * 2), RGB);
      borderedImg.loadPixels();
      for (int i = 0; i < borderedImg.width; i++) {
        for (int j = 0; j < borderedImg.height; j++) {
          if (i < borderSize || i >= borderedImg.width - borderSize || j < borderSize || j >= borderedImg.height - borderSize) {
            borderedImg.set(i, j, color(255)); // Set the border to white
          } else {
            borderedImg.set(i, j, croppedImg.get(i - int(borderSize), j - int(borderSize))); // Copy the grayscale image inside the border
          }
        }
      }
      borderedImg.updatePixels();

      // Display the image with a white border
      image(borderedImg, x, y); // Draw the bordered image
      filter(POSTERIZE, random(2, 7)); // Apply a posterize filter
    } else {
      // If no image is available, draw a gray rectangle as a placeholder
      fill(150);
      rect(x, y, currentWidth, currentHeight);
    }
  }
}
