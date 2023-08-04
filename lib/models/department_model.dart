import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_model.dart';

class DepartmentModel {
  DepartmentModel._();

  DepartmentModel(
    this.id, {
    required this.description,
  });

  late dynamic id;
  late dynamic mid; // Mongo document id
  late String description;

  static const String collectionName = 'deparments';

  static DepartmentModel fromMap(Map<String, dynamic> data) {
    DepartmentModel model = DepartmentModel._();
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

  static DepartmentModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<DepartmentModel>> getAll() {
    List<DepartmentModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<DepartmentModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(DepartmentModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<DepartmentModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(DepartmentModel.fromMap(data));
        },
      ),
    );
  }

  Future<DepartmentModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return DepartmentModel.fromMap(d);
  }

  static Future<DepartmentModel?> get(id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return DepartmentModel.fromMap(d);
  }

  static Future<DepartmentModel?> findById(id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return DepartmentModel.fromMap(d);
  }

  static Future<DepartmentModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return DepartmentModel.fromMap(d);
  }

  Future<DepartmentModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<DepartmentModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedDepartment(this, collName);
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
      await ActionModel.deletedDepartment(this, collName);
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
      await ActionModel.createdDepartment(this, collName);
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
      await ActionModel.deletedDepartment(this, collectionName);
      print(r);
    }
    return 1;
  }

  // Future<DepartmentModel> edit() async => await editToCol(collectionName);

  // Future<DepartmentModel> editToCol(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).update(
  //         where.eq('id', id),
  //         toMap(),
  //       );
  //   await ActionModel.updatedDepartment(this, collName);
  //   print(r);
  //   return this;
  // }

  // Future<int> delete() async => await deleteFromColl(collectionName);

  // Future<int> deleteFromColl(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).remove(
  //         where.eq('id', id),
  //       );
  //   await ActionModel.deletedDepartment(this, collName);
  //   print(r);
  //   return 1;
  // }

  // Future<int> add() async => await addToCol(collectionName);

  // Future<int> addToCol(String collName) async {
  //   var r = await SystemMDBService.db.collection(collName).insert(
  //         toMap(),
  //       );
  //   await ActionModel.createdDepartment(this, collName);

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
  //   await ActionModel.deletedDepartment(this, collectionName);
  //   print(r);
  //   return 1;
  // }
}

  // Future<DepartmentModel?> edit() async {
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
