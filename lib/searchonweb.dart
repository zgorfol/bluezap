import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theraphy.dart';

class SearchOnWeb extends StatefulWidget {
  final String searchStr;
  SearchOnWeb(this.searchStr);
  @override
  _SearchOnWebState createState() => _SearchOnWebState(
        searchStr: searchStr,
      );
}

class _SearchOnWebState extends State<SearchOnWeb> {
  final String searchStr;
  _SearchOnWebState({required this.searchStr});

  late Future<List<Theraphy>> futureTheraphy;

  @override
  void initState() {
    super.initState();
    futureTheraphy = fetchTheraphy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search theraphy'),
      ),
      body: Center(
        child: FutureBuilder<List<Theraphy>>(
          future: futureTheraphy,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: List.generate(snapshot.data?.length ?? 0, (index) {
                  return ListTile(
                      //padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(snapshot.data?[index].title.toString() ?? ""),
                          Text(snapshot.data?[index].fieldurzadzenie
                                  .toString() ??
                              ""),
                        ],
                      ),
                      onTap: () {
                        //dataSaved.theraphy = snapshot.data[index];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnTappedList(
                                  theraphy:
                                      snapshot.data?[index] ?? Theraphy()),
                            ));
                      });
                }),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      persistentFooterButtons: [
        Text("Rest link: ${this.searchStr}"),
      ],
    );
  }

  Future<List<Theraphy>> fetchTheraphy() async {
    //final response = await http.get("${dataSaved.searchURL}${this.searchStr}");
    try {
      final response = await http.get(Uri.parse("${this.searchStr}"));
      if (response.statusCode == 200) {
        List<Theraphy> lst = [];
        for (final e in jsonDecode(response.body))
          lst.add(Theraphy.fromRest(e));
        return lst;
      } else {
        throw Exception('Failed to load theraphy!');
      }
    } catch (e) {
      throw Exception('Http error! (Wifi/Mobil data is on?\n\n$e');
    }
  }
}

class OnTappedList extends StatefulWidget {
  final Theraphy theraphy;
  OnTappedList({required this.theraphy});

  @override
  _OnTappedListState createState() => _OnTappedListState(
        theraphy: theraphy,
      );
}

class _OnTappedListState extends State<OnTappedList> {
  final Theraphy theraphy;
  _OnTappedListState({required this.theraphy});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theraphy'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Text(""),
              Text(theraphy.title),
              Text(""),
              Text(theraphy.bodyvalue),
              Text(""),
              Text(theraphy.fieldscript),
              //Text(dataSaved.theraphy.fieldurzadzenie),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Divider(
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              //color: Theme.of(context).primaryColor,
              //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              //textColor: Theme.of(context).colorScheme.background,
              onPressed: () {
                Navigator.pop(context, theraphy);
                Navigator.pop(context, theraphy);
              },
              child: Text('Choose theraphy'),
            ),
          ),
        ],
      ),
    );
  }
}
