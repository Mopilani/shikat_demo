import '/utils/sync_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../utils/check_funcs.dart';
import '../utils/get_x.dart';
import '../utils/system_db.dart';

SystemConfig? _runtimeStoredInstance;

class InterfaceType {
  static const String administration = 'administration';
  static const String reception = 'reception';
  static const String pharmacy = 'pharmacy';
  static const String lab = 'lab';
}

class SystemConfig {
  factory SystemConfig() {
    if (_runtimeStoredInstance == null) {
      _runtimeStoredInstance = SystemConfig.init();
      return _runtimeStoredInstance!;
    }
    return _runtimeStoredInstance!;
  }

  SystemConfig.init([SystemConfig? $with]) {
    if ($with != null) {
      id = $with.id;
      printer = $with.printer;
      theme = $with.theme;
      invoicesSaveDirectoryPath = $with.invoicesSaveDirectoryPath;
      pageRoute = $with.pageRoute;
      animations = $with.animations;
      runSyncService = $with.runSyncService;
      deviceOnNetType = $with.deviceOnNetType;
      salesType = $with.salesType;
      svnamas = $with.svnamas;
      syncOperationsState = $with.syncOperationsState;
      firstStart = $with.firstStart;
      paddings = $with.paddings;
    }
  }

  static Map<String, dynamic> systemConfig = <String, dynamic>{};

  static SystemConfig? stored = _runtimeStoredInstance;

  int id = 0;
  String get invoicesSaveDirectoryPath => _invoicesSaveDirectoryPath!;
  String get pageRoute => _pageRoute ?? 'CupertinoPageRoute';
  String get printer => _printer!;
  String get theme => _theme!;
  String get salesType => _salesType!;
  bool get animations => _animations;
  bool get runSyncService => _runSyncService;
  DeviceOnNetType get deviceOnNetType => _deviceOnNetType;
  BackupState get syncOperationsState => _syncOperationsState;
  bool get firstStart => _firstStart;
  String? get paddings => _paddings;
  List<String>? get svnamas => _svnamas;

  set invoicesSaveDirectoryPath(String? v) {
    _invoicesSaveDirectoryPath = v;
    edit().asStream();
  }

  set paddings(String? v) {
    _paddings = v;
    edit().asStream();
  }

  set addSv(String v) {
    _svnamas!.add(v);
    edit().asStream();
  }

  set removeSv(int index) {
    _svnamas!.removeAt(index);
    edit().asStream();
  }

  set svnamas(List<String>? v) {
    _svnamas = v;
    edit().asStream();
  }

  set pageRoute(String? v) {
    _pageRoute = v;
    edit().asStream();
  }

  set printer(String? v) {
    _printer = v;
    edit().asStream();
  }

  set theme(String? v) {
    _theme = v;
    edit().asStream();
  }

  set salesType(String? v) {
    _salesType = v;
    edit().asStream();
  }

  set animations(bool v) {
    _animations = v;
    edit().asStream();
  }

  set runSyncService(bool v) {
    _runSyncService = v;
    edit().asStream();
  }

  set deviceOnNetType(DeviceOnNetType v) {
    _deviceOnNetType = v;
    edit().asStream();
  }

  set syncOperationsState(BackupState v) {
    _syncOperationsState = v;
    edit().asStream();
  }

  set firstStart(bool v) {
    _firstStart = v;
    edit().asStream();
  }

  String? _invoicesSaveDirectoryPath;
  List<String>? _svnamas;
  String? _pageRoute;
  String? _printer;
  String? _theme = 'light';
  String? _salesType = 'administration';
  bool _animations = true;
  bool _runSyncService = true;
  DeviceOnNetType _deviceOnNetType = DeviceOnNetType.master;
  BackupState _syncOperationsState = BackupState.running;
  bool _firstStart = true;
  String? _paddings;

  static Future<SystemConfig?> get() async {
    var r = await SystemMDBService.db
        .collection('sysconfig')
        .findOne(where.eq('id', 0));
    if (r == null) {
      return null;
    }
    var model = SystemConfig.fromMap(r);
    return model;
  }

  Future<void> edit() async {
    await SystemMDBService.db.collection('sysconfig').update(
          where.eq('id', 0),
          asMap(),
        );
    // print(r);
  }

  Future<void> add() async {
    await SystemMDBService.db.collection('sysconfig').insert(
          asMap(),
        );
  }

  asMap() => {
        'id': id,
        'invoicesSaveDirectoryPath': invoicesSaveDirectoryPath,
        'printer': printer,
        'salesType': salesType,
        'theme': theme,
        'animations': animations,
        'runSyncService': runSyncService,
        'svnamas': svnamas,
        'paddings': paddings,
        'firstStart': firstStart,
        'deviceOnNetType': deviceOnNetType.toString(),
        'syncOperationsState': syncOperationsState.toString(),
      };

  static SystemConfig fromMap(Map<String, dynamic> sysconfigData) {
    var model = SystemConfig();

    model.invoicesSaveDirectoryPath =
        sysconfigData['invoicesSaveDirectoryPath'];
    model.printer = sysconfigData['printer'];
    model.theme = sysconfigData['theme'];
    model.salesType = sysconfigData['salesType'];
    model.animations = sysconfigData['animations'] ?? true;
    model.runSyncService = sysconfigData['runSyncService'] ?? true;
    model.firstStart = sysconfigData['firstStart'] ?? true;
    model.paddings = sysconfigData['paddings'];
    model.svnamas =
        sysconfigData['svnamas'] == null ? null : [...sysconfigData['svnamas']];
    model.deviceOnNetType = sysconfigData['deviceOnNetType'] != null
        ? deviceOnNetTypeFromString(sysconfigData['deviceOnNetType'])
        : DeviceOnNetType.master;
    model.syncOperationsState = sysconfigData['syncOperationsState'] != null
        ? backupStateTypeFromString(sysconfigData['syncOperationsState'])
        : BackupState.stopped;
    return model;
  }

  Future<String?> getUserDirPath() async {
    String currentUserName = await getCurrentUserName();
    var currentUserDirPath = 'C:/Users/$currentUserName';
    // currentUserName == null ? currentUserDirPath = currentUserName : null;
    if (await chkdir(currentUserDirPath)) {
      return currentUserDirPath;
    }
    return null;
  }

  Future<String?> getUserDocumentsPath() async {
    String currentUserName = await getCurrentUserName();
    var currentUserDirPath = 'C:/Users/$currentUserName/Documents';
    // currentUserName == null ? currentUserDirPath = currentUserName : null;
    if (await chkdir(currentUserDirPath)) {
      return currentUserDirPath;
    }
    return null;
  }

  Future<String?> getUserPicturesPath() async {
    String currentUserName = await getCurrentUserName();
    var currentUserDirPath = 'C:/Users/$currentUserName/Pictures';
    // currentUserName == null ? currentUserDirPath = currentUserName : null;
    if (await chkdir(currentUserDirPath)) {
      return currentUserDirPath;
    }
    return null;
  }

  Future<String?> getUserAppDataDirPath() async {
    String currentUserName = await getCurrentUserName();
    var currentUserDirPath = 'C:/Users/$currentUserName/AppData';
    // currentUserName == null ? currentUserDirPath = currentUserName : null;
    if (await chkdir(currentUserDirPath)) {
      return currentUserDirPath;
    }
    return null;
  }
}
