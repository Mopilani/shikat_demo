import 'models/access_level_model.dart';
import 'models/processes_model.dart';
import 'models/system_config.dart';
import 'models/system_node_model.dart';
import 'models/user_model.dart';

Future<void> initialData() async {
  // await SystemMDBService.db.collection('users').drop();
  // await SystemMDBService.db.collection('accessLevels').drop();
  // await SystemMDBService.db.collection(SubscriptionModel.collectionName).drop();
  // await SystemMDBService.db.collection('canceledSubscriptions').drop();
  // await SystemMDBService.db.collection('wallets').drop();
  // await SystemMDBService.db.collection('subscriptions').drop();
  // await SystemMDBService.db.collection('subscripers').drop();

  // DepartmentModel.stream().listen((dpr) async {
  //   // await SystemMDBService.db.collection(dpr.id).drop();
  // });
  if (SystemConfig().firstStart) {
    await SystemNodeModel(
      0,
      area: 'الخرطوم',
      placeName: 'صندوق وداع الضباط',
      country: 'السودان',
      managerPhoneNumber: '0123456789',
      number: 0123456789,
      state: 'الخرطوم',
      town: 'الخرطوم',
      deviceName: 'عند بككا دسكتوب',
      deviceId: 'A',
      firstManagerName: '',
      firstManagerPhone: '',
      secondManagerName: '',
      secondManagerPhone: '',
      thirdManagerName: '',
      thirdManagerPhone: '',
    ).add();
  } else {
    await SystemNodeModel.init();
  }

  await SystemNodeModel.init();
  if (SystemConfig().firstStart) {
    await ProcessesModel(
      0,
      businessDay: DateTime.now(),
      currentDaty: DateTime.now(),
    ).add();
  }
  await ProcessesModel.get(0); // Initialization for the stored model

  if (SystemConfig().firstStart) {
    print('First Start');

    /// Access Levels
    await AccessLevelModel(
      0,
      accessToken: 'Support',
      levelDescription: 'For Support Team',
      levelNumber: 0,
      nodeId: 1,
      allowedLevels: {},
    ).add();

    await AccessLevelModel(
      1,
      accessToken: 'MNGMNGMNG',
      levelDescription: 'Manager',
      levelNumber: 1,
      nodeId: 1,
      allowedLevels: {},
    ).add();

    await AccessLevelModel(
      2,
      accessToken: 'CASHTHATILOVE',
      levelDescription: 'Cashier',
      levelNumber: 2,
      nodeId: 1,
      allowedLevels: {},
    ).add();

    await AccessLevelModel(
      3,
      accessToken: 'ASSISSTANT',
      levelDescription: 'Assistant',
      levelNumber: 3,
      nodeId: 1,
      allowedLevels: {},
    ).add();

    /// Users
    await UserModel(
      0,
      username: '12',
      password: '12',
      firstname: 'الدعم الفني',
      lastname: 'Support',
      phoneNumber: '+249113615012',
      accessLevelModel: await AccessLevelModel.get(0),
    ).add();

    await UserModel(
      1,
      username: '66',
      password: '3',
      firstname: 'الادارة',
      lastname: '',
      phoneNumber: '',
      accessLevelModel: await AccessLevelModel.get(1),
    ).add();

    // await UserModel.signin('12', '12');

    // var registeredUser = SysNav.registerRoutesForUser(UserModel.stored!, [
    //   UsersView,
    //   UsersControle,
    // ]);
    // await registeredUser.edit();
  } else {
    await UserModel.signin('12', '12');
  }
  SystemConfig().firstStart = false;
  await SystemConfig().edit();
}
