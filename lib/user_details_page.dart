import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'constants.dart';

class UserDetails {
  UserDetails(
    this.userDate,
    this.userName,
    this.email,
    this.phoneNumber,
    this.kioskId,
  );

  final String userDate;
  final String userName;
  final String email;
  final String phoneNumber;
  final int kioskId;
}

class UserDetailsDataSource extends DataTableSource {
  List<UserDetails> _userDetails = getUserDetailsList();

  static List<UserDetails> getUserDetailsList() {
    List<UserDetails> _userDetailsList = [];

    for (var eachUser in Constants.USER_LIST) {
      print(eachUser['datetime'].toString());
      String datetime = eachUser['datetime'];
      String userName = eachUser['username'];
      String phone = eachUser['phone'];
      String email = eachUser['email'];
      int kioskId = eachUser['kioskid'];
      _userDetailsList
          .add(UserDetails(datetime, userName, phone, email, kioskId));
    }
    return _userDetailsList;
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final UserDetails user = _userDetails[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${user.userDate}')),
        DataCell(Text('${user.userName}')),
        DataCell(Text('${user.email}')),
        DataCell(Text('${user.phoneNumber}')),
        DataCell(Text('${user.kioskId}')),
      ],
    );
  }

  @override
  int get rowCount => _userDetails.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class UserDetailsDataTable extends StatefulWidget {
  static const String tag = 'user-details';

  @override
  _UserDetailsDataTableState createState() => _UserDetailsDataTableState();
}

class _UserDetailsDataTableState extends State<UserDetailsDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  static List<dynamic> listOfUser;

  final UserDetailsDataSource _userDetailsDataSource = UserDetailsDataSource();

  @override
  Widget build(BuildContext context) {
    final userDetailsAppBar = new AppBar(
        automaticallyImplyLeading: true,
        title: Text('User Details',
            style: TextStyle(fontStyle: FontStyle.normal, color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, false),
        ));

    final userDetailsTable = new PaginatedDataTable(
      header: const Text('User Details'),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (int value) {
        setState(() {
          _rowsPerPage = value;
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: <DataColumn>[
        DataColumn(
          label: const Text('Date'),
        ),
        DataColumn(
          label: const Text('User Name'),
        ),
        DataColumn(
          label: const Text('Phone'),
        ),
        DataColumn(
          label: const Text('Email'),
        ),
        DataColumn(
          label: const Text('Kiosk'),
          numeric: true,
        ),
      ],
      source: _userDetailsDataSource,
    );

    return Scaffold(
      appBar: userDetailsAppBar,
      body: SafeArea(
        top: true,
        bottom: true,
        right: true,
        left: true,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            userDetailsTable,
          ],
        ),
      ),
    );
  }
}
