import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../utils/system_cache.dart';
import '../utils/system_db.dart';
import 'action_model.dart';
import 'patchs.dart';

class ProcessesModel {
  ProcessesModel._();
  ProcessesModel.init() {
    _setModel(this);
  }

  ProcessesModel(
    this.id, {
    this.lastTicketId = 0,
    this.lastCategoryId = 0,
    this.lastSubcategoryId = 0,
    this.lastStockId = 0,
    this.lastSupplierId = 0,
    this.lastBillId = 0,
    this.ornikNumber = 1,
    this.lastPatientId = 1,
    this.lastNoteId = 1,
    this.lastMedicalServiceId = 1,
    this.lastReservationId = 1,
    this.lastLabAnalysisId = 1,
    this.lastSubscriperId = 1,
    this.lastDialyId = 1,
    this.lastSKUId = 0,
    this.lastSaleUnitId = 0,
    this.shiftNumber = 1,
    this.printerName,
    required this.businessDay,
    required this.currentDaty,
    this.dayStarted = false,
    this.shiftStarted = false,
    // this.lastTaskId,
    this.lastActionId = 0,
  }) {
    currentDaty;
    _setModel(this);
  }

  late int id;
  // late String catgoryName;
  int lastTicketId = 0;
  int lastCategoryId = 0;
  int lastSubcategoryId = 0;
  int lastStockId = 0;

  int lastSupplierId = 0;
  int lastBillId = 0;
  int ornikNumber = 0;
  int lastSKUId = 0;
  int lastReservationId = 1;
  int lastLabAnalysisId = 1;
  int lastSubscriperId = 1;
  // int rangeStartId = 0;
  // int rangeEndId = 100;
  int lastPatientId = 1;
  int lastNoteId = 1;
  int lastMedicalServiceId = 1;
  int lastDialyId = 1;

  int lastSaleUnitId = 0;
  int lastActionId = 0;
  int shiftNumber = 1;
  bool dayStarted = false;
  bool shiftStarted = false;
  // bool rangedIdList = 100;
  String? printerName;
  late DateTime businessDay;
  late DateTime currentDaty;

  String businessDayString() {
    return '${businessDay.year}-${businessDay.month}-${businessDay.day}';
  }

  static ProcessesModel fromMap(Map<String, dynamic> data) {
    ProcessesModel model = ProcessesModel._();
    model.id = data['id'];

    model.lastTicketId = data['lastTicketId'];
    model.lastCategoryId = data['lastCategoryId'];
    model.lastSubcategoryId = data['lastSubcategoryId'];
    model.lastStockId = data['lastStockId'];
    model.printerName = data['printerName'];

    model.lastSKUId = data['lastSKUId'];
    model.lastSupplierId = data['lastSupplierId'];
    model.lastBillId = data['lastBillId'];
    model.ornikNumber = data['ornikNumber'];
    model.lastReservationId = data['lastReservationId'] ?? 1;
    model.lastLabAnalysisId = data['lastLabAnalysisId'] ?? 1;
    model.lastSubscriperId = data['lastSubscriperId'] ?? 1;
    model.lastDialyId = data['lastDialyId'] ?? 1;
    model.lastPatientId = data['lastPatientId'] ?? 1;
    model.lastNoteId = data['lastNoteId'] ?? 1;
    model.lastMedicalServiceId = data['lastMedicalServiceId'] ?? 1;
    model.lastActionId = data['lastActionId'] ?? 0;

    model.lastSaleUnitId = data['lastSaleUnitId'];
    model.shiftNumber = data['shiftNumber'];
    model.businessDay = stringOrDateTime(data['businessDay'])!;
    model.dayStarted = data['dayStarted'] ?? false;
    model.shiftStarted = data['shiftStarted'] ?? false;
    model.currentDaty = stringOrDateTime(data['currentDaty'])!;
    // model.edit();
    return model;
  }

  Future<int> requestActionId() async {
    lastActionId++;
    await edit();
    return lastActionId;
  }

  Future<int> requestLabAnalysisId() async {
    lastLabAnalysisId++;
    // await edit();
    return lastLabAnalysisId;
  }

  Future<int> requestSubscriperId() async {
    lastSubscriperId++;
    bool notGetted = true;
    do {
      // var r = await SubscriperModel.get(lastSubscriperId);
      // if (r == null) {
      //   return lastSubscriperId;
      // }
    } while (notGetted);

    // await edit();
  }

  Future<int> requestReservationId() async {
    lastReservationId++;
    // await edit();
    return lastReservationId;
  }

  Future<int> requestDialyId() async {
    lastDialyId++;
    // await edit();
    return lastDialyId;
  }

  Future<int> requestPatientId() async {
    lastPatientId++;
    // await edit();
    return lastPatientId;
  }

  Future<int> requestNoteId() async {
    lastNoteId++;
    // await edit();
    return lastNoteId;
  }

  Future<int> requestMedicalServiceId() async {
    lastMedicalServiceId++;
    // await edit();
    return lastMedicalServiceId;
  }

  // Future<int> requestReceiptId() async {
  //   lastReceiptId++;
  //   // await edit();
  //   return lastReceiptId;
  // }

  // Future<int> updateReceiptId(id) async {
  //   lastReceiptId = id;
  //   await edit();
  //   return lastReceiptId;
  // }

  Future<int> requestOrnikNumber() async {
    ornikNumber++;
    await edit();
    return ornikNumber;
  }

  Future<int> requestBillId() async {
    lastBillId++;
    await edit();
    return lastBillId;
  }

  Future<int> requestShiftNumber() async {
    shiftNumber++;
    await edit();
    return shiftNumber;
  }

  Future<int> requestSaleUnitId() async {
    lastSaleUnitId++;
    await edit();
    return lastSaleUnitId;
  }

  Future<int> requestCategoryId() async {
    lastCategoryId++;
    await edit();
    return lastCategoryId;
  }

  Future<int> requestSubCategoryId() async {
    lastSubcategoryId++;
    await edit();
    return lastSubcategoryId;
  }

  Future<int> requestSupplierId() async {
    lastSupplierId++;
    await edit();
    return lastSupplierId;
  }

  ProcessesModel copyWith({
    int? id,
    int? lastTicketId,
    int? lastCategoryId,
    int? lastSKUId,
    int? lastSubcategoryId,
    int? lastStockId,
    int? lastSupplierId,
    int? lastBillId,
    int? ornikNumber,
    int? lastSaleUnitId,
    int? lastReservationId,
    int? lastLabAnalysisId,
    int? lastSubscriperId,
    int? lastDialyId,
    int? lastPatientId,
    int? lastActionId,
    int? lastNoteId,
    int? lastMedicalServiceId,
    int? shiftNumber,
    bool? dayStarted,
    bool? shiftStarted,
    DateTime? businessDay,
    DateTime? currentDaty,
    String? printerName,
  }) {
    return ProcessesModel(
      id ?? this.id,
      lastTicketId: lastTicketId ?? this.lastTicketId,
      lastCategoryId: lastCategoryId ?? this.lastCategoryId,
      lastSubcategoryId: lastSubcategoryId ?? this.lastSubcategoryId,
      lastStockId: lastStockId ?? this.lastStockId,
      lastSKUId: lastSKUId ?? this.lastSKUId,
      lastSupplierId: lastSupplierId ?? this.lastSupplierId,
      lastBillId: lastBillId ?? this.lastBillId,
      ornikNumber: ornikNumber ?? this.ornikNumber,
      lastReservationId: lastReservationId ?? this.lastReservationId,
      lastLabAnalysisId: lastLabAnalysisId ?? this.lastLabAnalysisId,
      lastSubscriperId: lastSubscriperId ?? this.lastSubscriperId,
      lastDialyId: lastDialyId ?? this.lastDialyId,
      lastPatientId: lastPatientId ?? this.lastPatientId,
      lastNoteId: lastNoteId ?? this.lastNoteId,
      lastActionId: lastActionId ?? this.lastActionId,
      lastMedicalServiceId: lastMedicalServiceId ?? this.lastMedicalServiceId,
      lastSaleUnitId: lastSaleUnitId ?? this.lastSaleUnitId,
      businessDay: businessDay ?? this.businessDay,
      currentDaty: currentDaty ?? this.currentDaty,
      dayStarted: dayStarted ?? this.dayStarted,
      shiftStarted: shiftStarted ?? this.shiftStarted,
      shiftNumber: shiftNumber ?? this.shiftNumber,
      printerName: printerName ?? this.printerName,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'lastTicketId': lastTicketId,
        'lastCategoryId': lastCategoryId,
        'lastSubcategoryId': lastSubcategoryId,
        'lastStockId': lastStockId,
        'lastSupplierId': lastSupplierId,
        'lastBillId': lastBillId,
        'ornikNumber': ornikNumber,
        'lastSKUId': lastSKUId,
        'lastReservationId': lastReservationId,
        'lastLabAnalysisId': lastLabAnalysisId,
        'lastSubscriperId': lastSubscriperId,
        'lastDialyId': lastDialyId,
        'lastPatientId': lastPatientId,
        'lastSaleUnitId': lastSaleUnitId,
        'lastActionId': lastActionId,
        'businessDay': businessDay,
        'currentDaty': currentDaty,
        'dayStarted': dayStarted,
        'shiftStarted': shiftStarted,
        'shiftNumber': shiftNumber,
        'printerName': printerName,
        'lastNoteId': lastNoteId,
        'lastMedicalServiceId': lastMedicalServiceId,
      };

  String toJson() => json.encode(toMap());

  static ProcessesModel fromJson(String jsn) {
    return fromMap(json.decode(jsn));
  }

  static ProcessesModel? get stored => SystemCache.get('processes');
  void setModel(ProcessesModel processes) =>
      SystemCache.set('processes', processes);
  static void _setModel(ProcessesModel? processes) =>
      SystemCache.set('processes', processes);

  // static void _deleteModel() => SystemCache.remove('processes');

  static Stream<ProcessesModel>? stream() {
    return SystemMDBService.db.collection('processes').find().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(ProcessesModel.fromMap(data));
        },
      ),
    );
  }

  Future<void> startDay(DateTime time, BuildContext context) async {
    if (dayStarted) {
      toast(
        'عليك اقفال اليوم السابق اولا',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    businessDay = time;
    dayStarted = true;
    await edit().then((processes) {
      ActionModel.startedDay(processes.businessDay);
      alert(
        context,
        AlertType.success,
        'تم بدء اليوم',
        'اغلاق',
      );
    });
  }

  Future<void> endDay(BuildContext context) async {
    // print(dayStarted);
    // print(shiftStarted);
    if (!dayStarted) {
      toast(
        'ليم يتم بدء اليوم',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    if (shiftStarted) {
      toast(
        'عليك قفال الوردية المفتوحة حاليا اولا',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    // var subscription = ReceiptModel.backupAndReset();
    // subscription.onError((e) {
    //   alert(
    //     context,
    //     AlertType.error,
    //     'حدث خطأ اثناء اقفال اليوم: $e',
    //     'اغلاق',
    //   );
    // });
    // subscription.onDone(() async {
    //   alert(
    //     context,
    //     AlertType.success,
    //     'تم اقفال اليوم بنجاح',
    //     'اغلاق',
    //   );
    // });
    shiftNumber = 0;
    dayStarted = false;
    await edit().then((processes) {
      ActionModel.endedTheDay(processes.businessDay);
    });

    // businessDay =
    //     DateTime(businessDay.year, businessDay.month, businessDay.day + 1);
    // await edit().then((processes) {
    //   ActionModel.startedDay(processes.businessDay);
    //   // SystemMDBService.repsDb.collection(businessDay.toString());
    // });
  }

  // Future<void> startShift(BuildContext context) async {
  //   if (!dayStarted) {
  //     toast(
  //       'ليم يتم بدء اليوم',
  //       duration: const Duration(seconds: 5),
  //     );
  //     return;
  //   }
  //   if (shiftStarted) {
  //     toast(
  //       'عليك اقفال الوردية $shiftNumber',
  //       duration: const Duration(seconds: 5),
  //     );
  //     return;
  //   }
  //   var shiftModel = ShiftModel(
  //     user: UserModel.stored!,
  //     number: shiftNumber + 1,
  //     saledReceiptsIds: <int>[],
  //     startDateTime: businessDay,
  //     moneyInventory: <MoneyInventory>[],
  //   );
  //   await shiftModel.add().then((_) async {
  //     shiftStarted = true;
  //     shiftNumber++;
  //     await edit().then((processes) {
  //       ActionModel.startedNewShift(processes.shiftNumber);
  //     });
  //   });
  // }

  // Future<void> endShift(BuildContext context, ShiftModel shiftModel) async {
  //   // print(shiftStarted);
  //   // print(dayStarted);
  //   if (!shiftStarted) {
  //     toast(
  //       'ليم يتم بدء وردية بعد',
  //       duration: const Duration(seconds: 5),
  //     );
  //     return;
  //   }
  //   if (!dayStarted) {
  //     toast(
  //       'ليم يتم بدء يوم بعد',
  //       duration: const Duration(seconds: 5),
  //     );
  //     return;
  //   }
  //   await shiftModel.edit().then((_) async {
  //     shiftModel.startDateTime = currentDaty;
  //     shiftStarted = false;
  //     await edit().then((processes) async {
  //       // / Print the Shift end report
  //       try {
  //         await ShiftReportsMaker.printReport(shiftModel);
  //       } catch (e, s) {
  //         print(e);
  //         print(s);
  //       }
  //       await ActionModel.endedTheShift(processes.shiftNumber).then((value) {
  //         alert(
  //           context,
  //           AlertType.success,
  //           'تم اقفال الوردية',
  //           'اغلاق',
  //         );
  //       });
  //     });
  //   });
  // }

  Future<ProcessesModel?> aggregate(List<dynamic> pipeline) async {
    var d =
        await SystemMDBService.db.collection('processes').aggregate(pipeline);

    return ProcessesModel.fromMap(d);
  }

  static Future<ProcessesModel?> get(int id) async {
    var d = await SystemMDBService.db
        .collection('processes')
        .findOne(where.eq('id', id));
    if (d == null) {
      throw 'null';
    }
    var model = ProcessesModel.fromMap(d);
    _setModel(model);
    return model;
  }

  Future<ProcessesModel?> findByShiftNumber(int shiftNumber) async {
    var d = await SystemMDBService.db
        .collection('processes')
        .findOne(where.eq('shiftNumber', shiftNumber));
    if (d == null) {
      return null;
    }
    return ProcessesModel.fromMap(d);
  }

  Future<ProcessesModel> edit() async {
    var r = await SystemMDBService.db.collection('processes').update(
          where.eq('id', id),
          toMap(),
        );

    // _setModel(await get(id));
    (await get(id));
    print(r);
    return stored!;
  }

  Future<int> delete() async {
    var r = await SystemMDBService.db.collection('processes').remove(
          where.eq('id', id),
        );
    print(r);
    return 1;
  }

  Future<int> add() async {
    var r = await SystemMDBService.db.collection('processes').insert(
          toMap(),
        );
    print(r);
    return 1;
  }
}

String dateToString(DateTime datetime, [String sparator = '-']) {
  return '${datetime.year}$sparator${datetime.month}$sparator${datetime.day}';
}

void alert(
    BuildContext context, AlertType type, String title, String buttonText) {
  Alert(
    context: context,
    type: type,
    title: title,
    buttons: [
      DialogButton(
        child: Text(buttonText),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  ).show();
}
