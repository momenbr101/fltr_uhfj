import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DetectorPage extends StatefulWidget {
  DetectorPage({Key key}) : super(key: key);

  @override
  _DetectorPageState createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> {
  static const platform = const MethodChannel('demo.uhf/scan');

  bool _scan = true;
  double _rssi = 0.0;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(this._didRecieveTag);
    _setUps();
  }

  Future<void> _setUps() async {
    try {
      await platform.invokeMethod('START_DETECT', Get.arguments.toString());
    } on PlatformException catch (e) {}
  }

  void foundTag(String tag) {
    var splitted = tag.split('@');
    setState(() {
      _rssi = double.parse(splitted[1]);
    });
  }

  Future<void> _didRecieveTag(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    final String tag = call.arguments;
    switch (call.method) {
      case "TAG_FOUND":
        foundTag(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Divider(
          color: Colors.transparent,
        ),
        Text('Tag: ${Get.arguments.toString()}'),
        Divider(
          color: Colors.transparent,
        ),
        Text('Current RSSI: $_rssi '),
        Divider(
          color: Colors.transparent,
        ),
        RaisedButton(
          child: Text(_scan ? "Stop" : "Scan"),
          onPressed: () async {
            final bool result = await platform.invokeMethod(
                _scan ? 'STOP_SCAN' : 'START_DETECT', Get.arguments.toString());
            //addCode(result);
            if (result)
              setState(() {
                _scan = !_scan;
              });
          },
        ),
        Divider(
          color: Colors.transparent,
        ),
        LinearProgressIndicator(
          value: (70 + _rssi) / 70,
          backgroundColor: Colors.grey[200],
        )
      ]),
    );
  }
}
