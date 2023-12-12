import 'package:bluezap/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'package:provider/provider.dart';
import 'bluetoothProvider.dart';

/*
Map<String, Color> colors = {
  'onBorderColor': Colors.green,
  'offBorderColor': Colors.red,
  'neutralBorderColor': Colors.transparent,
  'onTextColor': Colors.green[700],
  'offTextColor': Colors.red[700],
  'neutralTextColor': Colors.blue,
};
*/

class BluetoothSetup extends StatefulWidget {
  BluetoothSetup();
  @override
  _BluetoothSetupState createState() => _BluetoothSetupState();
}

class _BluetoothSetupState extends State with WidgetsBindingObserver {
  //_BluetoothSetupState();
  late AppLifecycleState state;

  final blState = locator<BluetoothProvider>();

  // BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  //List<BluetoothDevice> _devicesList = [];
  //BluetoothDevice _device;
  //String _snackMessage = "";
  // String _errorMessage;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  //BluetoothConnection _connection;

  final _searchTextCtrl = TextEditingController();
  final ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    /*
    blState.onSnack.listen((e) => {
          if (e.eventData != "")
            {showSnack(e.eventData)}
          else
            {
              if (_scaffoldKey.currentState != null)
                {_scaffoldKey.currentState.removeCurrentSnackBar()}
            }
        });
    */
  }

  @override
  void dispose() {
    //  _route?.removeScopedWillPopCallback(askTheUserIfTheyAreSure);
    //  _route = null;
    WidgetsBinding.instance.removeObserver(this);
    _searchTextCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void showSnack(
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) {
    //_scaffoldKey.currentState.showSnackBar(
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(state);
    state = appLifecycleState;
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
    }
  }

  @override
  Future<bool> didPopRoute() async {
    Navigator.of(context).pop({'device': blState.device});
    return Future<bool>.value(true);
  }

  //var blState;
  //bool blStateInit = true;
//  ModalRoute<dynamic> _route;

  // bool isStateON = false;

  //@override
  //void didChangeDependencies() {
  //  super.didChangeDependencies();

  //   _route?.removeScopedWillPopCallback(askTheUserIfTheyAreSure);
  //   _route = //ModalRoute.withName('/');
  //       ModalRoute.of(context);
  //   _route?.addScopedWillPopCallback(askTheUserIfTheyAreSure);

  // final blueState = Provider.of<BluetoothProvider>(context);
  // if (blStateInit) {
  //   blState = blueState;
  //   blStateInit = false;
  // }

  // _bluetoothState = blState.bluetoothState;
  //_devicesList = blState.devicesList;
  //_device = blState.device;
  //
  //_snackMessage = blState.snackMessage;
  //if (_snackMessage != "") {
  //  show(_snackMessage);
  //} else {
  //  if (_scaffoldKey.currentState != null) {
  //    _scaffoldKey.currentState.removeCurrentSnackBar();
  //  }
  //}

  // }

  List<BluetoothDevice> _devList = [];
  BluetoothState bState = BluetoothState.UNKNOWN;

  Widget bodyView() {
    _devList = blState.devicesList;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: blState.bluetoothState == BluetoothState.STATE_ON
                  ? devicelistTree(_devList)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget pertsistentView() {
    bState = blState.bluetoothState;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            color: Colors.blue,
            icon: Icon(
              Icons.settings_bluetooth_sharp,
            ),
            /*label: Text(
              "",
            ),*/
            onPressed: () {
              blState.bluetoothsetup();
            },
          ),
          IconButton(
            color: Colors.blue,
            icon: Icon(Icons.refresh_sharp),
            /*label: Text(
              "",
            ),*/
            onPressed: () async {
              await blState.getPairedDevices().then((_) {
                setState(() {
                  _devList = blState.devicesList;
                });
                showSnack('Device list refreshed');
              });
            },
          ),
          IconButton(
            color: Colors.blue,
            icon: bState == BluetoothState.STATE_ON
                ? Icon(Icons.toggle_on_sharp)
                : Icon(Icons.toggle_off),
            /*label: Text(
              "",
            ),*/
            onPressed: () async {
              await blState.switchbl().then((value) => {
                    setState(() {
                      bState = value;
                    })
                    // bState = value,
                  });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => didPopRoute(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Bluetooth setup"),
          actions: [],
        ),
        body: bodyView(),
        persistentFooterButtons: [
          pertsistentView(),
        ],
      ),
    );
  }

  Widget devicelistTree(List _devicesList) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: _devicesList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10.0),
        itemBuilder: (BuildContext context, int index) {
          var data = _devicesList[index];
          var address = blState.device == null ? null : blState.device.address;
          return GestureDetector(
            onTap: () => {
              showSnack("${data.name}"),
              setState(() {
                blState.device = data;
              }),
            },
            child: Text(
              "\n ${data.name}",
              style: TextStyle(
                backgroundColor: data.address == address
                    ? Theme.of(context).colorScheme.secondary //accentColor
                    : Theme.of(context).dialogBackgroundColor,
                fontSize: 18.0,
              ),
            ),
          );
        });
  }

/*
  void show(
    String message, {
    Duration duration: const Duration(seconds: 1),
  }) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
  */
}
