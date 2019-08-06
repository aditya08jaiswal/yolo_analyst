import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'analyst_page.dart';
import 'constants.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_availability_page.dart';

class TabPage extends StatefulWidget {
  static String tag = 'tab-page';

  @override
  State<StatefulWidget> createState() {
    return TabsState();
  }
}

class AppBarChoice {
  const AppBarChoice({this.title});

  final String title;
}

class TabsState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    List<AppBarChoice> listOfAppBarChoices = <AppBarChoice>[
      AppBarChoice(title: 'Logout'),
    ];

    void _selectAppBarChoice(AppBarChoice select) {
      setState(() {
        print("MENU CHOICE WORKING");

        Constants.USERNAME = '';
        Constants.PASSWORD = '';
        Constants.BASIC_DISPATCH = 0;
        Constants.BASIC_ASSEMBLED = 0;
        Constants.WELLNESS_DISPATCH = 0;
        Constants.WELLNESS_ASSEMBLED = 0;
        Constants.ADVANCED_DISPATCH = 0;
        Constants.ADVANCED_ASSEMBLED = 0;

        SharedPreferences sharedPreferences;
        SharedPreferences.getInstance().then((SharedPreferences sp) {
          sharedPreferences = sp;
          sharedPreferences.setInt("callMapping", 0);
          sharedPreferences?.setBool('Logged_In', false);
        });
        Navigator.of(context).pushNamedAndRemoveUntil(
            LoginPage.tag, (Route<dynamic> route) => false);
      });
    }

    return DefaultTabController(
        length: 3,
        child: new Scaffold(
          appBar: AppBar(
            title: Text('YOLO Management',
                style: TextStyle(
                    fontStyle: FontStyle.normal, color: Colors.white)),
            actions: <Widget>[
              PopupMenuButton<AppBarChoice>(
                onSelected: _selectAppBarChoice,
                itemBuilder: (BuildContext context) {
                  return listOfAppBarChoices.map((AppBarChoice choice) {
                    return PopupMenuItem<AppBarChoice>(
                      value: choice,
                      child: Text(choice.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0,
                              color: Colors.black)),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: TabBar(
                unselectedLabelColor: Colors.white70,
                labelColor: Colors.white,
                indicatorWeight: 3,
                indicatorColor: Colors.white,
                labelStyle:
                    TextStyle(fontStyle: FontStyle.normal, fontSize: 20.0),
                tabs: [
                  Tab(
                    text: "Analyst",
                  ),
                  Tab(
                    text: "Inventory",
                  ),
                  Tab(
                    text: "Product",
                  ),
                ]),
          ),
          body: TabBarView(children: [
            new Container(
              child: AnalystPage(),
            ),
            new Container(
              child: InventoryPage(),
            ),
            new Container(
              child: ProductAvailabilityPage(),
            ),
          ]),
        ));
  }
}
