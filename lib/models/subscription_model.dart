// import 'dart:async';
// import 'dart:convert';

// import 'package:mongo_dart/mongo_dart.dart';

// import '../utils/system_db.dart';
// import 'action_model.dart';
// import 'subscriper_model.dart';

// class SubscriptionModel {
//   SubscriptionModel._();

//   SubscriptionModel(
//     this.id, {
//     required this.value,
//     required this.payed,
//     required this.wanted,
//     required this.time,
//     required this.subscriper,
//   });

//   late dynamic id;
//   late double value;
//   late double payed;
//   late double wanted;
//   late DateTime time;
//   late SubscriperModel subscriper;

//   static SubscriptionModel fromMap(Map<String, dynamic> data) {
//     SubscriptionModel model = SubscriptionModel._();
//     model.id = data['id'];
//     model.value = data['value'];
//     model.payed = data['payed'];
//     model.wanted = data['wanted'];
//     model.time = data['time'];
//     model.subscriper = SubscriperModel.fromMap(data['subscriper']);

//     return model;
//   }

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'wanted': wanted,
//         'value': value,
//         'payed': payed,
//         'time': time,
//         'subscriper': subscriper.toMap(),
//       };

//   String toJson() => json.encode(toMap());

//   static SubscriptionModel fromJson(String jsn) {
//     return fromMap(json.decode(jsn));
//   }

//   static const String collectionName = 'subscriptions';

//   static Future<List<SubscriptionModel>> getAll() {
//     List<SubscriptionModel> models = [];
//     return SystemMDBService.db
//         .collection(collectionName)
//         .find()
//         .transform<SubscriptionModel>(
//           StreamTransformer.fromHandlers(
//             handleData: (data, sink) {
//               sink.add(SubscriptionModel.fromMap(data));
//             },
//           ),
//         )
//         .listen((subCatg) {
//           models.add(subCatg);
//         })
//         .asFuture()
//         .then((value) => models);
//   }

//   static Stream<SubscriptionModel> stream() {
//     return SystemMDBService.db.collection(collectionName).find().transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           sink.add(SubscriptionModel.fromMap(data));
//         },
//       ),
//     );
//   }

//   Future<SubscriptionModel?> aggregate(List<dynamic> pipeline) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .aggregate(pipeline);

//     return SubscriptionModel.fromMap(d);
//   }

//   static Future<SubscriptionModel?> init() async {
//     var pos = await get(0);
//     if (pos == null) {
//       return null;
//     }
//     return pos;
//   }

//   static Future<SubscriptionModel?> get(dynamic id) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .findOne(where.eq('id', id));
//     // print(d);
//     if (d == null) {
//       return null;
//     }

//     return SubscriptionModel.fromMap(d);
//   }

//   Future<SubscriptionModel?> findByName(String name) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .findOne(where.eq('name', name));
//     if (d == null) {
//       return null;
//     }
//     return SubscriptionModel.fromMap(d);
//   }

//   Future<SubscriptionModel> edit([bool fromSyncService = false]) async =>
//       await editToCol(collectionName, fromSyncService);

//   Future<SubscriptionModel> editToCol(String collName,
//       [bool fromSyncService = false]) async {
//     var r = await SystemMDBService.db.collection(collName).update(
//           where.eq('id', id),
//           toMap(),
//         );
//     if (!fromSyncService) {
//       await ActionModel.updatedSubscription(this, collName);
//       print(r);
//     }
//     return this;
//   }

//   Future<int> delete([bool fromSyncService = false]) async =>
//       await deleteFromColl(collectionName, fromSyncService);

//   Future<int> deleteFromColl(String collName,
//       [bool fromSyncService = false]) async {
//     var r = await SystemMDBService.db.collection(collName).remove(
//           where.eq('id', id),
//         );
//     if (!fromSyncService) {
//       await ActionModel.deletedSubscription(this, collName);
//     }
//     print(r);
//     return 1;
//   }

//   Future<int> add([bool fromSyncService = false]) async =>
//       await addToCol(collectionName, fromSyncService);

//   Future<int> addToCol(String collName, [bool fromSyncService = false]) async {
//     var r = await SystemMDBService.db.collection(collName).insert(
//           toMap(),
//         );
//     if (!fromSyncService) {
//       await ActionModel.createdSubscription(this, collName);
//     }

//     print(r);
//     return 1;
//   }

//   Future<int> moveToColl(
//       String fromCollectionName, String toCollectionName) async {
//     var r = await deleteFromColl(fromCollectionName);
//     print(r);
//     r = await addToCol(toCollectionName);
//     print(r);
//     return 1;
//   }
// }
//   // Future<SubscriptionModel?> edit() async {
//   //   var r = await SystemMDBService.db.collection(collectionName).update(
//   //         where.eq('id', id),
//   //         toMap(),
//   //       );
//   //   await init();

//   //   print(r);
//   //   return await init();
//   // }

//   // Future<SubscriptionModel?> editToColl(String collName) async {
//   //   var r = await SystemMDBService.db.collection(collName).update(
//   //         where.eq('id', id),
//   //         toMap(),
//   //       );
//   //   await init();

//   //   print(r);
//   //   return await init();
//   // }

//   // Future<int> delete() async {
//   //   var r = await SystemMDBService.db.collection(collectionName).remove(
//   //         where.eq('id', id),
//   //       );
//   //   print(r);
//   //   return 1;
//   // }

//   // Future<int> deleteFromColl(String collName) async {
//   //   var r = await SystemMDBService.db.collection(collName).remove(
//   //         where.eq('id', id),
//   //       );
//   //   print(r);
//   //   return 1;
//   // }

//   // Future<int> add() async {
//   //   var r = await SystemMDBService.db.collection(collectionName).insert(
//   //         toMap(),
//   //       );

//   //   await init();
//   //   print(r);
//   //   return 1;
//   // }
