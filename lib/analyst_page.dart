import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'date_time_picker_widget.dart';
import 'complete_kiosk_list_page.dart';
import 'invoice_details_page.dart';
import 'user_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

Future<Map<String, dynamic>> createPost(
    String url, Map body, BuildContext context) async {
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

class AnalystPage extends StatefulWidget {
  static String tag = 'analyst-page';

  AnalystPage({Key key}) : super(key: key);

  @override
  createState() => AnalystPageState();
}

class Analyst {
  static List<String> kioskTagList = [];
  static String loginAnalyst = 'loginanalyst';
  String kioskList = '';

  // ignore: non_constant_identifier_names
  String CREATE_POST_URL = Constants.SERVER_ADDRESS +
      '/' +
      Constants.PLATFORM +
      '/' +
      loginAnalyst +
      '/';

  Future<List<String>> callPostApi(int id, BuildContext context) async {
    if (id == 0) {
      Post newPost =
          new Post(phone: Constants.USERNAME, password: Constants.PASSWORD);

      Map<String, dynamic> responsePostApi =
          await createPost(CREATE_POST_URL, newPost.toMap(), context);
      int i = 0;
      List<dynamic> allKioskTags = responsePostApi['body']['kiosklist'];

      for (var allKioskTag in allKioskTags) {
        i++;
        kioskTagList.add(allKioskTag['kiosktag']);
      }
      print(i);
    }

    return kioskTagList;
  }

  Future<Map<String, dynamic>> fetchPost(
      String url, BuildContext context) async {
    print(Constants.TOKEN);
    http.Response response =
        await http.get(url, headers: {'content-type': 'application/json'});
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);

      SharedPreferences sharedPreferences;
      SharedPreferences.getInstance().then((SharedPreferences sp) {
        sharedPreferences = sp;
        sharedPreferences.setInt("callMapping", 0);
        sharedPreferences?.setBool('Logged_In', false);
      });
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.tag, (Route<dynamic> route) => false);
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

class AnalystPageState extends State<AnalystPage> with WidgetsBindingObserver {
  AnalystPageState() {
    print('hello');
  }

  List<String> _allKiosk = Constants.KIOSKTAGLIST;

  @override
  void initState() {
    super.initState();
    setState(() {
      Constants.SELECTEDKIOSKNUMBER = Constants.KIOSKSTR.split(',').length;
    });
    SharedPreferences sharedPreferences;
    Analyst analyst = new Analyst();
    int userId;
    String url = '';

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      print('CALL MAPPING : ' + sp.getInt("callMapping").toString());
      sharedPreferences = sp;
      userId = sharedPreferences?.getInt('userid');
      if (sharedPreferences.getInt("callMapping") == 1) {
        sharedPreferences.setInt("callMapping", 0);
        url = Constants.SERVER_ADDRESS +
            '/User/getKioskUserTypeMapping/?appsessiontoken=' +
            sharedPreferences.getString("appsessiontoken") +
            '&filetype=analyst&userid=' +
            userId.toString();
        print(url);

        String kioskString = '';
        List<String> kioskTagList = [];
        analyst.fetchPost(url, context).then((responseFromMapping) {
          print(responseFromMapping);
          List<dynamic> kioskLists = responseFromMapping['body']['kiosklist'];

          for (var kiosk in kioskLists) {
            LoginPage.mapping[kiosk['kiosktag']] = kiosk['kioskid'];
            print('KIOSK MAPPED ID ' +
                LoginPage.mapping[kiosk['kiosktag']].toString());
            kioskString = kioskString + kiosk['kioskid'].toString() + ",";
            kioskTagList.add(kiosk['kiosktag']);
          }
          kioskTagList.add(kioskString.substring(0, kioskString.length - 1));
          Constants.KIOSKSTR = kioskTagList.last;
          setState(() {
            Constants.SELECTEDKIOSKNUMBER =
                Constants.KIOSKSTR.split(',').length;
          });
          print(kioskTagList.last);
          kioskTagList.removeLast();
          Constants.KIOSKTAGLIST = kioskTagList;
          print(Constants.KIOSKTAGLIST);

          print(Constants.KIOSKSTR);
        });
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print('DISPOSE');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print('INACTIVE ANALYST PAGE');

        SharedPreferences.getInstance().then((SharedPreferences sp) {
          sp.setInt("callMapping", 1);
        });

        break;

      case AppLifecycleState.resumed:
        print('RESUMED ANALYST PAGE');
        break;

      case AppLifecycleState.paused:
        print('PAUSED ANALYST PAGE');
        break;

      case AppLifecycleState.suspending:
        print('SUSPENDING ANALYST PAGE  ');
        break;
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String kiosk in _allKiosk) {
      items.add(new DropdownMenuItem(value: kiosk, child: new Text(kiosk)));
    }
    print(_allKiosk);
    return items;
  }

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final analystAppBar = new AppBar(
      title: Text('Analyst Panel',
          style: TextStyle(fontStyle: FontStyle.normal, color: Colors.white)),
    );

    final showResultButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Color(0xFF337ab7),
      onPressed: () {
        if (Constants.FROMDATE.difference(Constants.TODATE).inDays > 0) {
          setState(() {
            Constants.INVOICE_DETAILS = 0;
            Constants.USERLIST = 0;
            Constants.TOTALAMOUNT = 0;
            Constants.UNPAIDAMOUNT = 0;
          });
          Fluttertoast.showToast(
            msg: "End Date should be greater than Start date",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
          );
          throw new Exception("Date isuue");
        } else {
          String url;
          Analyst analyst = new Analyst();

          SharedPreferences sharedPreferences;
          SharedPreferences.getInstance().then((SharedPreferences sp) {
            sharedPreferences = sp;

            url = Constants.SERVER_ADDRESS +
                '/BodyVitals/getAllTestCountForDateRangeAndKiosk/?appsessiontoken=' +
                sharedPreferences.getString("appsessiontoken") +
                '&enddate=' +
                Constants.TODATE
                    .add(new Duration(days: 1))
                    .toString()
                    .split(' ')[0] +
                '&kioskstr=' +
                Constants.KIOSKSTR +
                '&startdate=' +
                Constants.FROMDATE.toString().split(' ')[0];
            print(url);

            analyst.fetchPost(url, context).then((responseFetch) {
              print(responseFetch);

              setState(() {
                Constants.INVOICE_DETAILS =
                    responseFetch['body']['invoicedata']['invoicecount'];
                Constants.USERLIST = responseFetch['body']['totaluser'];
                Constants.TOTALAMOUNT =
                    responseFetch['body']['invoicedata']['invoiceamount'];
                Constants.UNPAIDAMOUNT =
                    responseFetch['body']['invoicedata']['invoiceamountunpaid'];

                if (Constants.INVOICE_DETAILS.toString() == "null") {
                  Constants.INVOICE_DETAILS = 0;
                }

                if (Constants.TOTALAMOUNT.toString() == "null") {
                  Constants.TOTALAMOUNT = 0;
                }

                if (Constants.UNPAIDAMOUNT.toString() == "null") {
                  Constants.UNPAIDAMOUNT = 0;
                }
              });

              print(Constants.INVOICE_DETAILS);
              print(Constants.USERLIST);
            });
          });
        }
      },
      child: Text("Show Result",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
              color: Colors.white)),
    );

    final selectKioskButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Color(0xFF337ab7),
      onPressed: () {
        if (Constants.FROMDATE.difference(Constants.TODATE).inDays > 0) {
          setState(() {
            Constants.INVOICE_DETAILS = 0;
            Constants.USERLIST = 0;
            Constants.TOTALAMOUNT = 0;
            Constants.UNPAIDAMOUNT = 0;
          });
          Fluttertoast.showToast(
            msg: "End Date should be greater than Start date",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
          );
          throw new Exception("Date isuue");
        } else {
          Navigator.pushReplacementNamed(context, KioskDataTable.tag);
        }
      },
      child: Text("${Constants.SELECTEDKIOSKNUMBER} Kiosks Selected",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
              color: Colors.white)),
    );

    final fromDate = new DateTimePicker(
      labelText: 'From',
      selectedDate: Constants.FROMDATE,
      selectDate: (DateTime date) {
        setState(() {
          _fromDate = date;
          Constants.FROMDATE = _fromDate;
        });
      },
    );

    final toDate = new DateTimePicker(
      labelText: 'To',
      selectedDate: Constants.TODATE,
      selectDate: (DateTime date) {
        setState(() {
          _toDate = date;
          Constants.TODATE = _toDate;
        });
      },
    );

    final space = const SizedBox(height: 40.0);

    final Color cardBackgroundColor = const Color(0xFF337ab7);
    final Color cardDetailColor = const Color(0xFFF5F5F5);

    final invoiceDetailsCard = Card(
      elevation: 5.0,
      color: cardDetailColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 100,
            color: cardBackgroundColor,
            child: ListTile(
              leading: Icon(
                Icons.assignment,
                color: Colors.white,
                size: 30.0,
              ),
              title: Text('Invoice Details',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0,
                      color: Colors.white)),
              trailing: Text(Constants.INVOICE_DETAILS.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontSize: 45.0,
                      color: Colors.white)),
              onTap: () {
                print('Invoice Card tapped');
              },
            ),
          ),
          InkWell(
            splashColor: cardBackgroundColor,
            onTap: () {
              DateTime endDate = Constants.TODATE;
              String startDateValue =
                  Constants.FROMDATE.toString().split(' ')[0];
              String endDateValue =
                  endDate.add(new Duration(days: 1)).toString().split(' ')[0];
              print(endDateValue);
              print(endDate);
              String kioskIdList = Constants.KIOSKSTR;

              Analyst analyst = new Analyst();
              SharedPreferences sharedPreferences;
              SharedPreferences.getInstance().then((SharedPreferences sp) {
                sharedPreferences = sp;

                String url = Constants.SERVER_ADDRESS +
                    '/BodyVitals/getTestDataForDateRangeAndKiosk/?appsessiontoken=' +
                    sharedPreferences.getString("appsessiontoken") +
                    '&machinestr=transactionlist&enddate=' +
                    endDateValue +
                    '&kioskstr=' +
                    kioskIdList +
                    '&startdate=' +
                    startDateValue;

                print(url);

                analyst.fetchPost(url, context).then((ss) {
                  List<dynamic> list = ss['body']['transactionlist'];
                  print(list);
                  Constants.INVOICE_LIST = list;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceDetailsDataTable(),
                    ),
                  );
                });
              });
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text('Total Amount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: cardBackgroundColor)),
                              Text('${Constants.TOTALAMOUNT}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: cardBackgroundColor)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text('Unpaid Amount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: cardBackgroundColor)),
                              Text('${Constants.UNPAIDAMOUNT}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color: cardBackgroundColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: cardBackgroundColor,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final userRegisteredCard = Card(
      elevation: 5.0,
      color: cardDetailColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 100,
            color: cardBackgroundColor,
            child: ListTile(
              leading: Icon(
                Icons.supervisor_account,
                color: Colors.white,
                size: 30.0,
              ),
              title: Text('User Registered',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0,
                      color: Colors.white)),
              trailing: Text(Constants.USERLIST.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontSize: 45.0,
                      color: Colors.white)),
              onTap: () {
                print('User Registered tapped');
              },
            ),
          ),
          InkWell(
            splashColor: cardBackgroundColor,
            onTap: () {
              DateTime endDate = Constants.TODATE;
              String startDateValue =
                  Constants.FROMDATE.toString().split(' ')[0];
              String endDateValue =
                  endDate.add(new Duration(days: 1)).toString().split(' ')[0];
              print(endDateValue);
              print(endDate);
              String kioskIdList = Constants.KIOSKSTR;

              Analyst analyst = new Analyst();
              SharedPreferences sharedPreferences;
              SharedPreferences.getInstance().then((SharedPreferences sp) {
                sharedPreferences = sp;

                String url = Constants.SERVER_ADDRESS +
                    '/BodyVitals/getTestDataForDateRangeAndKiosk/?appsessiontoken=' +
                    sharedPreferences.getString("appsessiontoken") +
                    '&machinestr=userlist&enddate=' +
                    endDateValue +
                    '&kioskstr=' +
                    kioskIdList +
                    '&startdate=' +
                    startDateValue;

                print(url);

                analyst.fetchPost(url, context).then((ss) {
                  List<dynamic> list = ss['body']['userlist'];
                  print(list);
                  Constants.USER_LIST = list;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsDataTable(),
                    ),
                  );
                });
              });
            },
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: const Text('View Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0,
                              color: Color(0xFF337ab7))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: cardBackgroundColor,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: analystAppBar,
      body: DropdownButtonHideUnderline(
        child: SafeArea(
          top: true,
          bottom: true,
          right: true,
          left: true,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              fromDate,
              toDate,
              space,
              selectKioskButton,
              showResultButton,
              space,
              invoiceDetailsCard,
              space,
              userRegisteredCard
            ],
          ),
        ),
      ),
    );
  }
}
