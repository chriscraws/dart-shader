import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:expr/expr.dart';

class ImageDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleImageShader(
          shaderProvider: (image) => ImageDemoShader(image),
          assetPath: 'images/city2.jpg',
        ),
      ),
    );
  }
}

class ImageDemoShader extends TimeAndResolutionShader {
  ImageDemoShader(this.image) : this.sampler = Sampler(image);

  final ui.Image image;
  final Sampler sampler;

  @override
  List<ui.Shader> children() => [
        ui.ImageShader(
          image,
          ui.TileMode.repeated, // tmx
          ui.TileMode.repeated, // tmy
          Matrix4.identity().storage, // matrix
        ),
      ];

  @override
  Vec4 color(Vec2 position) {
    Vec2 uv = position / resolution * Vec2(image.width.s, image.height.s);
    uv += Vec2(sin(uv.y / 100.s + time) * 25.s, 0.s);
    return sampler.sample(uv);

    // TODO: [ERROR:flutter/lib/ui/painting/fragment_shader.cc(53)] Invalid SPIR-V: Unsupported OP: 79
    // return Vec4.of([sampler.sample(position).xy, Vec2(0.5.s, 1.s)]);
  }
}

abstract class TimeAndResolutionShader extends Shader {
  final time = ScalarUniform();
  final resolution = Vec2Uniform();
  List<ui.Shader> children() => [];
}

typedef TimeAndResolutionShader TimeAndResolutionAndImageShaderProvider(image);

class SingleImageShader extends StatefulWidget {
  final TimeAndResolutionAndImageShaderProvider shaderProvider;
  final String assetPath;

  SingleImageShader({
    this.shaderProvider,
    this.assetPath,
  });

  @override
  _SingleImageShaderState createState() => _SingleImageShaderState();
}

class _SingleImageShaderState extends State<SingleImageShader> {
  ui.Image _image;
  Ticker _ticker;
  ChangeNotifier notifier;
  TimeAndResolutionShader _shader;

  @override
  void initState() {
    super.initState();
    notifier = ChangeNotifier();
    _ticker = Ticker((duration) {
      notifier.notifyListeners();
      if (_shader != null) {
        _shader.time.value = duration.inMicroseconds / 1000.0 / 1000.0;
      }
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_image == null) {
      _image = await loadUiImage(widget.assetPath);
      setState(() {
        _shader = widget.shaderProvider(_image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _shader == null
        ? Container()
        : Center(
            child: CustomPaint(
              painter: SingleImageShaderPainter(
                ssirShader: _shader,
                repaint: notifier,
              ),
              size: Size.infinite,
            ),
          );
  }
}

class SingleImageShaderPainter extends CustomPainter {
  final TimeAndResolutionShader ssirShader;
  final Listenable repaint;
  final ui.FragmentShader _shader;
  final Vec2Uniform _resolution;

  SingleImageShaderPainter({
    this.ssirShader,
    this.repaint,
  })  : _shader = ui.FragmentShader.spirv(
            ssirShader.toSPIRV().asUint8List(), ssirShader.children()),
        _resolution = ssirShader.resolution,
        super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _resolution.value
      ..x = size.width
      ..y = size.height;

    ssirShader.writeUniformData(_shader.setFloatUniform);
    _shader.refresh();
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = _shader,
    );
  }

  @override
  bool shouldRepaint(SingleImageShaderPainter old) => true;
}

Future<ui.Image> loadUiImage(String imageAssetPath) async {
  final ByteData data = await rootBundle.load(imageAssetPath);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}
