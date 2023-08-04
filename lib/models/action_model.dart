import 'dart:async';

import '/models/processes_model.dart';
import '/models/subscriper_model.dart';
import '/models/system_node_model.dart';
import '/utils/sync_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';
import 'action_data_model.dart';
import 'batch_model.dart';
import 'department_model.dart';
import 'rank_model.dart';
import 'subscription_model.dart';
import 'user_model.dart';

/// Actions table used to log user actions like
///   Signin
///   Signout
///   System Manipulation like
///   Adding catgories, suppliers, and so additions
///   So deletions, and modifications
class ActionModel {
  ActionModel(
    this.line, {
    this.id,
  }) {
    id = const Uuid().v4();
    createDate = DateTime.now();
    user = UserModel.stored!;
  }

  ActionModel._();

  static SyncService? syncSvc;

  static set registerSync(SyncService service) {
    syncSvc = service;
    // service.modelOfCollection('collName').listen;
  }

  // ActionModel.add() {
  //   id = const Uuid().v4();
  //   createDate = DateTime.now();
  //   user = UserModel.stored!;
  // }

  dynamic id;
  late String line;
  late DateTime createDate;
  UserModel? user;

  // static ActionModel fromMap(Map<String, dynamic> data) {
  //   ActionModel action = ActionModel._();
  //   action.id = data['id'];
  //   action.line = data['line'];
  //   action.createDate = DateTime.parse(data['createDate']);
  //   // action.user = UserModel.fromMap(data['user']);
  //   return action;
  // }

  // Map<String, dynamic> toMap() => {
  //       'id': id,
  //       'line': line,
  //       'createDate': createDate.toString(),
  //       // 'userModel': user?.toMap(),
  //     };

  // String toJson() => json.encode(toMap());

  // static ActionModel fromJson(String jsn) {
  //   return fromMap(json.decode(jsn));
  // }

  static Future<List<ActionDataModel>> getAll() async {
    List<ActionDataModel> result = [];
    return SystemMDBService.db
        .collection('actions')
        .find()
        .transform<ActionDataModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(ActionDataModel.fromMap(data));
            },
          ),
        )
        .listen((model) {
          result.add(model);
        })
        .asFuture()
        .then((value) => result);
  }

  static Stream<ActionDataModel> stream() {
    return SystemMDBService.db.collection('actions').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          // print(data);
          sink.add(ActionDataModel.fromMap(data));
        },
      ),
    );
  }

  Future<ActionDataModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db.collection('actions').aggregate(pipeline);

    return ActionDataModel.fromMap(d);
  }

  Future<ActionDataModel?> get(String id) async {
    var d = await SystemMDBService.db
        .collection('actions')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return ActionDataModel.fromMap(d);
  }

  static Stream<ActionDataModel> collectOfTime(DateTime from, DateTime to) {
    var receiptsStream = stream();
    var musfaStream = receiptsStream.transform<ActionDataModel>(
        StreamTransformer.fromHandlers(handleData: (model, sink) {
      var r1 = model.time.compareTo(from);
      var r2 = model.time.compareTo(to);
      if (!(r1 == 1 && r2 == -1)) {
        return;
      }
      sink.add(model);
    }));
    return musfaStream;
  }
  // Future<ActionModel?> findByName(String name, String id) async {
  //   var d = await SystemMDBService.db
  //       .collection('actions')
  //       .findOne(where.eq('id', id));
  //   if (d == null) {
  //     return null;
  //   }
  //   return ActionModel.fromMap(d);
  // }

  // Future<ActionModel?> edit(String id, Map<String, dynamic> document) async {
  //   var r = await SystemMDBService.db.collection('actions').update(
  //         where.eq('id', id),
  //         document,
  //       );
  //   print(r);
  //   return ActionModel.fromMap(r);
  // }

  // Future<int> delete(String id) async {
  //   var r = await SystemMDBService.db.collection('actions').remove(
  //         where.eq('id', id),
  //       );
  //   print(r);
  //   return 1;
  // }

  // Future<int> add() async {
  //   var r = await SystemMDBService.db.collection('actions').insert(
  //         toMap(),
  //       );
  //   print(r);
  //   return 1;
  // }

  static Future<int> addData(ActionDataModel actionData) async {
    var r = await SystemMDBService.db.collection('actions').insert(
          actionData.toMap(),
        );
    print(r);
    return 1;
  }

  // static Future<int> updatedSubscriper(
  //   SubscriperModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.updatedSubscriper: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.updatedSubscriper,
  //   );
  // }

  // static Future<int> deletedSubscriper(
  //   SubscriperModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.deletedSubscriper: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.deletedSubscriper,
  //   );
  // }

  // static Future<int> createSubscriper(
  //   SubscriperModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.createdSubscriper: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.createdSubscriper,
  //   );
  // }

  static Future<int> createdBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdBatch,
    );
  }

  static Future<int> updatedBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedBatch,
    );
  }

  static Future<int> deletedBatch(
    BatchModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedBatch: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedBatch,
    );
  }

  static Future<int> createdDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdDepartment,
    );
  }

  static Future<int> updatedDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedDepartment,
    );
  }

  static Future<int> deletedDepartment(
    DepartmentModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedDepartment: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedDepartment,
    );
  }

  // static Future<int> createdSubscription(
  //   SubscriptionModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.createdSubscription: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.createdSubscription,
  //   );
  // }

  // static Future<int> updatedSubscription(
  //   SubscriptionModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.updatedSubscription: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.updatedSubscription,
  //   );
  // }

  // static Future<int> deletedSubscription(
  //   SubscriptionModel model,
  //   String collName,
  // ) async {
  //   return await _ac(
  //     <String, dynamic>{
  //       ActionDataModel.deletedSubscription: model.toMap(),
  //       'cn': collName,
  //     },
  //     ActionDataModel.deletedSubscription,
  //   );
  // }

  static Future<int> createdRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdRank,
    );
  }

  static Future<int> updatedRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedRank,
    );
  }

  static Future<int> deletedRank(
    RankModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedRank: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedRank,
    );
  }

  static Future<int> createdUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.createdUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.createdUser,
    );
  }

  static Future<int> updatedUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.updatedUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.updatedUser,
    );
  }

  static Future<int> deletedUser(
    UserModel model,
    String collName,
  ) async {
    return await _ac(
      <String, dynamic>{
        ActionDataModel.deletedUser: model.toMap(),
        'cn': collName,
      },
      ActionDataModel.deletedUser,
    );
  }

  static Future<int> _ac(Map<String, dynamic> metaData, String action) async {
    var user = UserModel.stored!;
    var nId = ProcessesModel.stored!.requestActionId();
    var actionId =
        '${DateTime.now().year}-${DateTime.now().month}.${SystemNodeModel.stored!.deviceId}-$nId';
    var actionData = ActionDataModel(
      actionId,
      action: action,
      firstname: user.firstname,
      lastname: user.lastname,
      metaData: metaData,
      time: DateTime.now(),
    );
    var r = await SystemMDBService.db.collection('actions').insert(
          actionData.toMap(),
        );
    await syncSvc?.sendAction(actionData);
    print(r);
    return 1;
  }

  // cb = create bill | db = deleted bill = | rb = reprinted bill
  // cnb = canceld bill |
  static Future<int> createdBill(int billNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.createdABill,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'bno': billNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> updatedBill(int billNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.updatedABill,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'bno': billNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> returnedBill(int billNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.returnedABill,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'bno': billNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> canceledBill(int billNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.canceledABill,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'bno': billNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> printedBill(int billNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.printedABill,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'bno': billNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> createReceipt(int receiptNumber) async {
    var user = UserModel.stored!;

    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.createdAReceipt,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'rcptno': receiptNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> canceledReceipt(int receiptNumber) async {
    var user = UserModel.stored!;

    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.canceledAReceipt,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'rcptno': receiptNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> updatedReceipt(int receiptNumber) async {
    var user = UserModel.stored!;

    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.updatedAReceipt,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'rcptno': receiptNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> returnedReceipt(int receiptNumber) async {
    var user = UserModel.stored!;

    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.returnedAReceipt,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'rcptno': receiptNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> printedReceipt(int receiptNumber) async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.printedAReceipt,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'rcptno': receiptNumber,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> signin() async {
    var user = UserModel.stored!;
    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.signin,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{},
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> signout() async {
    var user = UserModel.stored!;

    var r = await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.signout,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{},
            time: DateTime.now(),
          ).toMap(),
        );
    print(r);
    return 1;
  }

  static Future<int> startedDay(DateTime day) async {
    var user = UserModel.stored!;
    await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.startedADay,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'dy': day,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    return 1;
  }

  static Future<int> endedTheDay(DateTime day) async {
    var user = UserModel.stored!;
    await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.endedADay,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'dy': day,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    return 1;
  }

  static Future<int> startedNewShift(int number) async {
    var user = UserModel.stored!;
    await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.startedAShift,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'no': number,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    return 1;
  }

  static Future<int> endedTheShift(int number) async {
    var user = UserModel.stored!;
    await SystemMDBService.db.collection('actions').insert(
          ActionDataModel(
            null,
            action: ActionDataModel.endedAShift,
            firstname: user.firstname,
            lastname: user.lastname,
            metaData: <String, dynamic>{
              'no': number,
            },
            time: DateTime.now(),
          ).toMap(),
        );
    return 1;
  }
}
