
import java.util.List;
import java.util.LinkedList;

// earth 5.972 × 10^24
// 5972000000000000000000000
// sun 1.989 × 10^30 kg
// distance from earth to sun 92.96 million mi = 149604618240 m
// velocity of earth relative to sun 30 kilometers per second
// 30000 m/s, .000030000
// earth radius 6,371 km
// sun radius 695,700 km

double metersEarthRadius = 6371000.0;
double metersSecondEarthSpeed = 30000.0;
double metersEarthDistanceToSun = 149604618240.0;
double kgEarthMass = 5972000000000000000000000.0;
double kgSunMass = 1989000000000000000000000000000.0;
double metersSunRadius = 695700000.0;
double kgMoon = 73476730900000000000000.0;
double metersMoonDistanceToEarth = 384400000.0;
double metersSecondMoonRelativeToEarth = 1000; //3,683 kilometers per hour
double metersMoonRadius = 1737000;

GravityModel gravityModel = new GravityModel();

ArrayList<Object> universe = new ArrayList<Object>();

double renderScale = 0.000000001;

Object sun = new Object(
  gravityModel,
  kgSunMass / 2,
  0, 0,
  0, -metersSecondEarthSpeed,
  metersSunRadius,
  color(0, 255, 0));
  
Object moon = new Object(
  gravityModel,
  kgMoon,
  metersEarthDistanceToSun + metersMoonDistanceToEarth, 0,
  0, -metersSecondEarthSpeed + metersSecondMoonRelativeToEarth,
  metersMoonRadius,
  color(0, 0, 255));
  
Object earth = new Object(
  gravityModel,
  kgEarthMass,
  metersEarthDistanceToSun, 0,
  0, -metersSecondEarthSpeed,
  metersEarthRadius,
  color(255, 0, 255));
    
void setup()
{
  size(1200, 800);

  universe.add(earth);
  universe.add(sun);
  universe.add(moon);

  double size = random(0.5, 1.5);
  universe.add(new Object(
    gravityModel,
    kgSunMass / 2,
    (metersSunRadius + metersSunRadius * size) * 25, 0,
    0, metersSecondEarthSpeed,
    metersSunRadius,
    color(0, 255, 0)));
    
  for (int i = 0; i < 10; i++)
  {
    double bodySize = random(0.25, 10);
    universe.add(new Object(
      gravityModel,
      kgEarthMass * bodySize,
      metersEarthDistanceToSun * random(0.25, 1.5), 0,
      0, -metersSecondEarthSpeed * random(0.5, 1.5),
      metersEarthRadius * bodySize,
      color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)))));
  }
}


void draw()
{
  background(0);
  stroke(255);
  translate(width/2, height/2);
  scale((float)renderScale);  

  for (Object obj : universe) {
    obj.draw();
  }
  
  for (int i = 0; i < 1000; i++)
  {
    for (Object obj : universe) {
      obj.updateForces(universe);
    }
  
    for (Object obj : universe) {
      obj.applyForces(100.0);
    }
  }
}

class GravityModel
{
  GravityModel()
  {
    G = 0.00000000006674;
  }
  
  double calculateForceBetweenMasses(double mass1, double mass2, double distance)
  {
    return (G * mass1 * mass2) / (distance * distance);
  }
  
  double G;
}

class Object
{
  Object(GravityModel gravityModel, double kgMass, double x, double y, double vx, double vy, double mRadius, color tracerColor) {
    this.gravityModel = gravityModel;
    this.kgMass = kgMass;
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.mRadius = mRadius;
    this.tracerColor = tracerColor;
  }
  
  void updateForces(List<Object> universe)
  {
    fx = 0;
    fy = 0;

    for (Object body : universe)
    {
      if (body != this)
      {
        PVector bodyPosition = new PVector((float)body.x, (float)body.y);
        PVector selfPosition = new PVector((float)this.x, (float)this.y);
        PVector displacement = bodyPosition.sub(selfPosition);
        
        double force = gravityModel.calculateForceBetweenMasses(this.kgMass, body.kgMass, displacement.mag());
        PVector forceVector = displacement.normalize().mult((float)force);
       
        fx += forceVector.x;
        fy += forceVector.y;
      }
    }
  }
  
  void applyForces(double time)
  {
    double ax = fx / kgMass;
    double ay = fy / kgMass;
    x += vx * time;
    y += vy * time;
    vx += ax * time;
    vy += ay * time;
  }
  
  void draw()
  {
    fill(255);
    stroke(255);
    ellipse((float)x, (float)y, (float)(mRadius*10), (float)(mRadius*10));
    noFill();
    beginShape();
    positionHistory.add(new PVector((float)x, (float)y));
    if (positionHistory.size() > 10000)
    {
      positionHistory.removeFirst();
    }
    for (PVector history : positionHistory)
    {
      stroke(tracerColor);
      vertex(history.x, history.y);
    }
    endShape();
  }
  
  double kgMass;
  double x;
  double y;
  double vx;
  double vy;
  double fx;
  double fy;
  double mRadius;
  GravityModel gravityModel;
  LinkedList<PVector> positionHistory = new LinkedList<PVector>();
  color tracerColor;
}