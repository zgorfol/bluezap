import 'package:bluezap/locator.dart';
import 'package:flutter/material.dart';
import 'package:bluezap/bluetoothSetup.dart';
// import 'package:provider/provider.dart';

import 'terminalapp.dart';
//import 'bluetoothProvider.dart';
//import 'pages/bluetoothSetup.dart';

void main() {
  locator_init();
  runApp(MyApp());
}

/*
class TerminalAppProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BluetoothProvider>(
      create: (_) {
        return BluetoothProvider();
      },
      child: TerminalApp(),
    );
  }
}

class BluetoothSetupProvider extends TerminalAppProvider {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BluetoothProvider>(
      create: (_) {
        return BluetoothProvider();
      },
      child: BluetoothSetup(),
    );
  }
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'blueZAP',

      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.green,
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        errorColor: Colors.redAccent, // for bluetooth off button
        indicatorColor: Colors.lightGreenAccent,
        dialogBackgroundColor: Colors.white, // bluetooth on button
      ),
      routes: {
        '/': (BuildContext context) => TerminalApp(),
        '/bluetooth': (BuildContext context) => BluetoothSetup(),
      },
      initialRoute: '/',
      //home: TerminalAppProvider(),
    );
  }
}

/*
class MainScreen extends StatelessWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return TerminalApp();
                },
              ),
            );
          },
          child: Text('Go To StatefulWidget Screen'),
        ),
      ),
    );
  }
}
*/

/*

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'blueZAP',

      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.green,
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      //    primarySwatch: Colors.blue,
      //routes: {
      // '/': (BuildContext context) => TerminalApp(),
      //  '/Terminal': (BuildContext context) => TerminalApp(),
      //},
      initialRoute: '/',
      home: TerminalApp(),
    );
  }
}
*/
