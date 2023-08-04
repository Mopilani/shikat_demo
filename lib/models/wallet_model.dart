import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_model.dart';
import 'bank_model.dart';

class WalletModel {
  WalletModel._();

  WalletModel(
    this.id, {
    // required this.description,
    required this.date,
    required this.bank,
    required this.value,
    required this.remaining,
    required this.note,
    required this.subs,
  });

  late int id;
  late double value;
  late double remaining;
  late dynamic mid; // Mongo document id
  // late String description;
  late DateTime date;
  late BankModel bank;
  late String note;
  late List<String> subs;

  static const String collectionName = 'wallets';

  static WalletModel fromMap(Map<String, dynamic> data) {
    WalletModel model = WalletModel._();
    model.id = data['id'];
    // model.description = data['description'];
    model.date = data['date'];
    model.value = data['value'];
    model.remaining = data['remaining'];
    model.note = data['note'];
    model.subs = <String>[...data['subs']];
    model.bank = BankModel.fromMap(data['bank']);
    model.mid = data['_id'];

    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        // 'description': description,
        'bank': bank.toMap(),
        'date': date,
        'value': value,
        'remaining': remaining,
        'note': note,
        'subs': subs,
      };

  String toJson() => json.encode(toMap());

  static WalletModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<WalletModel>> getAll() {
    List<WalletModel> catgs = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<WalletModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(WalletModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  static Stream<WalletModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(WalletModel.fromMap(data));
        },
      ),
    );
  }

  Future<WalletModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return WalletModel.fromMap(d);
  }

  static Future<WalletModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return WalletModel.fromMap(d);
  }

  static Future<WalletModel?> findById(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return WalletModel.fromMap(d);
  }

  static Future<WalletModel?> findBydescription(String description) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('description', description));
    if (d == null) {
      return null;
    }
    return WalletModel.fromMap(d);
  }

  Future<WalletModel> edit([bool fromSyncService = false]) async =>
      await editToCol(collectionName, fromSyncService);

  Future<WalletModel> editToCol(String collName,
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

  // Future<WalletModel?> edit() async {
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
