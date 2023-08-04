import 'dart:async';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../utils/system_cache.dart';
import '../utils/system_db.dart';

class SystemNodeModel {
  SystemNodeModel._();

  SystemNodeModel(
    this.id, {
    this.number,
    this.groupId,
    this.placeName,
    this.area,
    this.country,
    this.managerPhoneNumber,
    this.state,
    this.town,
    this.deviceName,
    this.printerName,
    this.deviceId,
    this.firstManagerName,
    this.firstManagerPhone,
    this.firstManagerRank,
    this.secondManagerName,
    this.secondManagerPhone,
    this.secondManagerRank,
    this.thirdManagerName,
    this.thirdManagerPhone,
    this.thirdManagerRank,
    this.metadata = const {
      'recordShiftSANDT': true,
      'recordDaySANDT': true,
      'recordSuppliersTraffic': true,
      'recordCategoriesTraffic': true,
      'recordSubCategoriesTraffic': true,
      'recordSaleUnitsTraffic': true,
      'recordStocksTraffic': true,
      'recordPaymentMethodsTraffic': true,
      'recordSKUsTraffic': true,
      'recordBillsTraffic': true,
      'recordReceiptsTraffic': true,
      'recordReportsTraffic': true,
      'recordInvoicesTraffic': true,
      'recordUsersTraffic': true,
    },
  }) {
    setNode(this);
  }

  late int id;
  int? number;
  String? placeName;
  // late String catgoryName;
  String? managerPhoneNumber;
  String? town;
  String? area;
  String? state;
  String? country;
  double? balance;
  String? deviceName;
  String? printerName;
  String? groupId;
  String? deviceId;
  Map<String, dynamic>? metadata;

  String? firstManagerName;
  String? firstManagerPhone;
  String? firstManagerRank;
  String? secondManagerName;
  String? secondManagerPhone;
  String? secondManagerRank;
  String? thirdManagerName;
  String? thirdManagerPhone;
  String? thirdManagerRank;

  // Actions Recording Options
  bool? recordShiftSANDT = true;
  bool? recordDaySANDT = true;
  bool? recordSuppliersTraffic = true;
  bool? recordCategoriesTraffic = true;
  bool? recordSubCategoriesTraffic = true;
  bool? recordSaleUnitsTraffic = true;
  bool? recordStocksTraffic = true;
  bool? recordPaymentMethodsTraffic = true;
  bool? recordSKUsTraffic = true;
  bool? recordBillsTraffic = true;
  bool? recordReceiptsTraffic = true;
  bool? recordReportsTraffic = true;
  bool? recordInvoicesTraffic = true;
  bool? recordUsersTraffic = true;
  // bool recordTraffic = true;

  static SystemNodeModel fromMap(Map<String, dynamic> data) {
    SystemNodeModel model = SystemNodeModel._();
    model.id = data['id'];
    model.number = data['number'];
    // model.catgoryName = data['catgoryName'];
    model.managerPhoneNumber = data['managerPhoneNumber'];
    model.town = data['town'];
    model.placeName = data['placeName'];
    model.area = data['area'];
    model.state = data['state'];
    model.country = data['country'];
    model.balance = data['balance'];
    model.deviceName = data['deviceName'];
    model.metadata = data['metadata'];
    model.printerName = data['printerName'];
    model.groupId = data['groupId'];
    model.deviceId = data['deviceId'];
    model.firstManagerName = data['firstManagerName'];
    model.firstManagerPhone = data['firstManagerPhone'];
    model.firstManagerRank = data['firstManagerRank'];
    model.secondManagerName = data['secondManagerName'];
    model.secondManagerPhone = data['secondManagerPhone'];
    model.secondManagerRank = data['secondManagerRank'];
    model.thirdManagerName = data['thirdManagerName'];
    model.thirdManagerPhone = data['thirdManagerPhone'];
    model.thirdManagerRank = data['thirdManagerRank'];

    model.recordShiftSANDT = model.metadata?['recordShiftSANDT'];
    model.recordDaySANDT = model.metadata?['recordDaySANDT'];
    model.recordSuppliersTraffic = model.metadata?['recordSuppliersTraffic'];
    model.recordCategoriesTraffic = model.metadata?['recordCategoriesTraffic'];
    model.recordSubCategoriesTraffic =
        model.metadata?['recordSubCategoriesTraffic'];
    model.recordSaleUnitsTraffic = model.metadata?['recordSaleUnitsTraffic'];
    model.recordStocksTraffic = model.metadata?['recordStocksTraffic'];
    model.recordPaymentMethodsTraffic =
        model.metadata?['recordPaymentMethodsTraffic'];
    model.recordSKUsTraffic = model.metadata?['recordSKUsTraffic'];
    model.recordBillsTraffic = model.metadata?['recordBillsTraffic'];
    model.recordReceiptsTraffic = model.metadata?['recordReceiptsTraffic'];
    model.recordReportsTraffic = model.metadata?['recordReportsTraffic'];
    model.recordInvoicesTraffic = model.metadata?['recordInvoicesTraffic'];
    model.recordUsersTraffic = model.metadata?['recordUsersTraffic'];
    setNode(model);
    return model;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'placeName': placeName,
        // 'catgoryName': catgoryName,
        'managerPhoneNumber': managerPhoneNumber,
        'town': town,
        'area': area,
        'state': state,
        'country': country,
        'balance': balance,
        'deviceName': deviceName,
        'metadata': metadata,
        'printerName': printerName,
        'groupId': groupId,
        'deviceId': deviceId,
        'firstManagerName': firstManagerName,
        'firstManagerPhone': firstManagerPhone,
        'firstManagerRank': firstManagerRank,
        'secondManagerName': secondManagerName,
        'secondManagerPhone': secondManagerPhone,
        'secondManagerRank': secondManagerRank,
        'thirdManagerName': thirdManagerName,
        'thirdManagerPhone': thirdManagerPhone,
        'thirdManagerRank': thirdManagerRank,
      };

  String toJson() => json.encode(toMap());

  static SystemNodeModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static SystemNodeModel? get stored => SystemCache.get('node');
  void _setNode(SystemNodeModel pos) => SystemCache.set('node', pos);
  static void setNode(SystemNodeModel? pos) => SystemCache.set('node', pos);

  static const String collectionName = 'systemFile';

  // static void _deleteUser() => SystemCache.remove('pos');

  static Future<List<SystemNodeModel>> getAll() {
    List<SystemNodeModel> models = [];
    return SystemMDBService.db
        .collection(collectionName)
        .find()
        .transform<SystemNodeModel>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              sink.add(SystemNodeModel.fromMap(data));
            },
          ),
        )
        .listen((subCatg) {
          models.add(subCatg);
        })
        .asFuture()
        .then((value) => models);
  }

  Stream<SystemNodeModel>? stream() {
    return SystemMDBService.db.collection(collectionName).find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(SystemNodeModel.fromMap(data));
        },
      ),
    );
  }

  Future<SystemNodeModel?> aggregate(List<dynamic> pipeline) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .aggregate(pipeline);

    return SystemNodeModel.fromMap(d);
  }

  static Future<SystemNodeModel?> init() async {
    var pos = await get(0);
    if (pos == null) {
      return null;
    }
    setNode(pos);
    return pos;
  }

  static Future<SystemNodeModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    // print(d);
    if (d == null) {
      return null;
    }

    return SystemNodeModel.fromMap(d);
  }

  Future<SystemNodeModel?> findByName(String name) async {
    var d = await SystemMDBService.db
        .collection(collectionName)
        .findOne(where.eq('id', id));
    if (d == null) {
      return null;
    }
    return SystemNodeModel.fromMap(d);
  }

  Future<SystemNodeModel?> edit() async {
    var r = await SystemMDBService.db.collection(collectionName).update(
          where.eq('id', id),
          toMap(),
        );
    await init();

    print(r);
    return await init();
  }

  Future<int> delete(int id) async {
    var r = await SystemMDBService.db.collection(collectionName).remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection(collectionName).insert(
          toMap(),
        );

    await init();
    print(r);
    return 1;
  }
}
