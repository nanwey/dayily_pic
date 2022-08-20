import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'json_serialize.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  var picList = HomeList().album;
  int page = 1;
  int pageCount = 15;

  @override
  void initState() {
    super.initState();
    _getImagesList();
  }

  Future<void> _getImagesList() async {
    var client = HttpClient();
    try {
      HttpClientRequest request = await client.get(
          'dili.bdatu.com', 80, '/jiekou/mains/p' + page.toString() + '.html');
      HttpClientResponse response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      HomeList homeList = HomeList.fromJson(jsonDecode(data));
      setState(() {
        picList = homeList.album;
      });
      // print(picList?[2].title);
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.separated(
            itemCount: picList!.length - 2,
            itemBuilder: (context, index) {
              return Card(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image(
                        image: NetworkImage(
                            picList?[page == 1 ? index + 2 : index].url ?? '')),
                    Container(
                        alignment: Alignment.bottomCenter,
                        // width: 100,
                        height: 40,
                        // color: const Color.fromRGBO(0, 0, 0, 0.3),
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromRGBO(0, 0, 0, 0),
                              Color.fromRGBO(0, 0, 0, 0.3),
                              Color.fromRGBO(0, 0, 0, 0.5),
                            ])),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            picList?[page == 1 ? index + 2 : index].title ?? '',
                            style: const TextStyle(
                                color: Color.fromRGBO(220, 220, 220, 1)),
                          ),
                        )),
                  ],
                ),
              ));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        ));
  }
}
