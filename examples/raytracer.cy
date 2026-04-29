Raytracer raytracer = Raytracer(500, 500)
raytracer.render()

void draw(int time)
  raytracer.draw()

class Raytracer
  int width
  int height
  Image img
  
  Sphere[] spheres
  Light[] lights
  Vector cameraOrigin

  void __init__(int w, int h)
    size("Raytracer", w, h)
    
    width = w
    height = h
    img = Image(width, height)
    cameraOrigin = Vector(0, 0, -1)
    
    Material matRed = Material(Vector(1, 0, 0), 0.1, 0.9, 0.5, 32)
    Material matSilver = Material(Vector(0, 0, 0), 0, 0, 0.8, 64)
    Material matGreen = Material(Vector(0, 1, 0), 0.1, 0.8, 0.2, 10)
    Material matGround = Material(Vector(0.8, 0.8, 0.8), 0.2, 0.8, 0, 0)

    spheres.push(Sphere(Vector(0, 0, 3), 1, matRed))
    spheres.push(Sphere(Vector(-1.75, -0.5, 4), 0.5, matSilver))
    spheres.push(Sphere(Vector(2.5, 0.5, 5), 1.5, matGreen))
    spheres.push(Sphere(Vector(0.0, -101.0, 3), 100, matGround)) 
    
    lights.push(Light(Vector(-5, 5, -5), Vector(1, 1, 1)))
    lights.push(Light(Vector(5, 2, -3), Vector(0.5, 0.5, 1)))

  void draw()
    img.draw()

  void render()
    int index
    
    for int y; y < height; y += 1
      for int x; x < width; x += 1
        float u = (float)x / (float)width - 0.5
        float v = (float)(height - y) / (float)height - 0.5 
        
        Vector rayDirection = Vector(u, v, 1).normalized()
        Ray primaryRay = Ray(cameraOrigin, rayDirection)

        Vector color = trace(primaryRay, 5) 

        img.data[index] = (char)(int)(clamp(color.x, 0, 1) * 255)
        img.data[index + 1] = (char)(int)(clamp(color.y, 0, 1) * 255)
        img.data[index + 2] = (char)(int)(clamp(color.z, 0, 1) * 255)

        index += 3
  
  Vector trace(Ray ray, int depth)
    if depth <= 0
      return Vector() 

    HitRecord closestHit = HitRecord(-1.0, Vector(), Vector(), null)
    float closestSoFar = 10000 

    for int i = 0; i < spheres.length; i += 1
      HitRecord rec = spheres[i].hit(ray, 0.001, closestSoFar)
      if rec.t > 0
        closestSoFar = rec.t
        closestHit = rec

    if closestHit.t > 0
      return calculateLighting(closestHit, ray, depth)
    else
      Vector unitDirection = ray.direction.normalized()
      float t = 0.5 * (unitDirection.y + 1)
      return Vector(1.0, 1.0, 1.0).scale(1.0 - t) + Vector(0.5, 0.7, 1).scale(t)

  Vector calculateLighting(HitRecord rec, Ray ray, int depth)
    Vector finalColor = rec.material.color.scale(rec.material.ambient)
    Vector viewDir = (ray.origin - rec.p).normalized()

    for int i = 0; i < lights.length; i += 1
      Vector lightDir = (lights[i].position - rec.p).normalized()
      
      Ray shadowRay = Ray(rec.p, lightDir)
      bool inShadow = false
      for int j = 0; j < spheres.length; j += 1
        HitRecord shadowRec = spheres[j].hit(shadowRay, 0.001, 10000.0)
        if shadowRec.t > 0
          inShadow = true
          break 
      
      if not inShadow
        float diff = max(0, rec.normal.dot(lightDir))
        Vector diffuse = rec.material.color.scale(diff * rec.material.diffuse)
        
        Vector reflectDir = lightDir.scale(-1) - rec.normal.scale(2 * lightDir.scale(-1).dot(rec.normal))
        float spec = pow(max(0.0, reflectDir.dot(viewDir)), rec.material.shininess)
        Vector specular = lights[i].color.scale(spec * rec.material.specular)

        finalColor = finalColor + diffuse + specular
    
    if rec.material.specular > 0.1 and rec.material.shininess > 0
        Vector reflectDir = ray.direction - rec.normal.scale(2 * ray.direction.dot(rec.normal))
        Ray reflectedRay = Ray(rec.p, reflectDir)
        Vector reflectionColor = trace(reflectedRay, depth - 1)
        finalColor = finalColor + reflectionColor.scale(rec.material.specular)

    return finalColor

class Ray
  Vector origin
  Vector direction

  void __init__(Vector origin, Vector direction)
    this.origin = origin
    this.direction = direction.normalized() 
  
  Vector at(float t)
    return origin + direction.scale(t)

class Material
  Vector color      
  float ambient    
  float diffuse    
  float specular   
  float shininess  

  void __init__(Vector color, float ambient, float diffuse, float specular, float shininess)
    this.color = color
    this.ambient = ambient
    this.diffuse = diffuse
    this.specular = specular
    this.shininess = shininess

class Light
  Vector position
  Vector color

  void __init__(Vector position, Vector color)
    this.position = position
    this.color = color

class HitRecord
  float t
  Vector p
  Vector normal
  Material material

  void __init__(float t, Vector p, Vector normal, Material material)
    this.t = t
    this.p = p
    this.normal = normal
    this.material = material

class Sphere
  Vector center
  Material material
  float radius

  void __init__(Vector center, float radius, Material material)
    this.center = center
    this.radius = radius
    this.material = material  
  
  HitRecord hit(Ray r, float t_min, float t_max)
    Vector oc = r.origin - center
    float a = r.direction.dot(r.direction)
    float b = 2 * oc.dot(r.direction)
    float c = oc.dot(oc) - radius * radius
    float discriminant = b*b - 4 * a * c

    if discriminant > 0
      float temp = (-b - discriminant.sqrt()) / (2 * a)
      if temp < t_max and temp > t_min
        Vector hitPoint = r.at(temp)
        Vector normal = (hitPoint - center).normalized()
        return HitRecord(temp, hitPoint, normal, material)
      
      temp = (-b + discriminant.sqrt()) / (2 * a)
      if temp < t_max and temp > t_min
        Vector hitPoint = r.at(temp)
        Vector normal = (hitPoint - center).normalized()
        return HitRecord(temp, hitPoint, normal, material)

    return HitRecord(-1, Vector(), Vector(), material)

class Vector
  float x
  float y
  float z

  void __init__()
  void __init__(float x, float y, float z)
    this.x = x
    this.y = y
    this.z = z

  Vector __add__(Vector other)
    return Vector(x + other.x, y + other.y, z + other.z)

  Vector __sub__(Vector other)
    return Vector(x - other.x, y - other.y, z - other.z)

  float lengthSquared()
    return x * x + y * y + z * z

  float length()
    return lengthSquared().sqrt()
    
  Vector normalized()
    float l = length()
    if l > 0.0
      return Vector(x / l, y / l, z / l)
    return Vector(0.0, 0.0, 0.0)
  
  Vector scale(float s)
    return Vector(x * s, y * s, z * s)
 
  float dot(Vector other)
    return x * other.x + y * other.y + z * other.z
  
  Vector cross(Vector other)
    return Vector(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x
    )

float clamp(float val, float min, float max)
  if val < min
    return min
  
  if val > max
    return max

  return val

float max(float a, float b)
  if a > b
      return a
  return b
