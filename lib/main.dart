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
      home: const MyHomePage(title: '每日精选'),
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
  int page = 1; //第几页
  int filteredPageCount = 0; //过滤的数量
  int totalPages = 0; //总页数
  bool loading = false; //首次进入加载指示器
  bool refreshing = false; //刷新指示器

  @override
  void initState() {
    super.initState();
    _getImagesList();
  }

  Future<void> _getImagesList() async {
    if (!refreshing) {
      setState(() {
        loading = true;
      });
    }
    var client = HttpClient();
    try {
      HttpClientRequest request = await client.get(
          'dili.bdatu.com', 80, '/jiekou/mains/p' + page.toString() + '.html');
      HttpClientResponse response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      HomeList homeList = HomeList.fromJson(jsonDecode(data));
      //过滤广告
      for (int i = 0; i < 15; i++) {
        if (homeList.album?[i].timing == '0') {
          homeList.album?.removeAt(i);
          continue;
        }
        if (homeList.album?[i].timing == '1') {
          setState(() {
            filteredPageCount = i;
          });
          break;
        }
      }
      print(filteredPageCount); //过滤掉的广告数量
      if (!refreshing) {
        setState(() {
          picList = homeList.album;
          totalPages = int.parse(homeList.total!);
        });
        Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
              loading = false;
            }));
      }
      if (refreshing) {
        return Future.delayed(const Duration(seconds: 1))
            .then((v) => setState(() {
                  picList = homeList.album;
                  totalPages = int.parse(homeList.total!);
                  refreshing = false;
                }));
      }
    } finally {
      client.close();
    }
  }

  Future<void> _refresh() {
    setState(() {
      refreshing = true;
    });
    return _getImagesList();
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
            PopupMenuButton<String>(
                onSelected: (String data) {},
                itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        child: Text("设置"),
                        value: "设置",
                      ),
                      const PopupMenuItem<String>(
                        child: Text("关于"),
                        value: "关于",
                      )
                    ]),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: listCard(),
          ),
        ));
  }

  Widget listCard() {
    if (loading && !refreshing) {
      return Container(
        alignment: Alignment.topCenter,
        child: const CircularProgressIndicator(),
      );
    }
    return ListView.separated(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: picList!.length,
      itemBuilder: (context, index) {
        if (index == picList!.length - 1) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 10),
            child: const Text('没有更多了'),
          );
        }
        return Card(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image(image: NetworkImage(picList?[index].url ?? '')),
              Container(
                  alignment: Alignment.bottomCenter,
                  height: 40,
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
                      picList?[index].title ?? '',
                      style: const TextStyle(
                          color: Color.fromRGBO(220, 220, 220, 1)),
                    ),
                  )),
              Positioned(
                  top: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: TriangleCliper(),
                    child: Container(
                      width: 40,
                      height: 35,
                      padding: const EdgeInsets.only(right: 2),
                      alignment: Alignment.topRight,
                      color: Colors.amber,
                      child: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )),
            ],
          ),
        ));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class TriangleCliper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.height + (size.width - size.height).abs(), 0);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
