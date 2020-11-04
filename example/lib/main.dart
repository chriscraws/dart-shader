import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:expr/expr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final shader = MainShader();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final notifier = ChangeNotifier();
  Ticker ticker;
  AnimationController _controller;

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      })
      ..forward();
    final curvedAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
      reverseCurve: Curves.bounceIn,
    );

    ticker = createTicker((duration) {
      notifier.notifyListeners();
      widget.shader.time.value = duration.inMilliseconds.toDouble() / 1000.0;

      final pos = widget.shader.circlePos;
      pos.value.x = -(curvedAnim.value - 0.5) * 0.2;
    })
      ..start();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: ShaderPainter(
            ssirShader: widget.shader,
            shader: FragmentShader.spirv(widget.shader.toSPIRV().asUint8List()),
            repaint: notifier,
            resolution: widget.shader.resolution,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class MainShader extends Shader {
  final time = ScalarUniform();
  final resolution = Vec2Uniform();
  final circlePos = Vec2Uniform();

  Scalar dcircle(Vec2 p, Scalar r) => p.length() - r;

  Vec4 color(Vec2 position) {
    final aspect = resolution.x / resolution.y;
    Vec2 p = position / resolution.x.v2 - Vec2.of(0.5.s, 0.5.s / aspect);

    p -= circlePos;
    p += Vec2.of(0.s, 0.03.s * sin(time + 30.s * p.y));

    final pixel = 1.s / resolution.x;
    final b = dcircle(p, 0.13.s).smoothStep(0.0.s, pixel);
    return Vec4.of([
      b.v3,
      1.s,
    ]);
  }
}

extension E on num {
  Scalar get s => Scalar(this.toDouble());
  Vec2 get v2 => Vec2.all(this.toDouble());
}

class ShaderPainter extends CustomPainter {
  final Shader ssirShader;
  final FragmentShader shader;
  final Listenable repaint;
  final Vec2Uniform resolution;

  ShaderPainter({
    this.ssirShader,
    this.shader,
    this.repaint,
    this.resolution,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    resolution.value
      ..x = size.width
      ..y = size.height;

    ssirShader.writeUniformData(shader.setFloatUniform);
    shader.refresh();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(ShaderPainter old) => true;
}
