import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Nappy {
  late String id;
  String poopDate;
  String poopTime;
  String nappyType;
  String poopImage;
  String? poopNote;

  Nappy({
    required this.poopDate,
    required this.poopTime,
    required this.nappyType,
    required this.poopImage,
    this.poopNote,
  });

  Nappy.fromJson(Map<String, dynamic> json, this.id)
      : poopDate = json['poopDate'],
        poopTime = json['poopTime'],
        nappyType = json['nappyType'],
        poopImage = json['poopImage'],
        poopNote = json['poopNote'];

  Map<String, dynamic> toJson() => {
    'poopDate': poopDate,
    'poopTime': poopTime,
    'nappyType': nappyType,
    'poopImage': poopImage,
    'poopNote': poopNote,
  };
}

class NappyModel extends ChangeNotifier {
  final List<Nappy> items = [];
  CollectionReference nappyCollection =
  FirebaseFirestore.instance.collection('poopHistory');
  bool loading = false;

  NappyModel() {
    fetch();
  }

  Future<void> fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await nappyCollection.orderBy("poopDate").get();

    for (var doc in querySnapshot.docs) {
      var nappy = Nappy.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(nappy);
    }
    loading = false;
    update();
  }

  Future add(Nappy item) async {
    loading = true;
    update();

    await nappyCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Nappy item) async {
    loading = true;
    update();

    await nappyCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await nappyCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  void update() {
    notifyListeners();
  }

  Nappy? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((nappy) => nappy.id == id);
  }
}
