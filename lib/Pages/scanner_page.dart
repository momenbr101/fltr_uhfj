/*
import 'package:fltr_pdascan/Components/select_delivery_types.dart';
import 'package:fltr_pdascan/Components/select_good_receipt_types.dart';
import 'package:fltr_pdascan/Components/select_stock_count_types.dart';
import 'package:fltr_pdascan/Components/select_store_trans_types.dart';
import 'package:fltr_pdascan/models/user_type.dart';
import 'package:fltr_pdascan/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerPage extends StatefulWidget {
  final HoneywellScanner honeywellScanner = HoneywellScanner();
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with WidgetsBindingObserver
    implements ScannerCallBack {
  String _scannedStatus = 'Stopped';
  String _typeId = "";
  String _error = "";
  int _type;
  List<String> _codes = List<String>();
  ScrollController _scrollController;
  UserType user;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    var initCodes = _getCodesList();
    print('initCodes $initCodes');

    if (initCodes != null)
      setState(() {
        _codes = initCodes;
      });

    setState(() {
      _scannedStatus = 'Started';
      _type = int.parse(Get.arguments.toString());
    });
    scannerSetups();
    _scrollController = ScrollController();

    var userJsonString =
        Constants.prefs.getString(Constants.PDASCR_LOGGED_USER);
    user = UserType.fromString(userJsonString);
  }

  void scannerSetups() async {
    widget.honeywellScanner.scannerCallBack = this;
    await widget.honeywellScanner.setProperties(CodeFormatUtils.get()
        .getFormatsAsProperties(
            [CodeFormat.CODE_128, CodeFormat.QR_CODE, CodeFormat.DATA_MATRIX]));
    try {
      await widget.honeywellScanner.stopScanner();
    } catch (e) {}
    await widget.honeywellScanner.startScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('state = $state');
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await widget.honeywellScanner.stopScanner();
    } else if (state == AppLifecycleState.resumed) {
      await widget.honeywellScanner.startScanner();
    }
  }

  @override
  void onDecoded(String result) {
    addCode(result);
  }

  List<String> _getCodesList() {
    return Constants.prefs.getStringList(Constants.PDASCR_CODES);
  }

  Future<void> _sendCodes(BuildContext context) async {
    await http.post(
        "http://13.90.214.197:8081/hrback/public/api/Scanner/header_guid",
        body: {
          "company": "1",
          "branch_id": user.branch.toString(),
          "type": _type.toString(),
          "type_id": _typeId,
          "emp_id": user.guid,
          "warehouse_id": user.currWarehouse
        }).then((response) async {
      if (response?.statusCode == 200) {
        var data = json.decode(response.body);
        var headGuid = data[0]['GUID'];
        var body = json.encode({
          "company": "1",
          "branch_id": user.branch.toString(),
          "head_guid": headGuid,
          "codes": _codes
        });
        await http.post(
            "http://13.90.214.197:8081/hrback/public/api/Scanner/post_codes",
            body: body,
            headers: {'Content-type': 'application/json'}).then((response) {
          if (response.statusCode == 201) {
            Constants.prefs.remove(Constants.PDASCR_CODES);
            setState(() {
              _codes = List<String>();
            });
            Get.snackbar("تم الارسال", "تم ارسال الاكواد بنجاح",
                snackPosition: SnackPosition.BOTTOM);
          }
        });
      }
    });
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
  void onError(Exception error) {
    setState(() {
      _error = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            if (_error.isNotEmpty)
              return Row(children: [
                Text(
                  'Error: $_error',
                  style: TextStyle(color: Colors.red[400]),
                ),
                Divider(
                  color: Colors.transparent,
                ),
              ]);
            else
              return SizedBox();
          }),
          if (_type == 0)
            Container(
              child: SelectStoreTransTypes(
                onChanged: (value) {
                  setState(() {
                    _typeId = value;
                  });
                },
              ),
            ),
          if (_type == 1)
            Container(
              child: SelectDeliveryTypes(
                onChanged: (value) {
                  setState(() {
                    _typeId = value;
                  });
                },
              ),
            ),
          if (_type == 2)
            Container(
              child: SelectStockCountTypes(
                onChanged: (value) {
                  setState(() {
                    _typeId = value;
                  });
                },
              ),
            ),
          if (_type == 3)
            Container(
              child: SelectGoodReceiptTypes(
                onChanged: (value) {
                  setState(() {
                    _typeId = value;
                  });
                },
              ),
            ),
          Text('Scanner: $_scannedStatus'),
          Divider(
            color: Colors.transparent,
          ),
          SizedBox(
            height: 250,
            child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: ListView.builder(
                  itemCount: _codes.length,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_codes[index]),
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
                    );
                  }),
            ),
          ),
          Divider(
            color: Colors.transparent,
          ),
          RaisedButton(
            child: Text(
              " ارسل الاكواد",
              style: TextStyle(fontSize: 24),
            ),
            padding: EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
            color: Colors.blue[300],
            onPressed: _typeId.isNotEmpty && _codes.length > 0
                ? () => _sendCodes(context)
                : null,
          ),
          Divider(
            color: Colors.transparent,
          ),
          RaisedButton(
            child: Text("Fake Code"),
            onPressed: () {
              Random rand = new Random();
              addCode(rand.nextInt(20).toString() +
                  "ECODE_666363699983633+" +
                  rand.nextInt(2000000000).toString());
            },
          ),
        ],
      ),
    );
  }
}
*/
