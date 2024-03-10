import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:productapp/models/product_model.dart';
import 'package:productapp/pages/add_product.dart';
import 'package:productapp/pages/edit_product.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProduct extends StatefulWidget {
  const ShowProduct({super.key});

  @override
  State<ShowProduct> createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Products'),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Move to Add Product Page
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductPage(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> getList() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    var apiUrl = "https://iamping.pungpingcoding.online/api";
    var url = Uri.parse("$apiUrl/product");

    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${_pref.getString('token')}"
    });

    return response.body;
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          // Convert snapshot.data to jsonString
          var jsonStr = jsonDecode(snapshot.data!);
          var payload = jsonStr['payload'];

          // Create List of Product by using Product Model
          List<ProductModel> products = payload.map<ProductModel>((product) {
            return ProductModel.fromJson(product);
          }).toList();

          // print(products);

          // Define Widgets to myList
          myList = [
            Column(
              children: products.map((item) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      // Navigate to Edit Product
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductPage(productId: item.id),
                          ));
                    },
                    title: Text(item.productName),
                    subtitle: Text(item.price.toString()),
                    trailing: IconButton(
                      onPressed: () {
                        // Create Alert Dialog
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          customAsset: "assets/error.gif",
                          headerBackgroundColor: Colors.red,
                          confirmBtnText: "ลบ",
                          confirmBtnColor: Colors.red,
                          confirmBtnTextStyle:
                              const TextStyle(color: Colors.white),
                          onConfirmBtnTap: () {
                            deleteProduct(item.id);
                            Navigator.pop(context);
                          },
                          title: "ต้องการลบข้อมูล",
                          text: item.productName,
                          cancelBtnText: "ยกเลิก",
                          onCancelBtnTap: () => Navigator.pop(context),
                          showCancelBtn: true,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ];
        } else if (snapshot.hasError) {
          myList = [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('ข้อผิดพลาด: ${snapshot.error}'),
            ),
          ];
        } else {
          myList = [
            const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('อยู่ระหว่างประมวลผล'),
            )
          ];
        }

        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    // Call SharedPreference to get Token
    SharedPreferences _pref = await SharedPreferences.getInstance();

    // Define Laravel API for Deleting Product
    var apiUrl = "https://iamping.pungpingcoding.online/api";
    var url = Uri.parse("$apiUrl/product/$id");

    // Request deleting product
    var response = await http.delete(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${_pref.getString('token')}",
    });

    print(response.statusCode);
  }

  Future<void> logout() async {
    // Call SharedPreference to get Token

    // Define Laravel API for Logout

    // Request for logging out

    // Check Status Code, remove sharedpreference, then pop to the previous
  }
}
