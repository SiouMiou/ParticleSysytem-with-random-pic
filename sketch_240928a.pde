import spout.*;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
ArrayList<RandomImageSquare> squares = new ArrayList<RandomImageSquare>();
Queue<PImage> images = new LinkedList<PImage>();
boolean imagesLoaded = false; // Flag to indicate if images are loaded
final int MAX_IMAGES = 10; // Maximum number of images to load
// NoiseField object
NoiseField noiseField;
// An ArrayList of points
ArrayList<Points> points;
ArrayList<Box> boxes = new ArrayList<Box>(); // List of boxes
// Spout sender
Spout spout;

void setup() {
  size(1600, 1000, P2D);
  // Initialize noise field with resolution of 10
  noiseField = new NoiseField(10);
  points = new ArrayList<Points>();

  // Initialize Spout sender
  spout = new Spout(this);
  spout.setSenderName("Spout Sender");

  // Create 5000 random points with random radius and angle
  for (int i = 0; i < 5000; i++) {
      float angle = random(TWO_PI); // Random angle in radians
      float r = random(100); // Random radius
      float x = r * cos(angle); // x-coordinate based on angle and radius
      float y = r * sin(angle); // y-coordinate based on angle and radius
      PVector position = new PVector(x + width/2, y + height/2); // Center the position on the canvas
      points.add(new Points(position, random(2, 5), random(0.5, 0.8))); // Add point to the list
  }
  
  // Create 5 boxes
  for (int i = 0; i < 5; i++) {
    boxes.add(new Box());
  }
  
  // Create squares
  for (int i = 0; i < 1; i++) {
    squares.add(new RandomImageSquare());
  }

  // Load initial set of images until MAX_IMAGES is reached
  while(images.size() < MAX_IMAGES) {
     PImage img = loadImage("https://picsum.photos/" + (int)random(40, 60) + "/" + (int)random(40, 60) + ".jpg?random");
      if (img != null && img.width > 0 && img.height > 0) {
        synchronized (images) { // Synchronize to avoid conflicts when adding images
          images.add(img); // Add valid image to the queue
          println("Image loaded: " + images.size());
        }
      } else {
        println("Image load failed");
      }
  }
   imagesLoaded = true; // Set flag to true when initial images are loaded
}

void draw() {
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 0, 0); 
  
  // Update and draw each point
  for (Points p : points) {
    p.follow(noiseField); // Point follows the noise field
    p.run(); // Update the state and draw the point
  }
  
  // Update and draw each box based on random point positions
  for (Box box : boxes) {
    PVector pos = points.get((int)random(5000)).position; // Use random point positions for box updates
    box.update(pos);
    box.display(); 
  }

  if (imagesLoaded) {
    // Update and display image squares
    for (RandomImageSquare square : squares) {
      PVector pos = points.get((int)random(5000)).position;
      square.update(pos);
      square.display();
    }

    // Load more images if the number of loaded images is less than MAX_IMAGES
    if (images.size() < MAX_IMAGES) {
      loadImages(); // Load new images asynchronously
      noiseField.init(); // Reinitialize the noise field after loading new images
    }
  } else {
    // Display loading message until images are loaded
    fill(255);
    text("Loading", width / 2 - 50, height / 2);
  }

  spout.sendTexture(); // Send texture via Spout
}

// Asynchronous method to load images in a separate thread
void loadImages() {
  if(images.size() < MAX_IMAGES) {
    new Thread(() -> {
      PImage img = loadImage("https://picsum.photos/" + (int)random(40, 60) + "/" + (int)random(40, 60) + ".jpg?random");
      if (img != null && img.width > 0 && img.height > 0) {
        synchronized (images) { // Synchronize image queue to avoid conflicts
          images.add(img);
        }
      } else {
        println("Image load failed");
      }
    }).start(); 
  }
  
  imagesLoaded = true;
}

// Close the Spout sender when the program exits
void exit() {
  spout.closeSender();
}
