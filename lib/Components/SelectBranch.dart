import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectBranch extends StatefulWidget {
  const SelectBranch({@required this.onChanged});
  final Function onChanged;
  @override
  _SelectBranchState createState() => _SelectBranchState();
}

class _SelectBranchState extends State<SelectBranch> {
  String _branchId;
  List branches;

  Future<void> _getAllBranches() async {
    await http
        .get(
            "http://13.90.214.197:8081/hrback/public/api/imis_branches?company_id=1")
        .then((response) {
      var data = json.decode(response.body);
      print(data);
      setState(() {
        branches = data;
      });
    });
  }

  @override
  void initState() {
    _getAllBranches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<String>(
        value: _branchId,
        hint: Text(
          "اختر الفرع",
          style: TextStyle(fontSize: 24),
        ),
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black38),
        onChanged: (String newval) {
          widget.onChanged(newval);
          setState(() {
            _branchId = newval;
          });
        },
        items: branches?.map((branch) {
              return new DropdownMenuItem(
                child: new Text(
                  branch['branchNameAr'],
                  style: TextStyle(fontSize: 20),
                ),
                value: branch['ID'].toString(),
              );
            })?.toList() ??
            [],
      ),
    );
  }
}
