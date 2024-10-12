class Box {
  PVector position; // The position of the box
  float size; // The size of the box
  int timer; // Timer for tracking updates
  int lifeTime; // The lifespan of the box before updating its position

  // Constructor: Initializes the box size, position, timer, and lifetime
  Box() {
    size = 15;
    position = new PVector(width / 2, height / 2); // Start position in the center of the canvas
    timer = 0;
    lifeTime = (int)random(50, 80); // Random lifetime for updating position
  }

  // Update: Moves the box to a new position after its lifetime expires
  void update(PVector p) {
    timer++;
    if (timer > lifeTime) {
      position = p; // Update position
      timer = 0; // Reset timer
      lifeTime = (int)random(30, 50); // Set new random lifetime
    }
  }

  // Display: Draws the box on the screen
  void display() {
    noFill(); // Transparent box
    stroke(200); // White stroke
    strokeWeight(1);
    rect(position.x - size / 2, position.y - size / 2, size, size); // Draw the box
  }
}
