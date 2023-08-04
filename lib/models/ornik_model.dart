import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shikat/models/shik_model.dart';

import '../utils/system_db.dart';

class OrnikModel {
  OrnikModel._();

  OrnikModel(
    this.id, {
    required this.number,
    required this.shiks,
    this.value,
    this.payeeName,
    this.createDate,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late int number;
  DateTime? createDate;
  double? value = 0;
  late String? payeeName;
  List<ShikModel> shiks = [];

  Future<void> addShik(ShikModel shik) async {
    shiks.add(shik);
    resum();
    // payeeName = shik.payeeName;
    await edit();
  }

  Future<void> removeShik(index) async {
    shiks.removeAt(index);
    resum();
    await edit();
  }

  void resum() {
    value = 0;
    for (var shik in shiks) {
      value = value! + shik.value;
    }
  }

  static const String collectionName = 'orniks';

  static OrnikModel fromMap(Map<String, dynamic> data) {
    OrnikModel model = OrnikModel._();
    model.id = data['id'];
    model.mid = data['_id'];
    model.number = data['number'];
    model.value = data['value'];
    model.payeeName = data['payeeName'];
    model.createDate = data['createDate'];
    model.shiks =
        (data['shiks'] as List).map((shik) => ShikModel.fromMap(shik)).toList();

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'value': value,
        'payeeName': payeeName,
        'createDate': createDate,
        'shiks': shiks.map((e) => e.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());

  static OrnikModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future deleteAll() {
    return SystemMDBService.db.collection(collectionName).drop();
  }

  static Future<List<OrnikModel>> getAll() {
    List<OrnikModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<OrnikModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(OrnikModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<OrnikModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(OrnikModel.fromMap(data));
        },
      ),
    );
  }

  Future<OrnikModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return OrnikModel.fromMap(d);
  }

  static Future<OrnikModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return OrnikModel.fromMap(d);
  }

  static Future<OrnikModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return OrnikModel.fromMap(d);
  }

  static Future<OrnikModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return OrnikModel.fromMap(d);
  }

  Future<OrnikModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<OrnikModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      // await ActionModel.updatedRank(this, collName);
      print(r);
    }
    return this;
  }

  Future<int> delete([bool fromSyncService = false]) async =>
      await deleteFromColl(collectionName, fromSyncService);

  Future<int> deleteFromColl(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).remove(
          where.eq('id', id),
        );
    if (!fromSyncService) {
      // await ActionModel.deletedRank(this, collName);
      print(r);
    }
    return 1;
  }

  Future<int> add([bool fromSyncService = false]) async =>
      await addToCol(collectionName, fromSyncService);

  Future<int> addToCol(String collName, [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).insert(
          toMap(),
        );
    if (!fromSyncService) {
      // await ActionModel.createdRank(this, collName);
    }
    print(r);
    return 1;
  }

  Future<int> moveToColl(
      String fromCollectionName, String toCollectionName) async {
    var r = await deleteFromColl(fromCollectionName);
    print(r);
    r = await addToCol(toCollectionName);
    print(r);
    return 1;
  }

  Future<int> deleteWithMID([bool fromSyncService = false]) async {
    print(mid);
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('_id', mid),
        );
    if (!fromSyncService) {
      // await ActionModel.deletedRank(this, collectionName);
    }
    print(r);
    return 1;
  }
}

  // Future<OrnikModel?> edit() async {
  //   var r = await SystemMDBService.db.collection(collectionName).update(
  //         where.eq('_id', mid),
  //         toMap(),
  //       );
  //   print(r);
  //   return this;
  // }

  // static Future<int> delete(int id) async {
  //   var r = await SystemMDBService.db.collection(collectionName).remove(
  //         where.eq('id', id),
  //       );
  //   print(r);
  //   return 1;
  // }


  // Future<int> add() async {
  //   var r = await SystemMDBService.db.collection(collectionName).insert(
  //         toMap(),
  //       );
  //   print(r);
  //   return 1;
  // }
