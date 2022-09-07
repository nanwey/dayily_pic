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

  Future<void> _getImagesList({bool loadMore = false}) async {
    print("Loading images...    " + loadMore.toString());
    if (!refreshing && !loadMore) {
      //如果不是在刷新中且不在获取更过中，即首次加载
      setState(() {
        loading = true;
      });
    }
    if (refreshing) {
      //下拉刷新时重置页数
      setState(() {
        page = 1;
      });
    }
    if (loadMore) {
      setState(() {
        page++; //下一页
      });
    }
    var client = HttpClient();
    try {
      HttpClientRequest request = await client.get(
          'dili.bdatu.com', 80, '/jiekou/mains/p' + page.toString() + '.html');
      HttpClientResponse response = await request.close();
      final data = await response.transform(utf8.decoder).join();
      HomeList homeList = HomeList.fromJson(jsonDecode(data));
      //过滤广告，只对第一页数据
      if (page == 1) {
        filteredPageCount = 0; //统计之前初始化
        homeList.album?.forEach((i) {
          //统计广告数量
          i.timing == "0"
              ? setState(() {
                  filteredPageCount++;
                })
              : "";
        });
        // print(filteredPageCount); //需要过滤掉的广告数量
        for (int i = 0; i < filteredPageCount; i++) {
          homeList.album?.removeAt(0); //删除广告
        }
      }
      if (!refreshing && !loadMore) {
        //如果没有在刷新,且没有在获取更多，即首次加载
        setState(() {
          picList = homeList.album;
          totalPages = int.parse(homeList.total!);
        });
        Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
              loading = false;
            }));
      }
      if (refreshing) {
        //下拉刷新时
        return Future.delayed(const Duration(seconds: 1))
            .then((v) => setState(() {
                  picList = homeList.album;
                  totalPages = int.parse(homeList.total!);
                  refreshing = false;
                }));
      }
      if (loadMore) {
        //获取更多时
        setState(() {
          picList!.addAll(homeList.album!); //拼接
        });
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
        // print(page.toString() + "当前页数");
        // print(index.toString() + "当前项");
        // print(picList!.length.toString() + '当前长度');
        // print(totalPages.toString() + '总页数');
        if (index == picList!.length - 1) {
          if (index == totalPages - 1) {
            return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 10),
                child: const Text(
                  '没有更多了',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ));
          } else {
            //还有更多
            // _getImagesList(loadMore: true); //获取下一页
            _retrieveNextPage();
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 10),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            );
          }
        }
        return Card(
            //为了实现图片之上的点击涟漪效果，套了两层stack
            child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image(
                    image: NetworkImage(picList?[index].url ?? ''),
                    height: 200,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const LinearProgressIndicator();
                    },
                  ),
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
            ),
            Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        //图片点击事件
                        // TODO:跳转到详情页
                        debugPrint(picList?[index].id);
                      },
                    )))
          ],
        ));
      },
      separatorBuilder: (BuildContext context, int index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(),
      ),
    );
  }

  void _retrieveNextPage() {
    print("获取下一页");
    Future.delayed(const Duration(seconds: 2)).then((value) => {
          {_getImagesList(loadMore: true)}
        });
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
