import "common/math.cy"

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
  Vector3 cameraOrigin

  void __init__(int w, int h)
    size("Raytracer", w, h)
    
    width = w
    height = h
    img = Image(width, height)
    cameraOrigin = Vector3(0, 0, -1)
    
    Material matRed = Material(Vector3(1, 0, 0), 0.1, 0.9, 0.5, 32)
    Material matSilver = Material(Vector3(0, 0, 0), 0, 0, 0.8, 64)
    Material matGreen = Material(Vector3(0, 1, 0), 0.1, 0.8, 0.2, 10)
    Material matGround = Material(Vector3(0.8, 0.8, 0.8), 0.2, 0.8, 0, 0)

    spheres.push(Sphere(Vector3(0, 0, 3), 1, matRed))
    spheres.push(Sphere(Vector3(-1.75, -0.5, 4), 0.5, matSilver))
    spheres.push(Sphere(Vector3(2.5, 0.5, 5), 1.5, matGreen))
    spheres.push(Sphere(Vector3(0.0, -101.0, 3), 100, matGround)) 
    
    lights.push(Light(Vector3(-5, 5, -5), Vector3(1, 1, 1)))
    lights.push(Light(Vector3(5, 2, -3), Vector3(0.5, 0.5, 1)))

  void draw()
    img.draw()

  void render()
    int index
    
    for int y; y < height; y += 1
      for int x; x < width; x += 1
        float u = (float)x / (float)width - 0.5
        float v = (float)(height - y) / (float)height - 0.5 
        
        Vector3 rayDirection = Vector3(u, v, 1).normalize()
        Ray primaryRay = Ray(cameraOrigin, rayDirection)

        Vector3 color = trace(primaryRay, 5) 

        img.data[index] = (char)(int)(clamp(color.x, 0, 1) * 255)
        img.data[index + 1] = (char)(int)(clamp(color.y, 0, 1) * 255)
        img.data[index + 2] = (char)(int)(clamp(color.z, 0, 1) * 255)

        index += 3
  
  Vector3 trace(Ray ray, int depth)
    if depth <= 0
      return Vector3() 

    HitRecord closestHit = HitRecord(-1.0, Vector3(), Vector3(), null)
    float closestSoFar = 10000 

    for int i = 0; i < spheres.length; i += 1
      HitRecord rec = spheres[i].hit(ray, 0.001, closestSoFar)
      if rec.t > 0
        closestSoFar = rec.t
        closestHit = rec

    if closestHit.t > 0
      return calculateLighting(closestHit, ray, depth)
    else
      Vector3 unitDirection = ray.direction.normalize()
      float t = 0.5 * (unitDirection.y + 1)
      return Vector3(1.0, 1.0, 1.0).scale(1.0 - t) + Vector3(0.5, 0.7, 1).scale(t)

  Vector3 calculateLighting(HitRecord rec, Ray ray, int depth)
    Vector3 finalColor = rec.material.color.scale(rec.material.ambient)
    Vector3 viewDir = (ray.origin - rec.p).normalize()

    for int i = 0; i < lights.length; i += 1
      Vector3 lightDir = (lights[i].position - rec.p).normalize()
      
      Ray shadowRay = Ray(rec.p, lightDir)
      bool inShadow = false
      for int j = 0; j < spheres.length; j += 1
        HitRecord shadowRec = spheres[j].hit(shadowRay, 0.001, 10000.0)
        if shadowRec.t > 0
          inShadow = true
          break 
      
      if not inShadow
        float diff = max(0, rec.normal.dot(lightDir))
        Vector3 diffuse = rec.material.color.scale(diff * rec.material.diffuse)
        
        Vector3 reflectDir = lightDir.scale(-1) - rec.normal.scale(2 * lightDir.scale(-1).dot(rec.normal))
        float spec = pow(max(0.0, reflectDir.dot(viewDir)), rec.material.shininess)
        Vector3 specular = lights[i].color.scale(spec * rec.material.specular)

        finalColor = finalColor + diffuse + specular
    
    if rec.material.specular > 0.1 and rec.material.shininess > 0
        Vector3 reflectDir = ray.direction - rec.normal.scale(2 * ray.direction.dot(rec.normal))
        Ray reflectedRay = Ray(rec.p, reflectDir)
        Vector3 reflectionColor = trace(reflectedRay, depth - 1)
        finalColor = finalColor + reflectionColor.scale(rec.material.specular)

    return finalColor

class Ray
  Vector3 origin
  Vector3 direction

  void __init__(Vector3 origin, Vector3 direction)
    this.origin = origin
    this.direction = direction.normalize() 
  
  Vector3 at(float t)
    return origin + direction.scale(t)

class Material
  Vector3 color      
  float ambient    
  float diffuse    
  float specular   
  float shininess  

  void __init__(Vector3 color, float ambient, float diffuse, float specular, float shininess)
    this.color = color
    this.ambient = ambient
    this.diffuse = diffuse
    this.specular = specular
    this.shininess = shininess

class Light
  Vector3 position
  Vector3 color

  void __init__(Vector3 position, Vector3 color)
    this.position = position
    this.color = color

class HitRecord
  float t
  Vector3 p
  Vector3 normal
  Material material

  void __init__(float t, Vector3 p, Vector3 normal, Material material)
    this.t = t
    this.p = p
    this.normal = normal
    this.material = material

class Sphere
  Vector3 center
  Material material
  float radius

  void __init__(Vector3 center, float radius, Material material)
    this.center = center
    this.radius = radius
    this.material = material  
  
  HitRecord hit(Ray r, float t_min, float t_max)
    Vector3 oc = r.origin - center
    float a = r.direction.dot(r.direction)
    float b = 2 * oc.dot(r.direction)
    float c = oc.dot(oc) - radius * radius
    float discriminant = b*b - 4 * a * c

    if discriminant > 0
      float temp = (-b - discriminant.sqrt()) / (2 * a)
      if temp < t_max and temp > t_min
        Vector3 hitPoint = r.at(temp)
        Vector3 normal = (hitPoint - center).normalize()
        return HitRecord(temp, hitPoint, normal, material)
      
      temp = (-b + discriminant.sqrt()) / (2 * a)
      if temp < t_max and temp > t_min
        Vector3 hitPoint = r.at(temp)
        Vector3 normal = (hitPoint - center).normalize()
        return HitRecord(temp, hitPoint, normal, material)

    return HitRecord(-1, Vector3(), Vector3(), material)
