import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_model.dart';

class RankModel {
  RankModel._();

  RankModel(
    this.id, {
    required this.description,
    required this.subValue,
    required this.subsWorth,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String description;
  late double subValue;
  late double subsWorth;

  static const String collectionName = 'ranks';

  static RankModel fromMap(Map<String, dynamic> data) {
    RankModel model = RankModel._();
    model.id = data['id'];
    model.description = data['description'];
    model.subValue = data['subValue'];
    model.subsWorth = data['subsWorth'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'subValue': subValue,
        'subsWorth': subsWorth,
      };

  String toJson() => json.encode(toMap());

  static RankModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<RankModel>> getAll() {
    List<RankModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<RankModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(RankModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<RankModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(RankModel.fromMap(data));
        },
      ),
    );
  }

  Future<RankModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return RankModel.fromMap(d);
  }

  static Future<RankModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return RankModel.fromMap(d);
  }

  static Future<RankModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return RankModel.fromMap(d);
  }

  static Future<RankModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return RankModel.fromMap(d);
  }

  Future<RankModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<RankModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedRank(this, collName);
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
      await ActionModel.deletedRank(this, collName);
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
      await ActionModel.createdRank(this, collName);
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
      await ActionModel.deletedRank(this, collectionName);
      print(r);
    }
    return 1;
  }
}

  // Future<RankModel?> edit() async {
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
