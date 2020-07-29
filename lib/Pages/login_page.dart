import 'package:fltr_uhfj/Components/username_input.dart';
import 'package:fltr_uhfj/Components/PasswordText.dart';
import 'package:fltr_uhfj/Components/SelectBranch.dart';
import 'package:fltr_uhfj/Pages/home_page.dart';
import 'package:fltr_uhfj/models/user_type.dart';
import 'package:fltr_uhfj/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;
  bool validLogins = false;
  String branchId;
  String username;
  String password;

  Future<void> _logIn(String branchId, String username, String password) async {
    setState(() {
      showSpinner = true;
    });
    await http.post("http://13.90.214.197:8081/hrback/public/api/Scanner/login",
        body: {
          "username": username,
          "password": password,
          "branch_id": branchId
        }).then((response) {
      var user = UserType.fromJson(json.decode(response.body));
      print(user.toString());
      Constants.prefs.setBool(Constants.PDASCR_LOGGED_IN, true);
      Constants.prefs.setString(Constants.PDASCR_LOGGED_USER, user.toJson());
      Get.off(HomePage());
    });
  }

  checkValidLogins() {
    if ((branchId?.isNotEmpty ?? false) &&
        (username?.isNotEmpty ?? false) &&
        (password?.isNotEmpty ?? false))
      setState(() {
        validLogins = true;
      });
    else
      setState(() {
        validLogins = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
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
                  Container(
                    child: Text(
                      "تسجيل الدخول",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  )
                ],
              )),
              SizedBox(
                height: 36,
              ),
              Container(
                child: SelectBranch(
                  onChanged: (value) {
                    branchId = value;
                    checkValidLogins();
                  },
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                child: UsernameInput(
                  title: "اسم المستخدم",
                  onChanged: (value) {
                    username = value;
                    checkValidLogins();
                  },
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                  child: PasswordText(
                title: "كلمة المرور",
                onChanged: (value) {
                  password = value;
                  checkValidLogins();
                },
              )),
              SizedBox(
                height: 24,
              ),
              RaisedButton(
                elevation: 5,
                onPressed: validLogins
                    ? () => _logIn(branchId, username, password)
                    : null,
                padding:
                    EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
                child: Text(
                  "تسجيل الدخول",
                  style: TextStyle(fontSize: 22),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
