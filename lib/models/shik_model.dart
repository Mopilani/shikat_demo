import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_model.dart';

class ShikModel {
  ShikModel._();

  ShikModel(
    this.id, {
    required this.number,
    required this.payeeName,
    required this.value,
    required this.date,
    required this.viewShikNumber,
    required this.cashe,
    required this.statement,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String payeeName;
  late int number;
  late double value;
  late String date;
  late String statement;
  late bool viewShikNumber;
  late bool cashe;

  static const String collectionName = 'shiks';

  static ShikModel fromMap(Map<String, dynamic> data) {
    ShikModel model = ShikModel._();
    model.id = data['id'];
    model.payeeName = data['payeeName'];
    model.value = data['value'];
    model.number = data['number'];
    model.date = data['date'];
    model.statement = data['statement'];
    model.viewShikNumber = data['viewShikNumber'];
    model.cashe = data['cashe'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'payeeName': payeeName,
        'number': number,
        'value': value,
        'date': date,
        'statement': statement,
        'viewShikNumber': viewShikNumber,
        'cashe': cashe,
      };

  String toJson() => json.encode(toMap());

  static ShikModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future deleteAll() {
    List<ShikModel> catgs = [];
    return SystemMDBService.db.collection(collectionName).drop();
  }

  static Future<List<ShikModel>> getAll() {
    List<ShikModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<ShikModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ShikModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<ShikModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(ShikModel.fromMap(data));
        },
      ),
    );
  }

  Future<ShikModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return ShikModel.fromMap(d);
  }

  static Future<ShikModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ShikModel.fromMap(d);
  }

  static Future<ShikModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ShikModel.fromMap(d);
  }

  static Future<ShikModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return ShikModel.fromMap(d);
  }

  Future<ShikModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<ShikModel> editToCol(String collName,
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

  // Future<ShikModel?> edit() async {
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
