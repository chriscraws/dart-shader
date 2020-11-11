import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:expr/expr.dart';

class SimpleDemoPage extends StatefulWidget {
  SimpleDemoPage({Key key, this.title}) : super(key: key);

  final String title;
  final shader = MainShader();

  @override
  _SimpleDemoPageState createState() => _SimpleDemoPageState();
}

class _SimpleDemoPageState extends State<SimpleDemoPage> with TickerProviderStateMixin {
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
            shader: ui.FragmentShader.spirv(
                widget.shader.toSPIRV().asUint8List(), []),
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
    Vec2 p = position / resolution.x.v2 - Vec2(0.5.s, 0.5.s / aspect);

    p -= circlePos;
    p += Vec2(0.s, 0.03.s * sin(time + 30.s * p.y));

    final pixel = 1.s / resolution.x;
    final b = dcircle(p, 0.13.s).smoothStep(0.0.s, pixel);
    return Vec4.of([
      b.v3,
      1.s,
    ]);
  }
}

class ShaderPainter extends CustomPainter {
  final Shader ssirShader;
  final ui.FragmentShader shader;
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