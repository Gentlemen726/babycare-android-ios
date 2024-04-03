import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Growth {
  late String id;
  String height;
  String measuredDate;

  Growth({
    required this.height,
    required this.measuredDate,
  });

  Growth.fromJson(Map<String, dynamic> json, this.id)
      : height = json['height'],
        measuredDate = json['measuredDate'];

  Map<String, dynamic> toJson() => {
    'height': height,
    'measuredDate': measuredDate,
  };
}

class GrowthModel extends ChangeNotifier {
  final List<Growth> items = [];
  CollectionReference growthCollection = FirebaseFirestore.instance.collection('growthHistory');
  bool loading = false;

  GrowthModel() {
    fetch();
  }

  Future<void> fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await growthCollection.orderBy("measuredDate").get();

    for (var doc in querySnapshot.docs) {
      var growth = Growth.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(growth);
    }
    loading = false;
    update();
  }

  Future add(Growth item) async
  {
    loading = true;
    update();

    await growthCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Growth item) async
  {
    loading = true;
    update();

    await growthCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String id) async
  {
    loading = true;
    update();

    await growthCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }
  void update() {
    notifyListeners();
  }

  Growth? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((growth) => growth.id == id);
  }
}
