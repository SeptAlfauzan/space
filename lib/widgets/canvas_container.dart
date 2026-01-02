import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:space/entities/pos.dart';
import 'package:space/entities/shape3d.dart';
import 'package:space/entities/vertice.dart';

class CanvasContainer extends StatefulWidget {
  const CanvasContainer({super.key});

  @override
  State<CanvasContainer> createState() => CanvasContainerState();
}

class CanvasContainerState extends State<CanvasContainer>
    with SingleTickerProviderStateMixin {
  final int durationMs = 20000;
  bool _lockXAxis = false;
  bool _lockYAxis = false;
  late Shape3D shape;
  late AnimationController _controller;

  double xPos = 0;
  double yPos = 0;

  void changeShape(Shape3D newShape) {
    setState(() {
      shape = newShape;
      _resetPositions();
    });
  }

  void resetRotationAngle() {
    setState(() {
      _resetPositions();
    });
  }

  void _resetPositions() {
    xPos = 0;
    yPos = 0;
  }

  bool toggleLockXAxis() {
    setState(() {
      _lockXAxis = !_lockXAxis;
    });
    return _lockXAxis;
  }

  bool toggleLockYAxis() {
    setState(() {
      _lockYAxis = !_lockYAxis;
    });
    return _lockYAxis;
  }

  @override
  void initState() {
    super.initState();

    // shape = Shape3D.rocket().rotateZ(-math.pi / 4);
    shape = Shape3D.sphere();

    _controller = AnimationController(
      duration: Duration(milliseconds: durationMs),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Pos normalizeSwipe(Size screenSize, double x, double y) {
    final centerScreen = Size(screenSize.width / 2, screenSize.height / 2);
    final double normalizeX =
        x == centerScreen.width
            ? 0
            : x > centerScreen.width
            ? 1
            : -1;
    final double normalizeY =
        y == centerScreen.height
            ? 0
            : y > centerScreen.height
            ? 1
            : -1;

    return Pos(x: normalizeX, y: normalizeY);
  }

  double _getRotationAngle(double pos) {
    return pos * 2 * math.pi;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final swipeSpeed = 500;
    return GestureDetector(
      onPanUpdate: (detail) {
        final normalizePos = normalizeSwipe(
          screenSize,
          detail.globalPosition.dx,
          detail.globalPosition.dy,
        );

        if (!_lockXAxis && !_lockYAxis) {
          setState(() {
            // Normalize to range 0.0 - 1.0
            // xPos = detail.globalPosition.dx / screenSize.width;
            // yPos = detail.globalPosition.dy / screenSize.height;
            xPos += (normalizePos.x * 0.005);
            yPos += (normalizePos.y * 0.005);
          });
        } else {
          if (_lockXAxis && !_lockYAxis) {
            setState(() {
              yPos += (normalizePos.y * 0.005);
            });
          }

          if (_lockYAxis && !_lockXAxis) {
            setState(() {
              xPos += (normalizePos.x * 0.005);
            });
          }
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // double animationValue = _controller.value;
          // Rotate the shape based on normalized position
          double angleY = _getRotationAngle(xPos); // Full rotation on X drag
          double angleX = _getRotationAngle(yPos); // Full rotation on Y drag
          final animatedShape = shape.rotateX(angleX).rotateY(angleY);
          return Center(
            child: CustomPaint(
              painter: DrawingPainter(
                edgeColor: Colors.grey[700],
                color: Colors.white,
                vertices: animatedShape.vertices,
                edges: animatedShape.edges,
              ),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Vertice> vertices;
  final List<List<int>> edges;
  final Color color;
  final double focalLength;
  final Color? edgeColor;

  DrawingPainter({
    required this.color,
    required this.vertices,
    required this.edges,
    this.edgeColor,
    this.focalLength = 300,
  });

  // Project 3D point to 2D using perspective
  Offset project(Vertice v, Offset center) {
    // Move the camera back
    double z = v.z + focalLength;
    double scale = focalLength / z;
    return Offset(center.dx + v.x * scale, center.dy + v.y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final double verticeSize = 4;
    // Paint for edges

    // Paint for vertices
    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw edges
    for (var edge in edges) {
      final firstEdgeOnBack = vertices[edge[0]].z > 0;
      final lastEdgeOnBack = vertices[edge[1]].z > 0;
      final alpha = firstEdgeOnBack && lastEdgeOnBack ? 80 : 255;
      final linePaint =
          Paint()
            ..color = edgeColor?.withAlpha(alpha) ?? color.withAlpha(alpha)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
      final p1 = project(vertices[edge[0]], center);
      final p2 = project(vertices[edge[1]], center);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Draw vertices as small circles
    for (var vertex in vertices) {
      final projected = project(vertex, center);
      final rect = Rect.fromCenter(
        center: projected,
        width: verticeSize,
        height: verticeSize,
      );
      canvas.drawRect(rect, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
