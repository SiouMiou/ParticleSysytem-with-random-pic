// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Class to represent a point that follows a noise field
class Points {

  // Basic properties of the object
  private PVector position;
  private PVector velocity;
  private PVector acceleration;
  private float radius;
  private float maxForce;    // Maximum steering force
  private float maxSpeed;    // Maximum speed
  private float lifeTime;
  private boolean isSeparating = false;
  private float separatingSpeed = 3.5;
  private color colorV;
  private float vHue = 180;
  private float vS = 0;
  private float vAlpha = 40;
  private int lifeTimeCount = 0; // Lifetime counter
  int frameCount = 0; // Frame counter

  // Constructor: Initializes the point's position, speed, and force
  Points(PVector position, float maxSpeed, float maxForce) {
    colorMode(HSB, 360, 100, 100, 100);
    this.position = position.get();
    this.radius = 3.0f;
    this.maxSpeed = maxSpeed;
    this.maxForce = maxForce;
    this.acceleration = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    resetLifeTime(); // Initialize the lifetime
    colorV = color(vHue, vS, 50, vAlpha); // Default color
  }

  // Run the logic of the point (update position, check boundaries, and display)
  public void run() {
    update(); // Update position based on velocity
    borders(); // Handle screen boundaries
    updateBrightness(); // Adjust brightness over time
    display(); // Draw the point on the screen
    checkIfDead(); // Check if the point's lifetime has ended
    frameCount++;
    if (frameCount % 200 == 0) { // Every 200 frames, check brightness range
      checkBrightnessRange();
      frameCount = 0;
    }
  }

  // Makes the point follow the noise field by applying force based on noise direction
  void follow(NoiseField flow) {
    PVector desired = flow.lookup(position); // Get vector from the noise field
    desired.mult(maxSpeed); // Scale vector by max speed
    PVector steer = PVector.sub(desired, velocity); // Calculate steering force
    steer.limit(maxForce);  // Limit the steering force
    applyForce(steer); // Apply the force to acceleration
  }

  // Adds the applied force to the acceleration
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  // Updates the point's velocity and position
  void update() {
    velocity.add(acceleration); // Update velocity

    // Handle separation speed if needed
    if (isSeparating) {
      isSeparating = false; // Reset separation state
      velocity.limit(separatingSpeed); // Limit velocity during separation
    } else {
      velocity.limit(maxSpeed); // Regular velocity limit
    }

    position.add(velocity); // Update position
    acceleration.mult(0); // Reset acceleration after each update
    lifeTime -= 1; // Decrease the lifetime
    lifeTimeCount++;
  }

  // Draw the point on the screen
  void display() {
    colorMode(HSB, 360, 100, 100, 100);
    stroke(colorV); // Set stroke color
    strokeWeight(3);
    pushMatrix();
    translate(position.x, position.y);
    point(0, 0); // Draw the point
    popMatrix();
  }

  // Adjust the brightness of the point over time
  void updateBrightness() {
    if (lifeTimeCount == 30) {
      colorV = color(vHue, vS, 100, vAlpha);
    }
    
    float brightnessValue = brightness(colorV); // Get current brightness
    if (brightnessValue > 50) {
      // Decrease brightness gradually if it's over 50
      float newBrightness = brightnessValue - 1;
      colorV = color(vHue, vS, newBrightness, vAlpha);
    }
  }

  // Check if the point is within a specific range and adjust its brightness
  void checkBrightnessRange() {
    float rangeRadius = random(30, 60); // Random radius for brightness range
    
    // Define four central points
    PVector[] centers = {
        new PVector(500, 300),
        new PVector(1000, 200),
        new PVector(500, 750),
        new PVector(1000, 600)
    };

    // Check if the point is within range of any center
    for (PVector center : centers) {
        if (PVector.dist(position, center) < rangeRadius) {
            colorV = color(vHue, vS, random(80, 100), vAlpha); // Adjust brightness
            break;
        }
    }
  }

  // Checks if the point's lifetime has ended or if it is out of bounds, and resets it
  void checkIfDead() {
    if (lifeTime < 0 || isTouchingEdge()) {
      resetLifeTime(); // Reset lifetime
      // Randomly reposition the point
      float angle = random(TWO_PI);
      float r = random(100);
      float x = r * cos(angle);
      float y = r * sin(angle);
      position = new PVector(x + width / 2, y + height / 2);
     }
  }

  // Handles screen boundaries by wrapping the point around the edges
  void borders() {
    if (position.x < -radius) position.x = width + radius;
    if (position.y < -radius) position.y = height + radius;
    if (position.x > width + radius) position.x = -radius;
    if (position.y > height + radius) position.y = -radius;
  }

  // Checks if the point is touching the edges of the screen
  boolean isTouchingEdge() {
    return (position.x < 0 || position.x > width || position.y < 0 || position.y > height);
  }

  // Resets the point's lifetime to a random value
  void resetLifeTime() {
    lifeTime = random(80, 100);
    lifeTimeCount = 0;
  }
}
