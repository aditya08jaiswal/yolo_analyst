import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'constants.dart';

class ShortDevices {
  ShortDevices(
      this.id,
      this.deviceName,
      this.manufacturer,
      this.devicesInStock,
      this.model,
      );

  final int id;
  final String deviceName;
  final String manufacturer;
  final int devicesInStock;
  final String model;
}

class ShortDevicesDataSource extends DataTableSource {
  static List<ShortDevices> getShortDevicesList() {
    List<ShortDevices> _shortDevicesList = [];

    for (var eachDevice in Constants.SHORT_DEVICES_LIST) {
      int id = eachDevice['id'];
      String deviceName = eachDevice['device'];
      String manufacturer = eachDevice['manufacturer'];
      int devicesInStock = eachDevice['inventory_in_count'];
      String model = eachDevice['model'];

      _shortDevicesList.add(ShortDevices(id, deviceName, manufacturer,
          devicesInStock, model));
    }
    return _shortDevicesList;
  }

  List<ShortDevices> _shortDevices = getShortDevicesList();
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _shortDevices.length) return null;
    final ShortDevices invoice = _shortDevices[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${invoice.id}')),
        DataCell(Text('${invoice.deviceName}')),
        DataCell(Text('${invoice.manufacturer}')),
        DataCell(Text('${invoice.model}')),
        DataCell(Text('${invoice.devicesInStock}')),
      ],
    );
  }

  @override
  int get rowCount => _shortDevices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class ShortDevicesDataTable extends StatefulWidget {
  static const String tag = 'short-devices';

  @override
  _ShortDevicesDataTableState createState() =>
      _ShortDevicesDataTableState();
}

class _ShortDevicesDataTableState extends State<ShortDevicesDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  static List<dynamic> listOfInvoice;

  ShortDevicesDataSource _invoiceDetailsDataSource =
  new ShortDevicesDataSource();

  @override
  Widget build(BuildContext context) {
    final invoiceDetailsAppBar = new AppBar(
        automaticallyImplyLeading: true,
        title: Text('Short Devices',
            style: TextStyle(fontStyle: FontStyle.normal, color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, false),
        ));

    final shortDeviceListTable = new PaginatedDataTable(
      header: const Text('Short Devices'),
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
          label: const Text('ID'),
        ),
        DataColumn(
          label: const Text('Device Name'),
          numeric: true,
        ),
        DataColumn(
          label: const Text('Manufacturer'),
        ),
        DataColumn(
          label: const Text('Model'),
        ),
        DataColumn(
          label: const Text('Devices in Stock'),
          numeric: true,
        ),
      ],
      source: _invoiceDetailsDataSource,
    );

    return Scaffold(
      appBar: invoiceDetailsAppBar,
      body: SafeArea(
        top: true,
        bottom: true,
        right: true,
        left: true,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            shortDeviceListTable,
          ],
        ),
      ),
    );
  }
}
