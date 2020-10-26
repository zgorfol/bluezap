import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:bluezap/theraphy.dart';
import 'bluetoothProvider.dart';
import 'searchonweb.dart';
import 'package:bluezap/main.dart';

class TerminalApp extends StatefulWidget {
  const TerminalApp({Key key}) : super(key: key);
  @override
  _TerminalAppState createState() => _TerminalAppState();
}

class _TerminalAppState extends State with WidgetsBindingObserver {
  AppLifecycleState state;

  bool _isConnected = false;
  String lsearchStr;
  String lsearchURL;
  Theraphy ltheraphy;
  BluetoothDevice ldevice;
  List<String> _termStr = new List();

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _snackMessage = "";
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController myController;

  @override
  void initState() {
    super.initState();
    _termStr.clear();
    myController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
  }

  var blState;
  bool blStateInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final blueState = Provider.of<BluetoothProvider>(context);

    if (blStateInit) {
      blState = blueState;
      blState.onChange.listen((e) => {
            addTotermStr(e.eventData),
          });
      blStateInit = false;
    }

    _isConnected = blState.isConnected;
    lsearchStr = blState.lsearchStr;
    lsearchURL = blState.lsearchURL;
    ltheraphy = blState.ltheraphy;
    ldevice = blState.device;

    _bluetoothState = blState.bluetoothState;

    _snackMessage = blState.snackMessage;
    if (_snackMessage != "") {
      show(_snackMessage);
    } else {
      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState.removeCurrentSnackBar();
      }
    }
  }

  void show(
    String message, {
    Duration duration: const Duration(seconds: 1),
  }) {
    // WidgetsBinding.instance.addPostFrameCallback(
    //(_) =>
    _scaffoldKey.currentState
        //Scaffold.of(context)
        //..removeCurrentSnackBar()
        .showSnackBar(
      SnackBar(
        content: Text(message),
        //duration: duration,
      ),
      //    ..removeCurrentSnackBar(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    myController.dispose();
    _scrollController.dispose();
    _termStr.clear();
    super.dispose();
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

  void addTotermStr(String addStr) {
    setState(() {
      _termStr.length == 0 ||
              _termStr.last.substring(_termStr.last.length - 1) == '\n'
          ? _termStr.add(addStr)
          : _termStr.last += addStr;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 1000,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  Widget keyboardDismisser({BuildContext context, Widget child}) {
    final gesture = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: child,
    );
    return gesture;
  }

  Widget textSearchSend() {
    return TextField(
      autofocus: false,
      controller: myController,
    );
  }

  Widget terminalBody() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Visibility(
            visible: _bluetoothState == BluetoothState.UNKNOWN,
            child: LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _termStr.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Text(_termStr[index]);
                  }),
            ),
          ),
          Column(
            children: [
              Row(
                children: <Widget>[
                  Text('Search / Send :  '),
                  Expanded(
                    child: textSearchSend(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget drawerOnly() {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Container(
              height: 142,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/launcher/icon.png",
              )),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
        ListTile(
          title: Text("Terminal"),
          onTap: () {
            setState(() {
              Navigator.of(context).pop();
              terminalBody();
            });
          },
        ),
        ListTile(
          title: Text("Bluetooth setup"),
          onTap: () {
            if (_isConnected) {
              blState.disconnect();
            }
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => BluetoothSetupProvider(),
                    ),
                    // _route
                    ModalRoute.withName('/'))
                .then((results) => {
                      if (results != null && results.containsKey('device'))
                        {
                          blState.device = results['device'],
                        }
                    });
          },
        ),
      ],
    ));
  }

  Future downloadScript() async {
    addTotermStr(ltheraphy.fieldscript);
    await blState.sendMessageToBluetooth('mem\r\n@\r\n').then((valu1) => {
          Future.delayed(Duration(milliseconds: 100)).then((value) => {
                blState
                    .sendMessageToBluetooth('mem @\r\n' + ltheraphy.fieldscript)
                    .then(
                      (value2) => {
                        blState.show('Userprogram stored!'),
                      },
                    ),
              }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return this.keyboardDismisser(
      context: context,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("blueZAP"), actions: <Widget>[
          ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
            FlatButton.icon(
              icon: Icon(
                Icons.restore_from_trash,
                color: Theme.of(context).iconTheme.color,
              ),
              label: Text(
                "",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onPressed: () {
                setState(() {
                  _termStr.clear();
                });
              },
            ),
            FlatButton.icon(
              icon: _isConnected
                  ? Icon(
                      Icons.bluetooth_connected,
                      color: Theme.of(context).indicatorColor,
                    )
                  : Icon(
                      Icons.bluetooth_disabled,
                      color: Theme.of(context).errorColor,
                    ),
              label: Text(
                "",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              onPressed: () {
                setState(() {
                  try {
                    _bluetoothState = BluetoothState.UNKNOWN;
                    _isConnected ? blState.disconnect() : blState.connect();
                  } catch (e) {
                    print(e);
                  }
                });
              },
            ),
          ]),
        ]),
        drawer: drawerOnly(),
        body: terminalBody(),
        persistentFooterButtons: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(
                    Icons.download_sharp,
                  ),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    try {
                      if (ltheraphy.fieldscript != null) {
                        _isConnected
                            ? downloadScript()
                            : blState.show('Bluetooth is disconected!');
                      }
                    } catch (e) {
                      blState.show('Search a theraphy first!');
                    }
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.search_sharp),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    _searchTheraphy(context);
                  },
                ),
                FlatButton.icon(
                  icon: Icon(Icons.keyboard_return_rounded),
                  label: Text(
                    "",
                  ),
                  onPressed: () {
                    blState.searchStr = myController.text;
                    _isConnected
                        ? blState.sendMessageToBluetooth(myController.text)
                        : blState.show('Bluetooth is disconected!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _searchTheraphy(BuildContext context) async {
    blState.searchStr = myController.text;
    try {
      final Theraphy chooseTheraphy = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchOnWeb(lsearchURL + myController.text),
        ),
      );
      if (chooseTheraphy != null) {
        blState.theraphy = chooseTheraphy;
        addTotermStr(chooseTheraphy.fieldscript);
      }
    } catch (e) {}
  }
}
