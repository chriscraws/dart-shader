import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'image.dart';
import 'simple.dart';
import 'touch.dart';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  List<_DemoTileData> demos = [
    _DemoTileData(
      title: 'Simple',
      builder: (_) => SimpleDemoPage(),
    ),
    _DemoTileData(
      title: 'Image',
      builder: (_) => ImageDemoPage(),
    ),
    _DemoTileData(
      title: 'Touch',
      builder: (_) => TouchInteraction(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, i) => _DemoTile(demos[i]),
          itemCount: demos.length,
        ),
      ),
    );
  }
}

class _DemoTileData {
  _DemoTileData({this.title, this.builder});

  final String title;
  final WidgetBuilder builder;
}

class _DemoTile extends StatelessWidget {
  _DemoTile(this.data);

  final _DemoTileData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: data.builder));
      },
      child: ListTile(
        title: Text(data.title),
      ),
    );
  }
}
