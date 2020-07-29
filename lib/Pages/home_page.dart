import 'package:fltr_uhfj/Components/select_warehouse.dart';
import 'package:fltr_uhfj/Pages/login_page.dart';
import 'package:fltr_uhfj/models/user_type.dart';
import 'package:fltr_uhfj/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/home";
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String warehouseId = "";

  _startScanner(int type) {
    Get.toNamed('uhf_scan', arguments: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 2,
                ),
              ],
            )),
            Container(
              child: SelectWarehouse(
                onChanged: (value) async {
                  var userJsonString =
                      Constants.prefs.getString(Constants.PDASCR_LOGGED_USER);
                  var user = UserType.fromString(userJsonString);
                  user.currWarehouse = value;
                  await Constants.prefs
                      .setString(Constants.PDASCR_LOGGED_USER, user.toJson());
                  setState(() {
                    warehouseId = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: 24,
            ),
            RaisedButton(
              elevation: 5,
              color: Colors.blue[300],
              onPressed: warehouseId.isNotEmpty ? () => _startScanner(0) : null,
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                "بدء المسح ",
                style: TextStyle(fontSize: 24),
              ),
            ),
            /*
            RaisedButton(
              elevation: 5,
              color: Colors.blue[300],
              onPressed: warehouseId.isNotEmpty ? () => _startScanner(0) : null,
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                "  حركات مخزنية ",
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            RaisedButton(
              elevation: 5,
              color: Colors.blue[300],
              onPressed: warehouseId.isNotEmpty ? () => _startScanner(1) : null,
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                "تسليم مبيعات",
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            RaisedButton(
              elevation: 5,
              color: Colors.blue[300],
              onPressed: warehouseId.isNotEmpty ? () => _startScanner(2) : null,
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                " الجرد",
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            RaisedButton(
              elevation: 5,
              color: Colors.blue[300],
              onPressed: warehouseId.isNotEmpty ? () => _startScanner(3) : null,
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                "استلام بضائع",
                style: TextStyle(fontSize: 24),
              ),
            ),
            */
            SizedBox(
              height: 24,
            ),
            RaisedButton(
              elevation: 5,
              color: Colors.red[300],
              onPressed: () {
                Constants.prefs.clear();
                Get.to(LoginPage());
              },
              padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
              child: Text(
                "تسجيل الخروج",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
