import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sleep {
  late String id;
  String date;
  String sleepDuration;
  String sleepEnd;
  String? sleepNote;
  String sleepStart;


  Sleep({
    required this.date,
    required this.sleepDuration,
    required this.sleepEnd,
    required this.sleepStart,
    this.sleepNote,
  });

  Sleep.fromJson(Map<String, dynamic> json, this.id)
      : date = json['date'],
        sleepDuration = json['sleepDuration'],
        sleepStart = json['sleepStart'],
        sleepEnd = json['sleepEnd'],
        sleepNote = json['sleepNote'];

  Map<String, dynamic> toJson() => {
    'date': date,
    'sleepDuration': sleepDuration,
    'sleepStart': sleepStart,
    'sleepEnd': sleepEnd,
    'sleepNote': sleepNote
  };
}

class SleepModal extends ChangeNotifier {
  final List<Sleep> items = [];
  CollectionReference sleepCollection = FirebaseFirestore.instance.collection('sleepHistory');
  bool loading = false;

  SleepModal() {
    fetch();
  }

  Future<void> fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await sleepCollection.orderBy("date").get();

    for (var doc in querySnapshot.docs) {
      var sleep = Sleep.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(sleep);
    }
    loading = false;
    update();
  }

  Future add(Sleep item) async
  {
    loading = true;
    update();

    await sleepCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Sleep item) async
  {
    loading = true;
    update();

    await sleepCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String id) async
  {
    loading = true;
    update();

    await sleepCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }
  void update() {
    notifyListeners();
  }

  Sleep? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((sleep) => sleep.id == id);
  }
}
