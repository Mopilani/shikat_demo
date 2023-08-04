import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_db.dart';

class AccessLevelModel {
  AccessLevelModel(
    this.id, {
    required this.levelDescription,
    required this.accessToken,
    required this.levelNumber,
    required this.nodeId,
    required this.allowedLevels,
  });

  int id;
  late String levelDescription;
  late String accessToken;
  late int levelNumber;
  late int nodeId;
  late Map<String, dynamic> allowedLevels;

  static AccessLevelModel fromMap(Map<String, dynamic> data) {
    // print('================');
    // print(data);
    AccessLevelModel model = AccessLevelModel(
      data['id'],
      levelDescription: data['levelDescription'],
      accessToken: data['accessToken'],
      levelNumber: data['levelNumber'],
      allowedLevels: data['allowedLevels'] ?? {},
      nodeId: data['nodeId'],
    );
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'levelDescription': levelDescription,
        'accessToken': accessToken,
        'levelNumber': levelNumber,
        'allowedLevels': allowedLevels,
        'nodeId': nodeId,
      };

  String toJson() => json.encode(toMap());

  static AccessLevelModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<List<AccessLevelModel>> getAll() {
    List<AccessLevelModel> catgs = [];
    return SystemMDBService.db
        .collection('accessLevels')
        .find()
        .transform<AccessLevelModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(AccessLevelModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          catgs.add(subCatg);
        })
        .asFuture()
        .then((value) => catgs);
  }

  Stream<AccessLevelModel>? stream() {
    return SystemMDBService.db.collection('accessLevels').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(AccessLevelModel.fromMap(data));
        },
      ),
    );
  }

  Future<AccessLevelModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection('accessLevels').aggregate(pipeline);

    return AccessLevelModel.fromMap(d);
  }

  static Future<AccessLevelModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection('accessLevels')
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return AccessLevelModel.fromMap(d);
  }

  static Future<AccessLevelModel?> findByLevelNumber(int levelNumber) async {
    var d = await SystemMDBService.db
        .collection('accessLevels')
        .findOne(where.eq('levelNumber', levelNumber));
    if (d == null) {
      return null;
    }
    print(d);
    return AccessLevelModel.fromMap(d);
  }

  Future<AccessLevelModel?> edit() async {
    var r = await SystemMDBService.db.collection('accessLevels').update(
          where.eq('id', id),
          toMap(),
        );
    print(r);
    return this;
  }

  Future<int> delete(String id) async {
    var r = await SystemMDBService.db.collection('accessLevels').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<AccessLevelModel> add() async {
    var r = await SystemMDBService.db.collection('accessLevels').insert(
          toMap(),
        );
    print(r);
    return this;
  }
}

// class UserLevelModel {
//   dynamic id;
//   late String levelDescription;
//   late AccessLevelModel accessLevelModel;
//   late int levelNumber;

//   static UserLevelModel fromMap(Map<String, dynamic> data) {
//     UserLevelModel model = UserLevelModel();
//     model.id = data['id'];
//     model.levelDescription = data['levelDescription'];
//     model.accessLevelModel = AccessLevelModel.fromMap(data['accessLevelModel']);
//     model.levelNumber = data['levelNumber'];
//     return model;
//   }

//   Map<String, dynamic> toMap() => {
//         'id': id,
//         'levelDescription': levelDescription,
//         'accessLevelModel': accessLevelModel.toMap(),
//         'levelNumber': levelNumber,
//       };

//   String toJson() => json.encode(toMap());

//   static UserLevelModel fromJson(String jsn) {
//     return fromMap(json.decode(jsn));
//   }

//   Stream<UserLevelModel>? stream() {
//     return SystemMDBService.db.collection('userLevels').find().transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           sink.add(UserLevelModel.fromMap(data));
//         },
//       ),
//     );
//   }

//   Future<UserLevelModel?> aggregate(List<dynamic> pipeline) async {
//     var d =
//         await SystemMDBService.db.collection('userLevels').aggregate(pipeline);

//     return UserLevelModel.fromMap(d);
//   }

//   Future<UserLevelModel?> get(String id) async {
//     var d = await SystemMDBService.db
//         .collection('userLevels')
//         .findOne(where.eq('id', id));
//     if (d == null) {
//       return null;
//     }
//     return UserLevelModel.fromMap(d);
//   }

//   static Future<UserLevelModel?> findByLevelNumber(int levelNumber) async {
//     var d = await SystemMDBService.db
//         .collection('userLevels')
//         .findOne(where.eq('levelNumber', levelNumber));
//     if (d == null) {
//       return null;
//     }
//     return UserLevelModel.fromMap(d);
//   }

//   Future<UserLevelModel?> edit(String id, Map<String, dynamic> document) async {
//     var r = await SystemMDBService.db.collection('userLevels').update(
//           where.eq('id', id),
//           document,
//         );
//     print(r);
//     return UserLevelModel.fromMap(r);
//   }

//   Future<int> delete(String id) async {
//     var r = await SystemMDBService.db.collection('userLevels').remove(
//           where.eq('id', id),
//         );
//     print(r);
//     return 1;
//   }

//   Future<UserLevelModel> add(UserLevelModel product) async {
//     var r = await SystemMDBService.db.collection('userLevels').insert(
//           product.toMap(),
//         );
//     print(r);
//     return UserLevelModel.fromMap(r);
//   }
// }
