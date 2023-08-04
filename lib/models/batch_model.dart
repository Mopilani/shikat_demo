import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_model.dart';

class BatchModel {
  BatchModel._();

  BatchModel(
    this.id, {
    required this.description,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String description;

  static const String collectionName = 'batches';

  static BatchModel fromMap(Map<String, dynamic> data) {
    BatchModel model = BatchModel._();
    model.id = data['id'];
    model.description = data['description'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
      };

  String toJson() => json.encode(toMap());

  static BatchModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<BatchModel>> getAll() {
    List<BatchModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<BatchModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(BatchModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<BatchModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(BatchModel.fromMap(data));
        },
      ),
    );
  }

  Future<BatchModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return BatchModel.fromMap(d);
  }

  static Future<BatchModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return BatchModel.fromMap(d);
  }

  static Future<BatchModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return BatchModel.fromMap(d);
  }

  static Future<BatchModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return BatchModel.fromMap(d);
  }

  Future<BatchModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<BatchModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedBatch(this, collName);
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
      await ActionModel.deletedBatch(this, collName);
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
      await ActionModel.createdBatch(this, collName);
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
      await ActionModel.deletedBatch(this, collectionName);
      print(r);
    }
    return 1;
  }

  // Future<BatchModel> edit() async => await editToCol(collectionName);

  // Future<BatchModel> editToCol(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).update(
  //         where.eq('id', id),
  //         toMap(),
  //       );
  //   await ActionModel.updatedBatch(this, collName);
  //   print(r);
  //   return this;
  // }

  // Future<int> delete() async => await deleteFromColl(collectionName);

  // Future<int> deleteFromColl(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).remove(
  //         where.eq('id', id),
  //       );
  //   await ActionModel.deletedBatch(this, collName);
  //   print(r);
  //   return 1;
  // }

  // Future<int> add() async => await addToCol(collectionName);

  // Future<int> addToCol(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).insert(
  //         toMap(),
  //       );
  //   await ActionModel.createdBatch(this, collName);

  //   print(r);
  //   return 1;
  // }

  // Future<int> moveToColl(
  //     String fromCollectionName, String toCollectionName) async {
  //   var r = await deleteFromColl(fromCollectionName);
  //   print(r);
  //   r = await addToCol(toCollectionName);
  //   print(r);
  //   return 1;
  // }

  // Future<int> deleteWithMID() async {
  //   print(mid);
  //   var r = await SystemMDBService.db.collection(collectionName).remove(
  //         where.eq('_id', mid),
  //       );
  //   await ActionModel.deletedBatch(this, collectionName);
  //   print(r);
  //   return 1;
  // }
}

  // Future<BatchModel?> edit() async {
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

  // Future<int> deleteWithMID() async {
  //   print(mid);
  //   var r = await SystemMDBService.db.collection(collectionName).remove(
  //         where.eq('_id', mid),
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
