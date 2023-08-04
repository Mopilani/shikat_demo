import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';

class PeriodModel {
  PeriodModel._();

  PeriodModel(
    this.id, {
    required this.description,
    required this.start,
    required this.end,
    required this.value,
  });

  late int id;
  late dynamic mid; // Mongo document id
  late String description;
  late DateTime start;
  late DateTime end;
  late double value;

  static const String collectionName = 'periods';

  static PeriodModel fromMap(Map<String, dynamic> data) {
    PeriodModel model = PeriodModel._();
    model.id = data['id'];
    model.description = data['description'];
    model.start = data['start'];
    model.end = data['end'];
    model.value = data['value'];
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'start': start,
        'end': end,
        'value': value,
      };

  String toJson() => json.encode(toMap());

  static PeriodModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<PeriodModel>> getAll() {
    List<PeriodModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<PeriodModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(PeriodModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<PeriodModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(PeriodModel.fromMap(data));
        },
      ),
    );
  }

  Future<PeriodModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return PeriodModel.fromMap(d);
  }

  static Future<PeriodModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return PeriodModel.fromMap(d);
  }

  static Future<PeriodModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return PeriodModel.fromMap(d);
  }

  static Future<PeriodModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return PeriodModel.fromMap(d);
  }

  Future<PeriodModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<PeriodModel> editToCol(String collName,
      [bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      // await ActionModel.updatedBatch(this, collName);
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
      // await ActionModel.deletedBatch(this, collName);
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
      // await ActionModel.createdBatch(this, collName);
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
      // await ActionModel.deletedBatch(this, collectionName);
      print(r);
    }
    return 1;
  }
}
