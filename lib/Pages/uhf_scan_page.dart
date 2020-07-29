import 'dart:math';

import 'package:fltr_uhfj/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UHFScanPage extends StatefulWidget {
  UHFScanPage({Key key}) : super(key: key);

  @override
  _UHFScanPageState createState() => _UHFScanPageState();
}

class _UHFScanPageState extends State<UHFScanPage> {
  List<String> _codes = List<String>();
  String _scanStatus = 'Unknown Status !';
  String _singleTag = 'no_tag';
  String _version = '';
  bool _scan = false;

  static const platform = const MethodChannel('demo.uhf/scan');
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    platform.setMethodCallHandler(this._didRecieveTag);
    _setUps();
  }

  Future<void> _setUps() async {
    String scanStatus;
    try {
      final String result = await platform.invokeMethod('INIT');
      scanStatus = 'BRFID SCANNER started at $result % .';
    } on PlatformException catch (e) {
      scanStatus = "Failed to start RFID SCANNER: '${e.code}'.";
    }

    setState(() {
      _scanStatus = scanStatus;
    });
  }

  Future<void> _didRecieveTag(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    final String code = call.arguments;
    switch (call.method) {
      case "TAG_FOUND":
        {
          var splitted = code.split('@');
          addCode(splitted[0]);
        }
    }
  }

  void addCode(String code) async {
    _codes.add(code);
    var newcodes = _codes.toSet().toList();
    setState(() {
      _codes = newcodes;
    });
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.linear);
    await Constants.prefs.setStringList(Constants.PDASCR_CODES, newcodes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Divider(
          color: Colors.transparent,
        ),
        Text('Scanner: $_scanStatus'),
        /*
        Divider(
          color: Colors.transparent,
        ),
        Text('Current Tag: $_singleTag'),
        Divider(
          color: Colors.transparent,
        ),
        Text('Device version: $_version'),
        */
        Divider(
          color: Colors.transparent,
        ),
        RaisedButton(
          child: Text(_scan ? "Stop" : "Scan"),
          onPressed: () async {
            final bool result =
                await platform.invokeMethod(_scan ? 'STOP_SCAN' : 'START_SCAN');
            //addCode(result);
            if (result)
              setState(() {
                _scan = !_scan;
              });
          },
        ),
        /*
        Divider(
          color: Colors.transparent,
        ),
        RaisedButton(
          child: Text("Version"),
          onPressed: () async {
            final String result = await platform.invokeMethod('VERSION');
            setState(() {
              _version = result;
            });
          },
        ),
        */
        Divider(
          color: Colors.transparent,
        ),
        SizedBox(
          height: 200,
          child: Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: ListView.builder(
                itemCount: _codes.length,
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_codes[index]),
                    /*
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                      onPressed: () async {
                        setState(() {
                          _codes.removeWhere((code) => code == _codes[index]);
                        });
                        await Constants.prefs
                            .setStringList(Constants.PDASCR_CODES, _codes);
                      },
                    ),
                    */
                    trailing: IconButton(
                      icon: Icon(Icons.location_searching,
                          color: Colors.blue[400]),
                      onPressed: () async {
                        Get.toNamed('detect', arguments: _codes[index]);
                      },
                    ),
                  );
                }),
          ),
        ),
        Divider(
          color: Colors.transparent,
        ),
        RaisedButton(
          onPressed: () {
            Random rand = new Random();
            addCode(rand.nextInt(20).toString() +
                "ECODE_666363699983633+" +
                rand.nextInt(2000000000).toString());
          },
          child: Text("Generate Code"),
        )
      ]),
    );
  }
}
