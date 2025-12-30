import 'dart:math' as math;

class Vertice {
  final double x;
  final double y;
  final double z;

  Vertice({required this.x, required this.y, required this.z});

  Vertice rotateY(double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    double newX = x * cosA - z * sinA;
    double newZ = x * sinA + z * cosA;
    return Vertice(x: newX, y: y, z: newZ);
  }

  Vertice rotateX(double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    double newY = y * cosA - z * sinA;
    double newZ = y * sinA + z * cosA;
    return Vertice(x: x, y: newY, z: newZ);
  }

  Vertice rotateZ(double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    double newX = x * cosA - y * sinA;
    double newY = x * sinA + y * cosA;
    return Vertice(x: newX, y: newY, z: z);
  }
}
