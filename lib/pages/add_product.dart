import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _addFormKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();

  final List<ProductType> _productType = [
    ProductType(1, 'โทรศัพท์มือถือ'),
    ProductType(2, 'สมาร์ททีวี'),
    ProductType(3, 'แท็บเล็ต'),
  ];

  late List<DropdownMenuItem<ProductType>> dropdownMenuItems;
  late ProductType _selectedType;

  @override
  void initState() {
    super.initState();
    dropdownMenuItems = createDropdownMenu(_productType);
    _selectedType = dropdownMenuItems[0].value!;
  }

  List<DropdownMenuItem<ProductType>> createDropdownMenu(
      List<ProductType> dropdownItems) {
    List<DropdownMenuItem<ProductType>> items = [];

    for (var item in dropdownItems) {
      items.add(DropdownMenuItem(
        value: item,
        child: Text(item.name),
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: _addFormKey,
        child: ListView(
          children: [
            inputName(),
            inputPrice(),
            dropdownType(),
            addButton(),
          ],
        ),
      ),
    );
  }

  Container inputName() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 8),
      child: TextFormField(
        controller: _name,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่ชื่อสินค้า';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          icon: Icon(
            Icons.list_alt_sharp,
            color: Colors.blue,
          ),
          label: Text(
            'ชื่อสินค้า',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Container inputPrice() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
      child: TextFormField(
        controller: _price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่ราคาสินค้า';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          icon: Icon(
            Icons.price_check,
            color: Colors.blue,
          ),
          label: Text(
            'ราคาสินค้า',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget dropdownType() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
      child: DropdownButtonFormField(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        value: _selectedType,
        items: dropdownMenuItems,
        onChanged: (value) {
          setState(() {
            _selectedType = value!;
          });
        },
      ),
    );
  }

  Widget addButton() {
    return Container(
      width: 150,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        onPressed: () {
          addProduct();
          Navigator.pop(context);
        },
        child: const Text('เพิ่มข้อมูล'),
      ),
    );
  }

  Future<void> addProduct() async {
    // Call SharedPreference to get Token
    SharedPreferences _pref = await SharedPreferences.getInstance();

    // Check Valid Form
    if (_addFormKey.currentState!.validate()) {
      var json = jsonEncode({
        "pd_name": _name.text,
        "pd_price": double.parse(_price.text),
        "pd_type": _selectedType.value,
      });

      var apiUrl = "https://iamping.pungpingcoding.online/api";
      var url = Uri.parse("$apiUrl/product");

      var response = await http.post(url, body: json, headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_pref.getString('token')}",
      });

      print(response.statusCode);
    }
  }
}

class ProductType {
  int value;
  String name;

  ProductType(this.value, this.name);
}
