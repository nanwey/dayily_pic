import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'json_serialize.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var homeList = <String>[];
  String page = '1';
  String pageCount = '15';

  @override
  void initState() {
    super.initState();
    _getImagesList();
  }

  Future<void> _getImagesList() async {
    var client = HttpClient();
    try {
      HttpClientRequest request =
      await client.get('dili.bdatu.com', 80, '/jiekou/mains/p1.html');
      HttpClientResponse response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      HomeList homeList = HomeList.fromJson(jsonDecode(data));
      print(homeList.album?[0].title);
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: _getImagesList,
                  child: Text("test"),
                );
              }),
        ));
  }
}
