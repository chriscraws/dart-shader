import 'dart:ui' as ui;
import 'package:expr/expr.dart';

import 'package:flutter/widgets.dart';

class TouchInteraction extends StatelessWidget {
	final shader = TouchShader();

	@override
	Widget build(BuildContext context) {
		return CustomPaint(
			painter: shader,
			size: Size.infinite,
			child: Listener(
				onPointerMove: (PointerMoveEvent e) {
					shader.touchPosition.value
						..x = -e.localPosition.dx
						..y = -e.localPosition.dy;
					shader.repaint();
				},
				behavior: HitTestBehavior.opaque,
			),
		);
	}
}

class TouchShader extends Shader<ui.Shader> with ChangeNotifier implements CustomPainter {
	final resolution = Vec2Uniform();
	final touchPosition = Vec2Uniform();

	ui.FragmentShader _shader;

	TouchShader() {
		_shader = ui.FragmentShader.spirv(toSPIRV().asUint8List(), []);
	}

	set width(double x) => resolution.value.x = x;
	set height(double x) => resolution.value.y = x;

	@override
	Vec4 color(Vec2 p) {
		return Vec4.of([
			((p + touchPosition) / resolution).fract(),
			0.s,
			1.s
		]);
	}

	void repaint() {
		notifyListeners();
	}

	@override
	void paint(Canvas canvas, Size size) {
		width = size.width;
		height = size.height;
		writeUniformData(_shader.setFloatUniform);
		_shader.refresh();
		canvas.drawRect(
			Offset.zero & size,
			Paint()..shader = _shader);
	}

	@override
	bool shouldRepaint(TouchShader old) => false; 

	@override
	bool hitTest(Offset position) => null;

	@override
	bool shouldRebuildSemantics(TouchShader old) => shouldRepaint(old);

	@override
	SemanticsBuilderCallback get semanticsBuilder => null;
}
