// import 'dart:async';
// import 'dart:convert';

// import 'package:businet_data_manipulation/models/action_model.dart';
// import 'package:businet_data_manipulation/models/department_model.dart';
// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:updater/updater.dart' as updater;

// import '../utils/sync_service.dart';
// import '../utils/system_db.dart';
// import 'batch_model.dart';
// import 'rank_model.dart';

// class SubscriperModel {
//   SubscriperModel._();

//   SubscriperModel(
//     this.id, {
//     this.phoneNumber,
//     this.name,
//     this.imagePath,
//     this.subscripeDate,
//     this.comeDate,
//     this.discount,
//     this.price,
//     this.rank,
//     this.batch,
//     this.departmentId,
//     // this.walletId,
//   });

//   late dynamic id;
//   String? phoneNumber;
//   double? discount;
//   double? price;
//   String? name;
//   String? imagePath;
//   String? departmentId;
//   // String? walletId;
//   DateTime? subscripeDate;
//   DateTime? unsubscripeDate;
//   DateTime? comeDate;
//   RankModel? rank;
//   BatchModel? batch;
//   List<SubData> subs = [];
//   // SubState state;

//   static SubscriperModel fromMap(Map<String, dynamic> data) {
//     SubscriperModel model = SubscriperModel._();
//     model.id = data['id'];
//     model.phoneNumber = data['phoneNumber'];
//     model.name = data['name'];
//     model.departmentId = data['departmentId'];
//     // model.walletId = data['walletId'];
//     model.imagePath = data['imagePath'];
//     model.subscripeDate = data['subscripeDate'];
//     model.unsubscripeDate = data['unsubscripeDate'];
//     model.comeDate = data['comeDate'];
//     model.discount = data['discount'];
//     // model.state = data['state'];
//     model.price = data['price'] ?? 0.0;
//     model.rank = data['rank'] == null ? null : RankModel.fromMap(data['rank']);
//     model.batch =
//         data['batch'] == null ? null : BatchModel.fromMap(data['batch']);
//     model.subs = data['subs'] == null
//         ? <SubData>[]
//         : <SubData>[
//             ...data['subs'].map(
//               (e) => SubData.fromMap(e),
//             )
//           ].toList();

//     return model;
//   }

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'phoneNumber': phoneNumber,
//         'name': name,
//         'imagePath': imagePath,
//         'discount': discount,
//         'price': price,
//         'subscripeDate': subscripeDate,
//         'unsubscripeDate': unsubscripeDate,
//         'comeDate': comeDate,
//         'departmentId': departmentId,
//         // 'walletId': walletId,
//         // 'state': state,
//         'rank': rank?.toMap(),
//         'batch': batch?.toMap(),
//         'subs': subs.map((e) => e.toMap()).toList()
//       };

//   String toJson() => json.encode(toMap());

//   static SubscriperModel fromJson(String jsn) {
//     return fromMap(json.decode(jsn));
//   }

//   static const String collectionName = 'subscripers';

//   static Future<List<SubscriperModel>> getAll() {
//     List<SubscriperModel> models = [];
//     return SystemMDBService.db
//         .collection(collectionName)
//         .find()
//         .transform<SubscriperModel>(
//           StreamTransformer.fromHandlers(
//             handleData: (data, sink) {
//               sink.add(SubscriperModel.fromMap(data));
//             },
//           ),
//         )
//         .listen((subCatg) {
//           models.add(subCatg);
//         })
//         .asFuture()
//         .then((value) => models);
//   }

//   static Stream<SubscriperModel> stream() {
//     return SystemMDBService.db.collection(collectionName).find().transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           sink.add(SubscriperModel.fromMap(data));
//         },
//       ),
//     );
//   }

//   static Stream<SubscriperModel> ofCollection(String collectionName) {
//     return SystemMDBService.db.collection(collectionName).find().transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           // print(data);
//           sink.add(SubscriperModel.fromMap(data));
//         },
//       ),
//     );
//   }

//   Future<SubscriperModel?> aggregate(List<dynamic> pipeline) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .aggregate(pipeline);

//     return SubscriperModel.fromMap(d);
//   }

//   static Future<SubscriperModel?> get(dynamic id) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .findOne(where.eq('id', id));
//     // print(d);
//     if (d == null) {
//       return null;
//     }

//     return SubscriperModel.fromMap(d);
//   }

//   static Future<SubscriperModel?> searchAll(dynamic id) async {
//     var dpartments = await DepartmentModel.getAll();
//     Map<String, dynamic>? d;
//     for (var department in dpartments) {
//       d = await SystemMDBService.db
//           .collection(department.id)
//           .findOne(where.eq('id', id));

//       if (d != null) {
//         break;
//       }
//     }
//     // print(d);
//     if (d == null) {
//       return null;
//     }
//     return SubscriperModel.fromMap(d);
//   }

//   static Future<SubscriperModel?> getFrom(
//       dynamic id, String collectionName) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .findOne(where.eq('id', id));
//     // print(d);
//     if (d == null) {
//       return null;
//     }

//     return SubscriperModel.fromMap(d);
//   }

//   Future<SubscriperModel?> findByName(String name) async {
//     var d = await SystemMDBService.db
//         .collection(collectionName)
//         .findOne(where.eq('id', id));
//     if (d == null) {
//       return null;
//     }
//     return SubscriperModel.fromMap(d);
//   }

//   Future<SubscriperModel> edit([bool fromSyncService = false]) async =>
//       await editToCol(collectionName, fromSyncService);

//   Future<SubscriperModel> editToCol(String collName,
//       [bool fromSyncService = false]) async {
//     var r = await SystemMDBService.db.collection(collName).update(
//           where.eq('id', id),
//           toMap(),
//         );
//     if (!fromSyncService) {
//       await ActionModel.updatedSubscriper(this, collName);
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
//       await ActionModel.deletedSubscriper(this, collName);
//       print(r);
//     }
//     return 1;
//   }

//   Future<int> add([bool fromSyncService = false]) async =>
//       await addToCol(collectionName, fromSyncService);

//   Future<int> addToCol(String collName, [bool fromSyncService = false]) async {
//     var r = await SystemMDBService.db.collection(collName).insert(
//           toMap(),
//         );
//     if (!fromSyncService) {
//       await ActionModel.createSubscriper(this, collName);
//     }
//     print(r);
//     return 1;
//   }

//   Future<int> moveToColl(
//       String fromCollectionName, String toCollectionName) async {
//     var r = await deleteFromColl(fromCollectionName);
//     // var r = await SystemMDBService.db.collection(fromCollectionName).remove(
//     //       where.eq('id', id), );
//     print(r);
//     r = await addToCol(toCollectionName);
//     // r = await SystemMDBService.db.collection(toCollectionName).insert(
//     //       toMap(),  );
//     print(r);
//     return 1;
//   }
// }

// class SubData {
//   SubData(this.id, this.payed, this.wanted, this.value);
//   dynamic id;
//   double payed;
//   double wanted;
//   double value = 0;

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'wanted': wanted,
//         'payed': payed,
//         'value': value,
//       };

//   static SubData fromMap(Map<String, dynamic> data) {
//     return SubData(data['id'], data['payed'], data['wanted'], data['value']);
//   }
// }

// // class ThisPageSecondUpdater extends updater.Updater {
// //   ThisPageSecondUpdater({
// //     init,
// //     bool updateForCurrentEvent = false,
// //   }) : super(init, updateForCurrentEvent: updateForCurrentEvent);
// // }
