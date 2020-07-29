import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectWarehouse extends StatefulWidget {
  const SelectWarehouse({@required this.onChanged});
  final Function onChanged;

  @override
  _SelectWarehouseState createState() => _SelectWarehouseState();
}

class _SelectWarehouseState extends State<SelectWarehouse> {
  String _warehouseId;
  List warehouses;

  Future<void> _getAllWarehouses() async {
    await http
        .get(
            "http://13.90.214.197:8081/hrback/public/api/imis_warehouses")
        .then((response) {
      var data = json.decode(response.body);
      print(data);
      setState(() {
        warehouses = data;
      });
    });
  }

  @override
  void initState() {
    _getAllWarehouses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<String>(
        value: _warehouseId,
        hint: Text(
          "اختر المخزن",
          style: TextStyle(fontSize: 24),
        ),
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black38),
        onChanged: (String newval) {
          widget.onChanged(newval);
          setState(() {
            _warehouseId = newval;
          });
        },
        items: warehouses?.map((warehouse) {
              return new DropdownMenuItem(
                child: new Text(
                  warehouse['ArabicDescription'],
                  style: TextStyle(fontSize: 20),
                ),
                value: warehouse['GUID'].toString(),
              );
            })?.toList() ??
            [],
      ),
    );
  }
}
