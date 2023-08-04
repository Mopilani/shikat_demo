import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_cache.dart';
import '../utils/system_db.dart';
import 'access_level_model.dart';
import 'action_model.dart';

class UserModel {
  UserModel(
    this.id, {
    // required this.levelNumber,
    required this.username,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.accessLevelModel,
  });

  int id;
  // late int levelNumber;
  late String username;
  late String password;
  late String firstname;
  late String lastname;
  late String phoneNumber;
  AccessLevelModel? accessLevelModel;

  static UserModel? get stored => SystemCache.get('user');

  void setUser(UserModel user) => SystemCache.set('user', user);
  static void _setUser(UserModel? user) => SystemCache.set('user', user);

  static void _deleteUser() => SystemCache.remove('user');

  static UserModel fromMap(Map<String, dynamic> data) {
    UserModel user = UserModel(
      data['id'],
      // levelNumber: data['levelNumber'],
      username: data['username'],
      password: data['password'],
      firstname: data['firstname'],
      lastname: data['lastname'],
      phoneNumber: data['phoneNumber'],
      accessLevelModel: data['accessLevelModel'] != null
          ? AccessLevelModel.fromMap(data['accessLevelModel'])
          : null,
    );
    return user;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
        'phoneNumber': phoneNumber,
        // 'levelNumber': levelNumber,
        'accessLevelModel': accessLevelModel?.toMap(),
      };

  static const String collectionName = 'users';

  String toJson() => json.encode(toMap());

  static UserModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static Future<void> signout() async {
    // UserModel? user = UserModel.stored;
    await ActionModel.signout();
    _deleteUser();
  }

  static Future<UserModel?> signin(String username, String password) async {
    var r = await findByUsername(username);

    if (r?.password == password) {
      _setUser(r!);
      await ActionModel.signin();
      return r;
    }
    return null;
  }

  static Future<bool> checkPasswordForUser(
      String username, String password) async {
    var r = await findByUsername(username);

    if (r?.password == password) {
      return true;
    }
    return false;
  }

  // Future<UserModel?> signup() async {
  //   var r = await findByUsername(username);
  //   if (r?.username == username) {
  //     print('Username Was Exists');
  //   } else {
  //     var newUser = await add(); // Must be add for later
  //     // _setUser(newUser);
  //     return newUser;
  //   }
  //   return null;
  // }

  static Stream<UserModel> stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(UserModel.fromMap(data));
        },
      ),
    );
  }

  Future<UserModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return UserModel.fromMap(d);
  }

  static Future<UserModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return UserModel.fromMap(d);
  }

  static Future<UserModel?> findByUsername(String username) async {
    var r = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('username', username));
    // var s = SystemMDBService.db.collection(collectionName).find();
    // print(await s.first);
    // print(r);
    if (r == null) {
      return null;
    }
    return UserModel.fromMap(r);
  }

  Future<UserModel?> edit([bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    if (!fromSyncService) {
      await ActionModel.updatedUser(this, collectionName);
    }
    // print('User Update: $r');
    return this;
  }

  Future<int> delete([bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );
    if (!fromSyncService) {
      await ActionModel.deletedUser(this, collectionName);
    }
    print(r);
    return 1;
  }

  Future<UserModel> add([bool fromSyncService = false]) async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );
    print(r);
    try {
      if (!fromSyncService) {
        await ActionModel.createdUser(this, collectionName);
      }
    } catch (e) {
      //
    }
    // toast(r['ok'].toString()jyhf);
    return this;
    //   toast(r['ok']);
    // if (r['ok'] == '1.0') {
    // } else {
    // }
  }
}
