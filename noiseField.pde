// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Class representing a noise field
class NoiseField {

  // The noise field is a 2D array of PVectors
  PVector[][] field;

  int cols, rows; // Number of columns and rows
  int resolution; // Size of each noise field cell
  float margin = 100; // Margin for the noise field boundaries

  // Constructor: Initializes the noise field based on resolution
  NoiseField(int r) {
    resolution = r;
    // Calculate number of columns and rows based on canvas size
    cols = width / resolution;
    rows = height / resolution;
    field = new PVector[cols][rows]; // Initialize the noise field array
    init(); // Initialize the noise vectors
  }

  // Initializes the noise field vectors
  public void init() {
    println("reset noise");
    noiseSeed((int)random(4000)); // Reset noise seed for new randomness
    float offsetValue = random(0.12, 0.17); // Random offset for noise
    float xoff = 0; // X-axis noise offset
    for (int i = 0; i < cols; i++) {
      float yoff = 0; // Y-axis noise offset
      for (int j = 0; j < rows; j++) {
        // Generate angle based on noise
        float theta = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
        
        // Determine direction based on position in the field
        float x = i * resolution;
        float y = j * resolution;
        PVector direction;

        // Direction changes based on which quadrant the point is in
        if (x > width / 2 && y > height / 2) {
          direction = new PVector(1, 1); // Top-right
        } else if (x < width / 2 && y > height / 2) {
          direction = new PVector(-1, 1); // Top-left
        } else if (x < width / 2 && y < height / 2) {
          direction = new PVector(-1, -1); // Bottom-left
        } else {
          direction = new PVector(1, -1); // Bottom-right
        }

        // Combine noise direction with the determined direction
        PVector noiseVector = new PVector(cos(theta), sin(theta));
        field[i][j] = PVector.add(direction, noiseVector.mult(0.9)); // Blend noise with direction
        field[i][j].normalize(); // Normalize the vector

        yoff += offsetValue; // Increment Y-axis noise offset
      }
      xoff += offsetValue; // Increment X-axis noise offset
    }
  }

  // Updates the noise field state (currently does nothing)
  void update() {
    // No state updates for now
  }

  // Displays each vector in the noise field as an arrow
  void display() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        drawVector(field[i][j], i * resolution + 20, j * resolution + 20, resolution - 2);
      }
    }
  }

  // Draws a vector as an arrow
  void drawVector(PVector v, float x, float y, float scayl) {
    colorMode(HSB, 360, 100, 100, 100); // Set color mode
    pushMatrix(); // Save the current transformation matrix

    translate(x, y); // Move to the drawing position
    stroke(0, 0, 60, 70); // Set stroke color
    strokeWeight(2); // Set stroke weight
    rotate(v.heading2D()); // Rotate to match the vector direction
    float len = v.mag() * scayl / 2; // Calculate arrow length
    line(0, 0, len, 0); // Draw the line for the arrow
    popMatrix(); // Restore the transformation matrix
  }

  // Returns the noise vector for a given position
  PVector lookup(PVector lookup) {
    int column = int(constrain(lookup.x / resolution, 0, cols - 1));
    int row = int(constrain(lookup.y / resolution, 0, rows - 1));
    return field[column][row].get(); // Return the vector at the specified position
  }
}
