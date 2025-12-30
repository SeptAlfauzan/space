import 'dart:math' as math;

import 'package:space/entities/vertice.dart';

class Shape3D {
  final List<Vertice> vertices;
  final List<List<int>> edges;

  Shape3D({required this.vertices, required this.edges});

  /// Creates a cube centered at origin
  factory Shape3D.cube({double size = 100}) {
    final double half = size / 2;
    final vertices = [
      // Front face (z = half)
      Vertice(x: -half, y: -half, z: half), // 0: front top-left
      Vertice(x: half, y: -half, z: half), // 1: front top-right
      Vertice(x: half, y: half, z: half), // 2: front bottom-right
      Vertice(x: -half, y: half, z: half), // 3: front bottom-left
      // Back face (z = -half)
      Vertice(x: -half, y: -half, z: -half), // 4: back top-left
      Vertice(x: half, y: -half, z: -half), // 5: back top-right
      Vertice(x: half, y: half, z: -half), // 6: back bottom-right
      Vertice(x: -half, y: half, z: -half), // 7: back bottom-left
    ];
    final edges = [
      // Front face edges
      [0, 1], [1, 2], [2, 3], [3, 0],
      // Back face edges
      [4, 5], [5, 6], [6, 7], [7, 4],
      // Connecting edges (front to back)
      [0, 4], [1, 5], [2, 6], [3, 7],
    ];
    return Shape3D(vertices: vertices, edges: edges);
  }

  /// Creates a sphere centered at origin
  factory Shape3D.sphere({
    double radius = 80,
    int latitudeSegments = 12,
    int longitudeSegments = 24,
  }) {
    final vertices = <Vertice>[];
    final edges = <List<int>>[];

    // Generate sphere vertices using spherical coordinates
    for (int lat = 0; lat <= latitudeSegments; lat++) {
      double theta = lat * math.pi / latitudeSegments;
      double sinTheta = math.sin(theta);
      double cosTheta = math.cos(theta);

      for (int lon = 0; lon <= longitudeSegments; lon++) {
        double phi = lon * 2 * math.pi / longitudeSegments;
        double sinPhi = math.sin(phi);
        double cosPhi = math.cos(phi);

        double x = radius * sinTheta * cosPhi;
        double y = radius * cosTheta;
        double z = radius * sinTheta * sinPhi;

        vertices.add(Vertice(x: x, y: y, z: z));
      }
    }

    // Generate edges
    for (int lat = 0; lat < latitudeSegments; lat++) {
      for (int lon = 0; lon < longitudeSegments; lon++) {
        int current = lat * (longitudeSegments + 1) + lon;
        int next = current + longitudeSegments + 1;

        // Horizontal edge (along latitude)
        edges.add([current, current + 1]);
        // Vertical edge (along longitude)
        edges.add([current, next]);
      }
    }

    return Shape3D(vertices: vertices, edges: edges);
  }

  /// Creates a rocket shape 🚀 centered at origin
  factory Shape3D.rocket({
    double height = 150,
    double bodyRadius = 20,
    int segments = 8,
  }) {
    final vertices = <Vertice>[];
    final edges = <List<int>>[];

    final noseHeight = height * 0.3;
    final bodyHeight = height * 0.5;
    final finHeight = height * 0.2;
    final finWidth = bodyRadius * 1.5;

    // Nose tip (vertex 0)
    vertices.add(Vertice(x: 0, y: -height / 2, z: 0));

    // Nose base ring (vertices 1 to segments)
    for (int i = 0; i < segments; i++) {
      double angle = i * 2 * math.pi / segments;
      double x = bodyRadius * math.cos(angle);
      double z = bodyRadius * math.sin(angle);
      double y = -height / 2 + noseHeight;
      vertices.add(Vertice(x: x, y: y, z: z));
    }

    // Body bottom ring (vertices segments+1 to 2*segments)
    for (int i = 0; i < segments; i++) {
      double angle = i * 2 * math.pi / segments;
      double x = bodyRadius * math.cos(angle);
      double z = bodyRadius * math.sin(angle);
      double y = -height / 2 + noseHeight + bodyHeight;
      vertices.add(Vertice(x: x, y: y, z: z));
    }

    // Edges: nose tip to nose base ring
    for (int i = 0; i < segments; i++) {
      edges.add([0, i + 1]);
    }

    // Edges: nose base ring
    for (int i = 0; i < segments; i++) {
      edges.add([i + 1, (i + 1) % segments + 1]);
    }

    // Edges: body vertical lines (nose base to body bottom)
    for (int i = 0; i < segments; i++) {
      edges.add([i + 1, i + 1 + segments]);
    }

    // Edges: body bottom ring
    for (int i = 0; i < segments; i++) {
      edges.add([i + 1 + segments, (i + 1) % segments + 1 + segments]);
    }

    // Add 4 fins at cardinal directions
    final finBaseIndex = vertices.length;
    final bodyBottomY = -height / 2 + noseHeight + bodyHeight;
    final finTipY = bodyBottomY + finHeight;

    for (int f = 0; f < 4; f++) {
      double angle = f * math.pi / 2; // 0, 90, 180, 270 degrees
      double cosA = math.cos(angle);
      double sinA = math.sin(angle);

      // Fin attachment point (on body)
      double attachX = bodyRadius * cosA;
      double attachZ = bodyRadius * sinA;

      // Fin outer point
      double outerX = (bodyRadius + finWidth) * cosA;
      double outerZ = (bodyRadius + finWidth) * sinA;

      // Fin vertices: base inner, base outer, tip
      int baseInner = finBaseIndex + f * 3;
      vertices.add(
        Vertice(x: attachX, y: bodyBottomY, z: attachZ),
      ); // base inner
      vertices.add(Vertice(x: outerX, y: finTipY, z: outerZ)); // tip outer
      vertices.add(Vertice(x: attachX, y: finTipY, z: attachZ)); // tip inner

      // Fin edges
      edges.add([baseInner, baseInner + 1]); // base to tip outer
      edges.add([baseInner + 1, baseInner + 2]); // tip outer to tip inner
      edges.add([baseInner + 2, baseInner]); // tip inner to base
    }

    // Exhaust nozzle center (bottom point)
    final exhaustIndex = vertices.length;
    vertices.add(Vertice(x: 0, y: height / 2, z: 0));

    // Connect body bottom ring to exhaust
    for (int i = 0; i < segments; i++) {
      edges.add([i + 1 + segments, exhaustIndex]);
    }

    return Shape3D(vertices: vertices, edges: edges);
  }

  /// Creates a gamepad/controller shape 🎮 centered at origin (detailed wireframe)
  factory Shape3D.gamepad({
    double width = 200,
    double height = 120,
    double depth = 25,
  }) {
    final vertices = <Vertice>[];
    final edges = <List<int>>[];

    final halfW = width / 2;
    final halfH = height / 2;
    final halfD = depth / 2;

    // Helper to add an octagon (8 segments) and return start index
    int addOctagon(
      double cx,
      double cy,
      double cz,
      double radius, {
      int segments = 8,
    }) {
      final start = vertices.length;
      for (int i = 0; i < segments; i++) {
        double angle = i * 2 * math.pi / segments - math.pi / 8;
        vertices.add(
          Vertice(
            x: cx + radius * math.cos(angle),
            y: cy + radius * math.sin(angle),
            z: cz,
          ),
        );
      }
      for (int i = 0; i < segments; i++) {
        edges.add([start + i, start + (i + 1) % segments]);
      }
      return start;
    }

    // Helper to add a ring with radial lines (like analog stick)
    int addDetailedCircle(
      double cx,
      double cy,
      double cz,
      double outerR,
      double innerR, {
      int segments = 12,
    }) {
      final outerStart = vertices.length;
      // Outer ring
      for (int i = 0; i < segments; i++) {
        double angle = i * 2 * math.pi / segments;
        vertices.add(
          Vertice(
            x: cx + outerR * math.cos(angle),
            y: cy + outerR * math.sin(angle),
            z: cz,
          ),
        );
      }
      for (int i = 0; i < segments; i++) {
        edges.add([outerStart + i, outerStart + (i + 1) % segments]);
      }
      // Inner ring
      final innerStart = vertices.length;
      for (int i = 0; i < segments; i++) {
        double angle = i * 2 * math.pi / segments;
        vertices.add(
          Vertice(
            x: cx + innerR * math.cos(angle),
            y: cy + innerR * math.sin(angle),
            z: cz,
          ),
        );
      }
      for (int i = 0; i < segments; i++) {
        edges.add([innerStart + i, innerStart + (i + 1) % segments]);
      }
      // Radial lines connecting inner to outer
      for (int i = 0; i < segments; i++) {
        edges.add([outerStart + i, innerStart + i]);
      }
      // Center point
      final centerIdx = vertices.length;
      vertices.add(Vertice(x: cx, y: cy, z: cz));
      for (int i = 0; i < segments; i++) {
        edges.add([centerIdx, innerStart + i]);
      }
      return outerStart;
    }

    // ===== MAIN BODY OUTLINE (curved top edge) =====
    final bodySegments = 16;
    final bodyFrontStart = vertices.length;

    // Front face - curved body outline
    for (int i = 0; i <= bodySegments; i++) {
      double t = i / bodySegments;
      double x = (t - 0.5) * width;
      // Curved top edge
      double curveTop = -halfH * 0.4 - math.sin(t * math.pi) * halfH * 0.3;
      vertices.add(Vertice(x: x, y: curveTop, z: halfD));
    }
    // Connect top curve
    for (int i = 0; i < bodySegments; i++) {
      edges.add([bodyFrontStart + i, bodyFrontStart + i + 1]);
    }

    // Front face - bottom edge with grip curves
    final bodyBottomFrontStart = vertices.length;
    for (int i = 0; i <= bodySegments; i++) {
      double t = i / bodySegments;
      double x = (t - 0.5) * width;
      double y;
      // Create grip indentations
      if (t < 0.25) {
        y = halfH * 0.3 + math.sin((t / 0.25) * math.pi) * halfH * 0.8;
      } else if (t > 0.75) {
        y = halfH * 0.3 + math.sin(((1 - t) / 0.25) * math.pi) * halfH * 0.8;
      } else {
        y = halfH * 0.3;
      }
      vertices.add(Vertice(x: x, y: y, z: halfD));
    }
    // Connect bottom curve
    for (int i = 0; i < bodySegments; i++) {
      edges.add([bodyBottomFrontStart + i, bodyBottomFrontStart + i + 1]);
    }
    // Connect sides
    edges.add([bodyFrontStart, bodyBottomFrontStart]);
    edges.add([
      bodyFrontStart + bodySegments,
      bodyBottomFrontStart + bodySegments,
    ]);

    // Back face - same pattern
    final bodyBackStart = vertices.length;
    for (int i = 0; i <= bodySegments; i++) {
      double t = i / bodySegments;
      double x = (t - 0.5) * width;
      double curveTop = -halfH * 0.4 - math.sin(t * math.pi) * halfH * 0.3;
      vertices.add(Vertice(x: x, y: curveTop, z: -halfD));
    }
    for (int i = 0; i < bodySegments; i++) {
      edges.add([bodyBackStart + i, bodyBackStart + i + 1]);
    }

    final bodyBottomBackStart = vertices.length;
    for (int i = 0; i <= bodySegments; i++) {
      double t = i / bodySegments;
      double x = (t - 0.5) * width;
      double y;
      if (t < 0.25) {
        y = halfH * 0.3 + math.sin((t / 0.25) * math.pi) * halfH * 0.8;
      } else if (t > 0.75) {
        y = halfH * 0.3 + math.sin(((1 - t) / 0.25) * math.pi) * halfH * 0.8;
      } else {
        y = halfH * 0.3;
      }
      vertices.add(Vertice(x: x, y: y, z: -halfD));
    }
    for (int i = 0; i < bodySegments; i++) {
      edges.add([bodyBottomBackStart + i, bodyBottomBackStart + i + 1]);
    }
    edges.add([bodyBackStart, bodyBottomBackStart]);
    edges.add([
      bodyBackStart + bodySegments,
      bodyBottomBackStart + bodySegments,
    ]);

    // Connect front to back (depth lines)
    for (int i = 0; i <= bodySegments; i += 2) {
      edges.add([bodyFrontStart + i, bodyBackStart + i]);
      edges.add([bodyBottomFrontStart + i, bodyBottomBackStart + i]);
    }

    // ===== LEFT GRIP (curved handle) =====
    final leftGripSegments = 8;
    final leftGripFrontStart = vertices.length;
    for (int i = 0; i <= leftGripSegments; i++) {
      double t = i / leftGripSegments;
      double angle = t * math.pi * 0.6 + math.pi * 0.2;
      double x = -halfW * 0.65 - math.cos(angle) * halfW * 0.25;
      double y = halfH * 0.5 + math.sin(angle) * halfH * 0.7;
      vertices.add(Vertice(x: x, y: y, z: halfD * 0.7));
    }
    for (int i = 0; i < leftGripSegments; i++) {
      edges.add([leftGripFrontStart + i, leftGripFrontStart + i + 1]);
    }

    final leftGripBackStart = vertices.length;
    for (int i = 0; i <= leftGripSegments; i++) {
      double t = i / leftGripSegments;
      double angle = t * math.pi * 0.6 + math.pi * 0.2;
      double x = -halfW * 0.65 - math.cos(angle) * halfW * 0.25;
      double y = halfH * 0.5 + math.sin(angle) * halfH * 0.7;
      vertices.add(Vertice(x: x, y: y, z: -halfD * 0.7));
    }
    for (int i = 0; i < leftGripSegments; i++) {
      edges.add([leftGripBackStart + i, leftGripBackStart + i + 1]);
    }
    for (int i = 0; i <= leftGripSegments; i += 2) {
      edges.add([leftGripFrontStart + i, leftGripBackStart + i]);
    }

    // ===== RIGHT GRIP (curved handle) =====
    final rightGripFrontStart = vertices.length;
    for (int i = 0; i <= leftGripSegments; i++) {
      double t = i / leftGripSegments;
      double angle = t * math.pi * 0.6 + math.pi * 0.2;
      double x = halfW * 0.65 + math.cos(angle) * halfW * 0.25;
      double y = halfH * 0.5 + math.sin(angle) * halfH * 0.7;
      vertices.add(Vertice(x: x, y: y, z: halfD * 0.7));
    }
    for (int i = 0; i < leftGripSegments; i++) {
      edges.add([rightGripFrontStart + i, rightGripFrontStart + i + 1]);
    }

    final rightGripBackStart = vertices.length;
    for (int i = 0; i <= leftGripSegments; i++) {
      double t = i / leftGripSegments;
      double angle = t * math.pi * 0.6 + math.pi * 0.2;
      double x = halfW * 0.65 + math.cos(angle) * halfW * 0.25;
      double y = halfH * 0.5 + math.sin(angle) * halfH * 0.7;
      vertices.add(Vertice(x: x, y: y, z: -halfD * 0.7));
    }
    for (int i = 0; i < leftGripSegments; i++) {
      edges.add([rightGripBackStart + i, rightGripBackStart + i + 1]);
    }
    for (int i = 0; i <= leftGripSegments; i += 2) {
      edges.add([rightGripFrontStart + i, rightGripBackStart + i]);
    }

    // ===== D-PAD (octagonal with cross) =====
    final dpadX = -halfW * 0.38;
    final dpadY = -halfH * 0.15;
    final dpadZ = halfD + 2;
    final dpadRadius = halfH * 0.28;
    addOctagon(dpadX, dpadY, dpadZ, dpadRadius);
    // Inner octagon
    addOctagon(dpadX, dpadY, dpadZ + 1, dpadRadius * 0.5);
    // Cross lines
    final crossStart = vertices.length;
    vertices.add(Vertice(x: dpadX, y: dpadY - dpadRadius * 0.8, z: dpadZ));
    vertices.add(Vertice(x: dpadX, y: dpadY + dpadRadius * 0.8, z: dpadZ));
    vertices.add(Vertice(x: dpadX - dpadRadius * 0.8, y: dpadY, z: dpadZ));
    vertices.add(Vertice(x: dpadX + dpadRadius * 0.8, y: dpadY, z: dpadZ));
    edges.add([crossStart, crossStart + 1]);
    edges.add([crossStart + 2, crossStart + 3]);

    // ===== LEFT ANALOG STICK (detailed circles) =====
    final leftStickX = -halfW * 0.18;
    final leftStickY = halfH * 0.25;
    final leftStickZ = halfD + 3;
    addDetailedCircle(
      leftStickX,
      leftStickY,
      leftStickZ,
      halfH * 0.3,
      halfH * 0.15,
      segments: 10,
    );

    // ===== RIGHT ANALOG STICK (detailed circles) =====
    final rightStickX = halfW * 0.18;
    final rightStickY = halfH * 0.25;
    final rightStickZ = halfD + 3;
    addDetailedCircle(
      rightStickX,
      rightStickY,
      rightStickZ,
      halfH * 0.3,
      halfH * 0.15,
      segments: 10,
    );

    // ===== ACTION BUTTONS (4 hexagonal buttons in diamond) =====
    final btnX = halfW * 0.38;
    final btnY = -halfH * 0.15;
    final btnZ = halfD + 2;
    final btnSpacing = halfH * 0.28;
    final btnRadius = halfH * 0.12;

    // Y button (top)
    addOctagon(btnX, btnY - btnSpacing, btnZ, btnRadius, segments: 6);
    // B button (right)
    addOctagon(btnX + btnSpacing, btnY, btnZ, btnRadius, segments: 6);
    // A button (bottom)
    addOctagon(btnX, btnY + btnSpacing, btnZ, btnRadius, segments: 6);
    // X button (left)
    addOctagon(btnX - btnSpacing, btnY, btnZ, btnRadius, segments: 6);

    // ===== TOP CENTER BUTTONS (menu buttons) =====
    final menuY = -halfH * 0.55;
    final menuZ = halfD + 1;
    final menuBtnRadius = halfH * 0.08;

    // Left menu button
    addOctagon(-halfW * 0.12, menuY, menuZ, menuBtnRadius, segments: 6);
    // Center button (larger)
    addDetailedCircle(
      0,
      menuY,
      menuZ,
      menuBtnRadius * 1.3,
      menuBtnRadius * 0.6,
      segments: 8,
    );
    // Right menu button
    addOctagon(halfW * 0.12, menuY, menuZ, menuBtnRadius, segments: 6);

    // ===== TOP SMALL BUTTONS (triggers area) =====
    final topBtnY = -halfH * 0.75;
    final topBtnZ = halfD * 0.5;
    final topBtnRadius = halfH * 0.06;

    // Two small buttons on each side at top
    addOctagon(-halfW * 0.25, topBtnY, topBtnZ, topBtnRadius, segments: 6);
    addOctagon(-halfW * 0.15, topBtnY, topBtnZ, topBtnRadius, segments: 6);
    addOctagon(halfW * 0.15, topBtnY, topBtnZ, topBtnRadius, segments: 6);
    addOctagon(halfW * 0.25, topBtnY, topBtnZ, topBtnRadius, segments: 6);

    // ===== SHOULDER BUMPERS (curved) =====
    final bumperSegments = 6;
    // Left bumper
    final lbStart = vertices.length;
    for (int i = 0; i <= bumperSegments; i++) {
      double t = i / bumperSegments;
      double x = -halfW * 0.5 + t * halfW * 0.3;
      double y = -halfH * 0.65 - math.sin(t * math.pi) * halfH * 0.1;
      vertices.add(Vertice(x: x, y: y, z: halfD * 0.6));
    }
    for (int i = 0; i < bumperSegments; i++) {
      edges.add([lbStart + i, lbStart + i + 1]);
    }
    final lbBackStart = vertices.length;
    for (int i = 0; i <= bumperSegments; i++) {
      double t = i / bumperSegments;
      double x = -halfW * 0.5 + t * halfW * 0.3;
      double y = -halfH * 0.65 - math.sin(t * math.pi) * halfH * 0.1;
      vertices.add(Vertice(x: x, y: y, z: -halfD * 0.6));
    }
    for (int i = 0; i < bumperSegments; i++) {
      edges.add([lbBackStart + i, lbBackStart + i + 1]);
    }
    edges.add([lbStart, lbBackStart]);
    edges.add([lbStart + bumperSegments, lbBackStart + bumperSegments]);

    // Right bumper
    final rbStart = vertices.length;
    for (int i = 0; i <= bumperSegments; i++) {
      double t = i / bumperSegments;
      double x = halfW * 0.2 + t * halfW * 0.3;
      double y = -halfH * 0.65 - math.sin(t * math.pi) * halfH * 0.1;
      vertices.add(Vertice(x: x, y: y, z: halfD * 0.6));
    }
    for (int i = 0; i < bumperSegments; i++) {
      edges.add([rbStart + i, rbStart + i + 1]);
    }
    final rbBackStart = vertices.length;
    for (int i = 0; i <= bumperSegments; i++) {
      double t = i / bumperSegments;
      double x = halfW * 0.2 + t * halfW * 0.3;
      double y = -halfH * 0.65 - math.sin(t * math.pi) * halfH * 0.1;
      vertices.add(Vertice(x: x, y: y, z: -halfD * 0.6));
    }
    for (int i = 0; i < bumperSegments; i++) {
      edges.add([rbBackStart + i, rbBackStart + i + 1]);
    }
    edges.add([rbStart, rbBackStart]);
    edges.add([rbStart + bumperSegments, rbBackStart + bumperSegments]);

    // ===== INTERNAL GRID LINES (surface detail) =====
    // Horizontal lines across body
    for (int row = 1; row <= 3; row++) {
      double y = -halfH * 0.3 + row * halfH * 0.2;
      final lineStart = vertices.length;
      vertices.add(Vertice(x: -halfW * 0.5, y: y, z: halfD));
      vertices.add(Vertice(x: halfW * 0.5, y: y, z: halfD));
      edges.add([lineStart, lineStart + 1]);
    }

    // Vertical center line
    final centerLineStart = vertices.length;
    vertices.add(Vertice(x: 0, y: -halfH * 0.6, z: halfD + 0.5));
    vertices.add(Vertice(x: 0, y: halfH * 0.3, z: halfD + 0.5));
    edges.add([centerLineStart, centerLineStart + 1]);

    return Shape3D(vertices: vertices, edges: edges);
  }

  /// Rotate all vertices around Y axis
  Shape3D rotateY(double angle) {
    return Shape3D(
      vertices: vertices.map((v) => v.rotateY(angle)).toList(),
      edges: edges,
    );
  }

  /// Rotate all vertices around X axis
  Shape3D rotateX(double angle) {
    return Shape3D(
      vertices: vertices.map((v) => v.rotateX(angle)).toList(),
      edges: edges,
    );
  }

  /// Rotate all vertices around Z axis
  Shape3D rotateZ(double angle) {
    return Shape3D(
      vertices: vertices.map((v) => v.rotateZ(angle)).toList(),
      edges: edges,
    );
  }
}
