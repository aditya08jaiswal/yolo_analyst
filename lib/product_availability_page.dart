import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'short_devices_page.dart';
import 'input_dropdown_widget.dart';

class Post {
  final String phone;
  final String password;

  Post({this.phone, this.password});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      phone: json['phone'],
      password: json['password'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["phone"] = phone;
    map["password"] = password;

    return map;
  }
}

Future<Map<String, dynamic>> createPost(String url, Map body,
    BuildContext context) async {
  print(body);
  var body1 = jsonEncode(body);
  print(body);

  Map<String, String> userHeader = {'content-type': 'application/json'};
  return await http
      .post(url, body: body1, headers: userHeader)
      .then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode >= 400 || json == null) {
      SharedPreferences sharedPreferences;
      SharedPreferences.getInstance().then((SharedPreferences sp) {
        sharedPreferences = sp;
        sharedPreferences.setInt("callMapping", 0);
        sharedPreferences?.setBool('Logged_In', false);
      });
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.tag, (Route<dynamic> route) => false);
      throw new Exception("Error while fetching data");
    }
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    return responseBody;
  });
}

class ProductAvailabilityPage extends StatefulWidget {
  static String tag = 'product-availability-page';

  ProductAvailabilityPage({Key key}) : super(key: key);

  @override
  createState() => ProductAvailabilityPageState();
}

class ProductAvailability {
  Future<dynamic> callPostApi(BuildContext context) async {
    String url = Constants.SERVER_ADDRESS +
        '/erp/get/products/?appsessiontoken=' +
        Constants.TOKEN;

    print("PRODUCT AVAILABILITY PAGE CALL POST API CREATE POST URL : " + url);

    return url;
  }

  Future<Map<String, dynamic>> fetchPost(String url,
      BuildContext context) async {
    print(
        "PRODUCT AVAILABILITY PAGE CALL POST API CREATE POST URL CONSTANT TOKEN : " +
            Constants.TOKEN);
    http.Response response =
    await http.get(url, headers: {'content-type': 'application/json'});
    print("PRODUCT AVAILABILITY PAGE FETCH POST STATUS CODE : " +
        response.statusCode.toString());
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return jsonDecode(response.body);
    } else {
      print("PRODUCT AVAILABILITY PAGE FETCH POST STATUS CODE : " +
          response.statusCode.toString());

      SharedPreferences sharedPreferences;
      SharedPreferences.getInstance().then((SharedPreferences sp) {
        sharedPreferences = sp;
        sharedPreferences?.setBool('Logged_In', false);
      });
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.tag, (Route<dynamic> route) => false);
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

class ProductAvailabilityPageState extends State<ProductAvailabilityPage>
    with WidgetsBindingObserver {
  ProductAvailabilityPageState() {
    print('HELLO PRODUCT AVAILABILITY PAGE');
  }

  String dropdownValue = Constants.BASIC;

  final inputCountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences sharedPreferences;
    ProductAvailability productAvailability = new ProductAvailability();
    String url = '';

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;
      url = Constants.SERVER_ADDRESS +
          '/erp/get/products/?appsessiontoken=' +
          sharedPreferences.getString("appsessiontoken");
      print("INITSTATE : " + url);

      productAvailability.fetchPost(url, context).then((responseFetch) {
        print("INITSTATE RESPONSE FETCH : " + responseFetch.toString());

        List<dynamic> productList = responseFetch['body']['products'];

        Constants.SHORT_DEVICES_LIST = productList;

        Constants.PRODUCT_LIST = productList;
        print('PRODUCT LIST ' + Constants.PRODUCT_LIST.toString());
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print('DISPOSE PRODUCT AVAILABILITY PAGE');
    WidgetsBinding.instance.removeObserver(this);

    inputCountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print('INACTIVE PRODUCT AVAILABILITY PAGE');

        SharedPreferences.getInstance().then((SharedPreferences sp) {
          sp.setInt("callMapping", 1);
        });

        break;

      case AppLifecycleState.resumed:
        print('RESUMED PRODUCT AVAILABILITY PAGE');
        break;

      case AppLifecycleState.paused:
        print('PAUSED PRODUCT AVAILABILITY PAGE');
        break;

      case AppLifecycleState.suspending:
        print('SUSPENDING PRODUCT AVAILABILITY PAGE  ');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDevicesButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Color(0xFF337ab7),
      onPressed: () {
        if (inputCountController.text == '') {
          Fluttertoast.showToast(
            msg: "Input a number",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
          );
          throw new Exception("INPUT NUMBER ISSUE");
        } else {
          String url;
          ProductAvailability productAvailability = new ProductAvailability();

          SharedPreferences sharedPreferences;
          SharedPreferences.getInstance().then((SharedPreferences sp) {
            sharedPreferences = sp;

            url = Constants.SERVER_ADDRESS +
                '/erp/get/products/?appsessiontoken=' +
                sharedPreferences.getString("appsessiontoken");

            print(url);

            productAvailability.fetchPost(url, context).then((responseFetch) {
              print(responseFetch);

              List<dynamic> productList = responseFetch['body']['products'];
              print('PRODUCT LIST ' + productList.toString());

              String numberText = inputCountController.text;

              Constants.INPUT_COUNT = int.parse(numberText);

              List<dynamic> shortDeviceList = [];

              print('INPUT NUMBER IN TEXT FIELD : ' +
                  Constants.INPUT_COUNT.toString());

              for (var eachDevice in productList) {
                if (eachDevice['inventory_in_count'] <= Constants.INPUT_COUNT &&
                    eachDevice['machine_types']
                        .toString()
                        .contains(Constants.MACHINETYPE)) {
                  shortDeviceList.add(eachDevice);
                }
              }

              Constants.SHORT_DEVICES_LIST = shortDeviceList;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShortDevicesDataTable(),
                ),
              );
            });
          });
        }
      },
      child: Text("Show Devices",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
              color: Colors.white)),
    );

    final space = const SizedBox(height: 35.0);
    final top = const SizedBox(height: 170.0);

    final input = TextField(
      controller: inputCountController,
      keyboardType: TextInputType.number,
      autofocus: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter number of device',
      ),
      style: TextStyle(
          fontStyle: FontStyle.normal, fontSize: 20.0, color: Colors.black),
    );

    final inputTextField = Container(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
          border: new Border.all(color: Color(0xFF337ab7))),
      child: Row(
        children: <Widget>[
          Expanded(child: input),
        ],
      ),
    );

    final selectMachineType = new Center(
      child: DropdownButton<String>(
        value: dropdownValue,
        style: TextStyle(
            fontStyle: FontStyle.normal, fontSize: 20.0, color: Colors.black),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;

            print("DROP DOWN SELECTED : " + dropdownValue);

            if (dropdownValue == Constants.BASIC) {
              Constants.MACHINETYPE = '1';
              print('BASIC MACHINE TYPE SELECTED : ' + Constants.MACHINETYPE);
            } else if (dropdownValue == Constants.WELLNESS) {
              Constants.MACHINETYPE = '2';
              print(
                  'WELLNESS MACHINE TYPE SELECTED : ' + Constants.MACHINETYPE);
            } else if (dropdownValue == Constants.ADVANCED) {
              Constants.MACHINETYPE = '3';
              print(
                  'ADVANCED MACHINE TYPE SELECTED : ' + Constants.MACHINETYPE);
            }
          });
        },
        items: <String>[Constants.BASIC, Constants.WELLNESS, Constants.ADVANCED]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );

    return Scaffold(
//      appBar: analystAppBar,
      body: DropdownButtonHideUnderline(
        child: SafeArea(
          top: true,
          bottom: true,
          right: true,
          left: true,
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                top,
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(32.0),
                    border: new Border.all(color: Color(0xFF337ab7))),
                child: Row(
                  children: <Widget>[
                    selectMachineType,
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: input,
                    )),
                  ],
                ),
              ),
              space,
              showDevicesButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
