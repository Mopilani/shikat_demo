import 'dart:convert';
import 'patchs.dart';

class ActionDataModel {
  ActionDataModel(
    this.id, {
    required this.action,
    required this.firstname,
    required this.lastname,
    this.metaData,
    required this.time,
  }) {
    // this.time = time ??= DateTime.now();
  }

  static ActionDataModel fromMap(Map<String, dynamic> data) {
    return ActionDataModel(
      data['id'],
      action: data['action'],
      firstname: data['firstname'],
      lastname: data['lastname'],
      metaData: data['metaData'],
      time: stringOrDateTime(data['time'])!,
    );
  }

  Map<String, dynamic> toMap() => {
        'action': action,
        'firstname': firstname,
        'lastname': lastname,
        'metaData': metaData,
        'time': time,
      };

  @override
  String toString() {
    return '$firstname:$lastname:$time:$action:${json.encode(metaData)}';
  }

  static ActionDataModel? fromString(int id, String line) {
    var segs = line.split(':');

    // int id;
    late String firstname;
    late String lastname;
    late DateTime time;
    late String action;
    Map<String, dynamic>? metaData;

    int currentSegIndex = 0;
    for (var seg in segs) {
      currentSegIndex == 0 ? firstname = seg : null;
      currentSegIndex == 1 ? lastname = seg : null;
      currentSegIndex == 2 ? time = DateTime.parse(seg) : null;
      currentSegIndex == 3 ? action = seg : null;
      if (currentSegIndex == 4) {
        var seg5 = line.substring(line.indexOf(seg[0]));
        try {
          metaData = json.decode(seg5);
        } catch (e) {
          //
        }
        return ActionDataModel(
          id,
          action: action,
          firstname: firstname,
          lastname: lastname,
          metaData: metaData,
          time: time,
        );
      }
      currentSegIndex++;
    }
    return null;
  }

  dynamic id;
  String firstname;
  String lastname;
  DateTime time;
  String action;
  Map<String, dynamic>? metaData;

  static const Map<String, dynamic> registeredActions = {
    'in': 'تسجيل دخول',
    'out': 'تسجيل خروج',
    'sshft': 'بدء وردية',
    'sdy': 'بدء يوم',
    'cb': 'انشاء فاتورة',
    'ub': 'تحديث فاتورة',
    'pb': 'طباعة فاتورة',
    'nb': 'الغاء فاتورة',
    'tb': 'استرجاع فاتورة',
    'cr': 'انشاء ايصال',
    'tr': 'استرجاع ايصال',
    'nr': 'الغاء ايصال',
    'ur': 'تحديث ايصال',
    'pr': 'طباعة ايصال',
    'cspl': 'انشاء مورد',
    'uspl': 'تحديث مورد',
    'dspl': 'حذف مورد',
    'cctg': 'انشاء شريحة رئيسية',
    'uctg': 'تحديث شريحة رئيسية',
    'dctg': 'حذف شريحة رئيسية',
    'csctg': 'انشاء شريحة فرعية',
    'usctg': 'تحديث شريحة فرعية',
    'dsctg': 'حذف شريحة فرعية',
    'csunt': 'انشاء وحدة بيع',
    'usunt': 'تحديث وحدة بيع',
    'dsunt': 'حذف وحدة بيع',
    'cstk': 'انشاء مخزن',
    'ustk': 'تحديث مخزن',
    'dstk': 'حذف مخزن',
    'cpym': 'انشاء طريقة دفع',
    'upym': 'تحديث طريقة دفع',
    'dpym': 'حذف طريقة دفع',
    'cmsf': 'انشاء خزنة',
    'umsf': 'تحديث خزنة',
    'dmsf': 'حذف خزنة',
    'eshft': 'انهاء وردية',
    'edy': 'انهاء يوم',
    'csbcr': 'انشاء مشترك',
    'usbcr': 'تحديث مشترك',
    'dsbcr': 'حذف مشترك',
    'csub': 'انشاء اشتراك',
    'usub': 'تحديث اشتراك',
    'dsub': 'حذف اشتراك',
    'crnk': 'انشاء رتبة',
    'urnk': 'تحديث رتبة',
    'drnk': 'حذف رتبة',
    'cbtch': 'انشاء دفعة',
    'ubtch': 'تحديث دفعة',
    'dbtch': 'حذف دفعة',
    'cdprt': 'انشاء قطاع',
    'udprt': 'تحديث قطاع',
    'ddprt': 'حذف قطاع',
    'cusr': 'انشاء مستخدم',
    'uusr': 'تحديث مستخدم',
    'dusr': 'حذف مستخدم',
  };

  // C. R. U. D. + P. Print - I. In - O. Out
  // S. Start - E. End - T. Returned - N. Canceld

  static const String signin = 'in';
  static const String signout = 'out';

  static const String startedAShift = 'sshft';
  static const String startedADay = 'sdy';

  static const String createdABill = 'cb';
  static const String updatedABill = 'ub';
  static const String printedABill = 'pb';
  static const String canceledABill = 'nb';
  static const String returnedABill = 'tb';

  static const String createdAReceipt = 'cr';
  static const String returnedAReceipt = 'tr';
  static const String canceledAReceipt = 'nr';
  static const String updatedAReceipt = 'ur';
  static const String printedAReceipt = 'pr';

  static const String createdASupplier = 'cspl';
  static const String updatedASupplier = 'uspl';
  static const String deletedASupplier = 'dspl';

  static const String createdACategory = 'cctg';
  static const String updatedACategory = 'uctg';
  static const String deletedACategory = 'dctg';

  static const String createdASubCategory = 'csctg';
  static const String updatedASubCategory = 'usctg';
  static const String deletedASubCategory = 'dsctg';

  static const String createdASaleUnit = 'csunt';
  static const String updatedASaleUnit = 'usunt';
  static const String deletedASaleUnit = 'dsunt';

  static const String createdAStock = 'cstk';
  static const String updatedAStock = 'ustk';
  static const String deletedAStock = 'dstk';

  static const String createdAPaymentMethod = 'cpym';
  static const String updatedAPaymentMethod = 'upym';
  static const String deletedAPaymentMethod = 'dpym';

  static const String createdAMonySafe = 'cmsf';
  static const String updatedAMonySafe = 'umsf';
  static const String deletedAMonySafe = 'dmsf';

  static const String createdSubscriper = 'csbcr';
  static const String updatedSubscriper = 'usbcr';
  static const String deletedSubscriper = 'dsbcr';

  static const String createdSubscription = 'csub';
  static const String updatedSubscription = 'usub';
  static const String deletedSubscription = 'dsub';

  static const String createdRank = 'crnk';
  static const String updatedRank = 'urnk';
  static const String deletedRank = 'drnk';

  static const String createdBatch = 'cbtch';
  static const String updatedBatch = 'ubtch';
  static const String deletedBatch = 'dbtch';

  static const String createdDepartment = 'cdprt';
  static const String updatedDepartment = 'udprt';
  static const String deletedDepartment = 'ddprt';

  static const String createdUser = 'cusr';
  static const String updatedUser = 'uusr';
  static const String deletedUser = 'dusr';

  // static const String createdA = 'ad';
  static const String endedAShift = 'eshft';
  static const String endedADay = 'edy';
}

  // static const String signin = 'in';
  // static const String signout = 'out';
  // static const String startedAShift = 'sshft';
  // static const String startedADay = 'sdy';
  // static const String createdABill = 'cb';
  // static const String updatedABill = 'ub';
  // static const String printedABill = 'pb';
  // static const String canceledABill = 'nb';
  // static const String returnedABill = 'tb';
  // static const String createdAReceipt = 'cr';
  // static const String returnedAReceipt = 'tr';
  // static const String canceledAReceipt = 'nr';
  // static const String updatedAReceipt = 'pr';
  // static const String printedAReceipt = 'pr';
  // static const String createdASupplier = 'cspl';
  // static const String updatedASupplier = 'uspl';
  // static const String deletedASupplier = 'dspl';
  // static const String createdACategory = 'cctg';
  // static const String updatedACategory = 'uctg';
  // static const String deletedACategory = 'dctg';
  // static const String createdASubCategory = 'csctg';
  // static const String updatedASubCategory = 'usctg';
  // static const String deletedASubCategory = 'dsctg';
  // static const String createdASaleUnit = 'csunt';
  // static const String updatedASaleUnit = 'usunt';
  // static const String deletedASaleUnit = 'dsunt';
  // static const String createdAStock = 'cstk';
  // static const String updatedAStock = 'ustk';
  // static const String deletedAStock = 'dstk';
  // static const String createdAPaymentMethod = 'cpym';
  // static const String updatedAPaymentMethod = 'upym';
  // static const String deletedAPaymentMethod = 'dpym';
  // static const String createdAMonySafe = 'cmsf';
  // static const String updatedAMonySafe = 'umsf';
  // static const String deletedAMonySafe = 'dmsf';
  // static const String endedAShift = 'eshft';
  // static const String endedADay = 'edy';