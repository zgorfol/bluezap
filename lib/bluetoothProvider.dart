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
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection _connection;
  List<BluetoothDevice> _devicesList = [];

  var changeController = new StreamController<MyEvent>();

  Stream<MyEvent> get onChange => changeController.stream;
  BluetoothConnection get connection => this._connection;
  bool get isConnected =>
      this._connection != null && this._connection.isConnected;
  BluetoothState get bluetoothState => _bluetoothState;
  List<BluetoothDevice> get devicesList => _devicesList;
  String _snackMessage = "";

  String get snackMessage => _snackMessage;

  set snackMessage(String message) {
    this._snackMessage = message;
    notifyListeners();
  }

  set showMsg(String message) {
    show(message);
  }

  set bluetoothState(BluetoothState blueSt) {
    this._bluetoothState = blueSt;
    notifyListeners();
  }

  set connection(BluetoothConnection _conn) {
    this._connection = _conn;
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
    FlutterBluetoothSerial.instance.state.then((state) {
      bluetoothState = state;
    }).catchError((e) => print(e));
    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();
    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      bluetoothState = state;
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
      bluetoothState = await FlutterBluetoothSerial.instance.state;
      if (bluetoothState == BluetoothState.STATE_OFF) {
        // If the bluetooth is off, then turn it on first
        // and then retrieve the devices that are paired.
        await FlutterBluetoothSerial.instance.requestEnable();
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
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error: Bluetooth PlatformException");
    }
    _devicesList = devices;
  }

  // Method to connect to bluetooth
  void connect() async {
    // _needProgIndicator = true;
    if (ldevice == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(ldevice.address).then((_conn) {
          print('Connected to the device');

          connection = _conn;

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
  }

  // Method to disconnect bluetooth
  void disconnect() async {
    //this._needProgIndicator = false;
    await connection.close().then((_connect) => connection = _connection);
    //connection = _connection;

    show('Device disconnected');
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
      FlutterBluetoothSerial.instance.openSettings();
    } catch (e) {
      print('Bluetooth Setup Error!!!');
    }
  }

  Future<void> switchbl(bool value) async {
    try {
      if (value) {
        await FlutterBluetoothSerial.instance.requestEnable();
      } else {
        await FlutterBluetoothSerial.instance.requestDisable();
      }

      await getPairedDevices();

      if (isConnected) {
        disconnect();
      }
    } catch (e) {
      print("Bluetooth switch exception");
      print(e);
    }
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(String message, {duration: const Duration(seconds: 1)}) async {
    snackMessage = message;
    notifyListeners();
    await new Future.delayed(duration).then((value) => {
          snackMessage = "",
          notifyListeners(),
        });
  }
}
