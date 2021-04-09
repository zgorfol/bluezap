import 'dart:async';
import 'dart:convert';

//import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluezap/dataProvider.dart';

class MyEvent {
  String eventData;

  MyEvent(this.eventData);
}

class BluetoothProvider extends DataProvider {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool _progressBar = false;
  BluetoothConnection _connection;
  List<BluetoothDevice> _devicesList = [];

  var changeController = new StreamController<MyEvent>();
  var SnackController = new StreamController<MyEvent>();

  Stream<MyEvent> get onChange => changeController.stream;
  Stream<MyEvent> get onSnack => SnackController.stream;

  BluetoothConnection get connection => this._connection;
  bool get isConnected => connection != null && connection.isConnected;

  bool get progressBar => _progressBar;
  BluetoothState get bluetoothState => _bluetoothState;

  //bool get isblStateON => _bluetoothState == BluetoothState.STATE_ON;

  List<BluetoothDevice> get devicesList => _devicesList;

  /*
  String _snackMessage = "";

  String get snackMessage => _snackMessage;

  set snackMessage(String message) {
    this._snackMessage = message;
    notifyListeners();
  }
  */
/*
  set showMsg(String message) {
    show(message);
  }
*/

  set progressBar(bool progBar) {
    _progressBar = progBar;
    notifyListeners();
  }

  set devicesList(List<BluetoothDevice> devLst) {
    _devicesList = devLst;
    notifyListeners();
  }

  set bluetoothState(BluetoothState blueSt) {
    _bluetoothState = blueSt;
    notifyListeners();
  }

  set connection(BluetoothConnection _conn) {
    _connection = _conn;
    notifyListeners();
  }

  BluetoothProvider() {
    this
        .read()
        .then((value) => {
              initdataSaved(value),
              initBlueState(),
            })
        .catchError((onError) => {
              initdataSaved(null),
              initBlueState(),
            });
  }

  void initBlueState() {
    // Get current state
    _bluetooth.state.then((state) {
      bluetoothState = state;
      //notifyListeners();
    }).catchError((e) => print(e));
    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();
    // Listen for further state changes
    _bluetooth.onStateChanged().listen((BluetoothState state) {
      bluetoothState = state;
      //notifyListeners();
      getPairedDevices();
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state

    try {
      bluetoothState = await _bluetooth.state;
      //notifyListeners();
      if (bluetoothState != BluetoothState.STATE_ON) {
        // If the bluetooth is off, then turn it on first
        // and then retrieve the devices that are paired.
        await _bluetooth.requestEnable();
        await getPairedDevices();
        return true;
      } else {
        await getPairedDevices();
      }
    } catch (e) {
      print('Bluetooth init exception!!!');
      print(e);
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<bool> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error: Bluetooth PlatformException");
    }
    devicesList = devices;
    return true;
  }

  // Method to connect to bluetooth
  Future<bool> connect() async {
    // _needProgIndicator = true;
    if (ldevice == null) {
      await show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(ldevice.address).then((_conn) {
          print('Connected to the device');

          connection = _conn;
          //notifyListeners();

          connection.input.listen(
            (data) {
              //Data entry point
              changeController.add(MyEvent(String.fromCharCodes(data)));
            },
            onError: (err) {
              print('Error!');
            },
            onDone: () {
              print('Done!');
            },
          );
          show('Device connected');
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          //print(error);
          // this._needProgIndicator = false;
          show('Device connection failed !');
        });
      }
    }
    return true;
  }

  // Method to disconnect bluetooth
  Future<bool> disconnect() async {
    //this._needProgIndicator = false;
    await connection.close().then((_connect) => {
          connection = _connection,
          //notifyListeners(),
        });
    //connection = _connection;

    await show('Device disconnected');
    return true;
  }

  // Method to send message,
  // for turning the Bluetooth device on
  Future sendMessageToBluetooth(String inTxt) async {
    if (isConnected) {
      connection.output.add(ascii.encode(inTxt + "\r\n"));
      await connection.output.allSent
          .then((value) => show('Message sent : ' + inTxt));
    }
  }

  void bluetoothsetup() {
    try {
      _bluetooth.openSettings();
    } catch (e) {
      print('Bluetooth Setup Error!!!');
    }
  }

  Future<BluetoothState> switchbl() async {
    try {
      if (bluetoothState != BluetoothState.STATE_ON) {
        await _bluetooth.requestEnable();
      } else {
        await _bluetooth.requestDisable();
      }

      await getPairedDevices();

      if (isConnected) {
        await disconnect();
      }
      bluetoothState = await _bluetooth.state;
    } catch (e) {
      print("Bluetooth switch exception");
      print(e);
    }
    return bluetoothState;
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(String message, {duration: const Duration(seconds: 1)}) async {
    //snackMessage = message;
    SnackController.add(MyEvent(message));
    /*
    notifyListeners();
    await new Future.delayed(duration).then((value) => {
          //snackMessage = "",
          notifyListeners(),
        });
    */
  }
}
