import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  late String id;
  String feedDate;
  String feedDuration;
  String milkType;
  String feedSide;
  String feedStartTime;
  String quantity;
  String? feedNote;

  Feed({
    required this.feedDate,
    required this.feedDuration,
    required this.milkType,
    required this.feedSide,
    required this.feedStartTime,
    required this.quantity,
    this.feedNote,
  });

  Feed.fromJson(Map<String, dynamic> json, this.id)
      : feedDate = json['feedDate'],
        feedDuration = json['feedDuration'],
        milkType = json['milkType'],
        feedSide = json['feedSide'],
        feedStartTime = json['feedStartTime'],
        quantity = json['quantity'],
        feedNote = json['feedNote'];

  Map<String, dynamic> toJson() => {
    'feedDate': feedDate,
    'feedDuration': feedDuration,
    'milkType': milkType,
    'feedSide': feedSide,
    'feedStartTime': feedStartTime,
    'quantity': quantity,
    'feedNote': feedNote,
  };
}

class FeedModel extends ChangeNotifier {
  final List<Feed> items = [];
  CollectionReference feedCollection =
  FirebaseFirestore.instance.collection('feedingHistory');
  bool loading = false;

  FeedModel() {
    fetch();
  }

  Future<void> fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await feedCollection.orderBy("feedDate").get();

    for (var doc in querySnapshot.docs) {
      var feed = Feed.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(feed);
    }
    loading = false;
    update();
  }

  Future add(Feed item) async
  {
    loading = true;
    update();

    await feedCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Feed item) async
  {
    loading = true;
    update();

    await feedCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String id) async
  {
    loading = true;
    update();

    await feedCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }
  void update() {
    notifyListeners();
  }

  Feed? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((feed) => feed.id == id);
  }
}
