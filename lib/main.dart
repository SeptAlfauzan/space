import 'package:flutter/material.dart';
import 'package:space/entities/shape3d.dart';

import 'package:space/widgets/canvas_container.dart';

void main() {
  runApp(const SpaceApp());
}

class SpaceApp extends StatelessWidget {
  const SpaceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.dark()),
      home: const App(title: 'Space'),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, required this.title});
  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final canvasKey = GlobalKey<CanvasContainerState>();
  bool _showShapeOptions = false;
  bool _xAxisLock = false;
  bool _yAxisLock = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _showShapeOptions ? 12 : 0,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child:
                _showShapeOptions
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 12,
                      children: [
                        ShapeOptionContainer(
                          text: 'cube',
                          action: () {
                            canvasKey.currentState?.changeShape(Shape3D.cube());
                            setState(() {
                              _showShapeOptions = false;
                            });
                          },
                        ),
                        ShapeOptionContainer(
                          text: 'sphere',
                          action: () {
                            canvasKey.currentState?.changeShape(
                              Shape3D.sphere(),
                            );
                            setState(() {
                              _showShapeOptions = false;
                            });
                          },
                        ),
                        ShapeOptionContainer(
                          text: 'game pad',
                          action: () {
                            canvasKey.currentState?.changeShape(
                              Shape3D.gamepad(),
                            );
                            setState(() {
                              _showShapeOptions = false;
                            });
                          },
                        ),
                        ShapeOptionContainer(
                          text: 'rocket',
                          action: () {
                            canvasKey.currentState?.changeShape(
                              Shape3D.rocket().rotateZ(-45),
                            );
                            setState(() {
                              _showShapeOptions = false;
                            });
                          },
                        ),
                      ],
                    )
                    : SizedBox.shrink(),
          ),
          Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                child: Icon(
                  Icons.swap_horizontal_circle_outlined,
                  color: _xAxisLock ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  final val = canvasKey.currentState?.toggleLockXAxis();
                  if (val == null) return;
                  setState(() {
                    _xAxisLock = val;
                  });
                },
              ),
              FloatingActionButton(
                child: Icon(
                  Icons.swap_vertical_circle_outlined,
                  color: _yAxisLock ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  final val = canvasKey.currentState?.toggleLockYAxis();
                  if (val == null) return;
                  setState(() {
                    _yAxisLock = val;
                  });
                },
              ),
              FloatingActionButton(
                child: Icon(Icons.center_focus_strong),
                onPressed: () {
                  canvasKey.currentState?.resetRotationAngle();
                },
              ),
              FloatingActionButton(
                child: Icon(Icons.format_shapes_outlined),
                onPressed: () {
                  setState(() {
                    _showShapeOptions = !_showShapeOptions;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: CanvasContainer(key: canvasKey),
    );
  }
}

class ShapeOptionContainer extends StatelessWidget {
  final String text;
  final Function action;
  const ShapeOptionContainer({
    super.key,
    required this.text,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: InkWell(
        onTap: () => action(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
          child: Text(text, style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}
