import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theraphy.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DataProvider extends ChangeNotifier {
  String lsearchStr;
  String lsearchURL;
  Theraphy ltheraphy;
  BluetoothDevice ldevice;

  String get searchStr {
    return lsearchStr;
  }

  set searchStr(String wStr) {
    if (wStr == null) wStr = "";
    lsearchStr = wStr;
    this.saveData();
  }

  String get searchURL {
    return lsearchURL;
  }

  set searchURL(String wStr) {
    if (wStr == null || wStr == "")
      wStr =
          "http://biotronics.eu/rest/bioresonance-therapies?_format=json&title=";
    lsearchURL = wStr;
    this.saveData();
  }

  BluetoothDevice get device {
    return ldevice;
  }

  set device(BluetoothDevice wDev) {
    ldevice = wDev;
    this.saveData();
    notifyListeners();
  }

  Theraphy get theraphy {
    return ltheraphy;
  }

  set theraphy(Theraphy wTer) {
    ltheraphy = wTer;
    this.saveData();
  }

  DataProvider(
      {this.lsearchStr, this.lsearchURL, this.ltheraphy, this.ldevice});

  factory DataProvider.fromJson(String str) =>
      DataProvider.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DataProvider.fromMap(Map<String, dynamic> json) => DataProvider(
        lsearchStr: json["searchStr"],
        lsearchURL: json["searchURL"],
        ltheraphy: json["theraphy"] == null
            ? null
            : Theraphy.fromMap(json["theraphy"]),
        ldevice: json['device'] == null
            ? null
            : BluetoothDevice.fromMap(json['device']),
      );

  Map<String, dynamic> toMap() => {
        "searchStr": this.lsearchStr,
        "searchURL": this.lsearchURL,
        "theraphy": this.ltheraphy == null ? null : this.ltheraphy.toMap(),
        "device": this.ldevice == null ? null : this.ldevice.toMap(),
      };

  final String key = "Data";

  void initdataProvider() {
    this
        .read()
        .then((value) => initdataSaved(value))
        .catchError((onError) => initdataSaved(null));
  }

  void initdataSaved(DataProvider value) {
    if (value == null) {
      value = new DataProvider(
        lsearchStr: 'i',
        lsearchURL:
            "http://biotronics.eu/rest/bioresonance-therapies?_format=json&title=",
      );
    }
    if (value.lsearchURL == null) {
      value.lsearchStr = 'initafterread';
      value.lsearchURL =
          "http://biotronics.eu/rest/bioresonance-therapies?_format=json&title=";
    }
    this.lsearchStr = value.lsearchStr;
    this.lsearchURL = value.lsearchURL;
    this.ltheraphy = value.ltheraphy;
    this.ldevice = value.ldevice;
    notifyListeners();
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint('Data saved!!!');
    prefs.setString(key, this.toJson());
    notifyListeners();
  }

  Future<DataProvider> read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint('Data read!!!');
    return DataProvider.fromJson(prefs.getString(key));
  }
}
