import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';

class PayeeModel {
  PayeeModel._();

  PayeeModel(
    this.id, {
    required this.name,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String name;

  static const String collectionName = 'payees';

  static PayeeModel fromMap(Map<String, dynamic> data) {
    PayeeModel model = PayeeModel._();
    model.id = data['id'];
    model.mid = data['_id'];
    model.name = data['name'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };

  String toJson() => json.encode(toMap());

  static PayeeModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<PayeeModel>> getAll() {
    List<PayeeModel> catgs = [];
    // SystemMDBService.db.collection(collectionName).drop();
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<PayeeModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(PayeeModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<PayeeModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(PayeeModel.fromMap(data));
        },
      ),
    );
  }

  Future<PayeeModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return PayeeModel.fromMap(d);
  }

  static Future<PayeeModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return PayeeModel.fromMap(d);
  }

  static Future<PayeeModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return PayeeModel.fromMap(d);
  }

  static Future<PayeeModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return PayeeModel.fromMap(d);
  }

  Future<PayeeModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<PayeeModel> editToCol(String collName,
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

  // Future<PayeeModel?> edit() async {
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
