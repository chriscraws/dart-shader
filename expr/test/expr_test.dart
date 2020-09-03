@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:expr/expr.dart';

class SimpleFragment extends Fragment {
  Vec4 get color => Vec4(0.25, 0.5, 0.75, 1);
}

final overwriteGoldens = false;

Future<void> matchGolden(ByteBuffer item, String filename) async {
  assert(filename != null);
  final file = File(filename);
  if (overwriteGoldens) {
    print(Directory.current);
    await file.writeAsBytes(item.asUint8List(), flush: true);
  }
  expect(item.asUint8List(), equals(await file.readAsBytes()));
}

void main() {
  // No tests yet

  test('simple shader', () async {
    final shader = SimpleFragment();
    await matchGolden(shader.toSPIRV(), 'simple.golden');
  });
}
