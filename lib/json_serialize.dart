//接口返回json数据解析
//首页列表
class HomeList {
  String? total;
  String? page;
  String? pagecount;
  List<Album>? album;

  HomeList({this.total, this.page, this.pagecount, this.album});

  HomeList.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    pagecount = json['pagecount'];
    if (json['album'] != null) {
      album = <Album>[];
      json['album'].forEach((v) {
        album!.add(Album.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['total'] = this.total;
    data['page'] = this.page;
    data['pagecount'] = this.pagecount;
    if (this.album != null) {
      data['album'] = this.album!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Album {
  String? id;
  String? title;
  String? url;
  String? addtime;
  String? adshow;
  String? fabu;
  String? encoded;
  String? amd5;
  String? sort;
  String? ds;
  String? timing;
  String? timingpublish;
  bool? status = false;

  Album({
    this.id,
    this.title,
    this.url,
    this.addtime,
    this.adshow,
    this.fabu,
    this.encoded,
    this.amd5,
    this.sort,
    this.ds,
    this.timing,
    this.timingpublish,
    this.status,
  });

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    addtime = json['addtime'];
    adshow = json['adshow'];
    fabu = json['fabu'];
    encoded = json['encoded'];
    amd5 = json['amd5'];
    sort = json['sort'];
    ds = json['ds'];
    timing = json['timing'];
    timingpublish = json['timingpublish'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['url'] = this.url;
    data['addtime'] = this.addtime;
    data['adshow'] = this.adshow;
    data['fabu'] = this.fabu;
    data['encoded'] = this.encoded;
    data['amd5'] = this.amd5;
    data['sort'] = this.sort;
    data['ds'] = this.ds;
    data['timing'] = this.timing;
    data['timingpublish'] = this.timingpublish;
    return data;
  }
}
