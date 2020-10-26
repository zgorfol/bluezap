import 'package:flutter/material.dart';

class PageWrapper extends StatefulWidget {
  final Widget page;

  PageWrapper(this.page);

  @override
  _PageWrapperState createState() => _PageWrapperState(this.page);
}

class _PageWrapperState extends State<PageWrapper> {
  final Widget page;

  _PageWrapperState(this.page);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: page);
  }
}
