import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectStockCountTypes extends StatefulWidget {
  const SelectStockCountTypes({@required this.onChanged});
  final Function onChanged;

  @override
  _SelectStockCountTypesState createState() => _SelectStockCountTypesState();
}

class _SelectStockCountTypesState extends State<SelectStockCountTypes> {
  String _deliveryTypeId;
  List deliveryTypes;

  Future<void> _getAllTypes() async {
    await http
        .get(
            "http://13.90.214.197:8081/hrback/public/api/Scanner/stock_count_types?company=1&branch_id=1")
        .then((response) {
      var data = json.decode(response.body);
      print(response.body);
      setState(() {
        deliveryTypes = data;
      });
    });
  }

  @override
  void initState() {
    _getAllTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<String>(
        value: _deliveryTypeId,
        hint: Text(
          "اختر نوع الجرد",
          style: TextStyle(fontSize: 24),
        ),
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black38),
        onChanged: (String newval) {
          widget.onChanged(newval);
          setState(() {
            _deliveryTypeId = newval;
          });
        },
        items: deliveryTypes?.map((deliveryType) {
              return new DropdownMenuItem(
                child: new Text(
                  deliveryType['ArabicDescription'],
                  style: TextStyle(fontSize: 20),
                ),
                value: deliveryType['GUID'].toString(),
              );
            })?.toList() ??
            [],
      ),
    );
  }
}
