import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:productapp/pages/show_products.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                inputEmail(),
                inputPassword(),
                formButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container formButton() {
    double width = 130;
    double height = 45;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          loginButton(width, height),
          registerButton(width, height),
        ],
      ),
    );
  }

  SizedBox loginButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Define your http laravel API location
              var apiUrl = "https://iamping.pungpingcoding.online/api";
              var url = Uri.parse("$apiUrl/login");

              // prepare json data to send
              var json = jsonEncode(
                  {"email": _email.text, "password": _password.text});

              // Request by POST Method
              var response = await http.post(url,
                  body: json,
                  headers: {HttpHeaders.contentTypeHeader: "application/json"});

              // if Status Code == 200, do
              if (response.statusCode == 200) {
                // Decode response json to list
                var jsonStr = jsonDecode(response.body);

                print(jsonStr['user']);
                print(jsonStr['token']);

                // Store user and token to local storage by using SharedPreference
                SharedPreferences _pref = await SharedPreferences.getInstance();
                await _pref.setInt('id', jsonStr['user']['id']);
                await _pref.setString('name', jsonStr['user']['name']);
                await _pref.setString('token', jsonStr['token']);

                // Navigate to ShowProduct Page
                if (!mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShowProduct(),
                    ));
              } else {
                showAlert();
              }
            }
          },
          child: const Text('เข้าสู่ระบบ')),
    );
  }

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'เกิดข้อผิดพลาด',
      text: 'ชื่อผู้ใช้และรหัสผ่านไม่ถูกต้อง',
      confirmBtnText: "ตกลง",
    );
  }

  SizedBox registerButton(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 255, 255, 255)),
        ),
        onPressed: () {},
        child: const Text('สมัครสมาชิก'),
      ),
    );
  }

  Container inputEmail() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 8),
      child: TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกอีเมล์';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          icon: Icon(
            Icons.email,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          label: Text(
            'อีเมล์',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      ),
    );
  }

  Widget inputPassword() {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: TextFormField(
        controller: _password,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณากรอกรหัสผ่าน';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          icon: Icon(
            Icons.lock,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          label: Text(
            'รหัสผ่าน',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      ),
    );
  }
}
