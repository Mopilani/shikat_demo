import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shikat/models/shik_model.dart';
import 'package:shikat/models/statement_model.dart';
import 'package:shikat/views/ornik_view.dart';
import 'package:shikat/widgets/button.dart';
import 'package:shikat/widgets/focusable_field.dart';

import '../spell_number.dart';

class ShikView extends StatefulWidget {
  const ShikView({
    super.key,
    this.shik,
    this.shikIndex,
  });
  final ShikModel? shik;
  final int? shikIndex;

  @override
  State<ShikView> createState() => _ShikViewState();
}

TextEditingController numberCont = TextEditingController(text: '');
// TextEditingController numberCont = TextEditingController(text: '100');
TextEditingController payeeNameCont = TextEditingController(text: '');
// TextEditingController payeeNameCont =
//     TextEditingController(text: 'عمر عبدالطيف عمر خالد محمدين احمد');
TextEditingController valueCont = TextEditingController(text: '');
// TextEditingController valueCont = TextEditingController(text: '999999999');
TextEditingController dateCont = TextEditingController(
    text:
        '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}');

class _ShikViewState extends State<ShikView> {
  bool shikNumberEntered = false;
  bool viewShikNumber = false;
  bool cashe = false;

  String valueToString = '';
  bool error = false;
  String? statement;
  List<StatementModel> statements = [];

  FocusNode numberNode = FocusNode();
  FocusNode payeeNameNode = FocusNode();
  FocusNode valueNode = FocusNode();
  FocusNode dateNode = FocusNode();

  bool checkNumber(text) {
    var value = int.tryParse(text);
    if (value == null) {
      var errorMsg = 'الرقم الذي ادخلته $text غير صحيح';
      toast(errorMsg);
      setState(() {
        valueToString = errorMsg;
        error = true;
      });
      return false;
    } else {
      setState(() {
        valueToString = '';
        error = false;
      });
    }
    return true;
  }

  @override
  void initState() {
    if (widget.shik != null) {
      numberCont.text = widget.shik!.number.toString();
      payeeNameCont.text = widget.shik!.payeeName;
      widget.shik!.value.toString().length >= 9
          ? valueCont.text = widget.shik!.value.toInt().toString()
          : valueCont.text = widget.shik!.value.toString();
      dateCont.text = widget.shik!.date;
      statement = widget.shik!.statement;
      viewShikNumber = widget.shik!.viewShikNumber;
      cashe = widget.shik!.cashe;
      shikNumberEntered = true;
    }
    dateCont = TextEditingController(
        text:
            '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}');
    getAwaiters();

    super.initState();
  }

  Future getAwaiters() async {
    var r = await StatementModel.getAll();
    statements.addAll(r);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shik != null ? 'تعديل الشيك' : 'عرض الشيك'),
      ),
      body: Center(
        child: !shikNumberEntered
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 450,
                        child: NFocusableField(
                          controller: numberCont,
                          node: numberNode,
                          labelTextWillBeTranslated: 'رقم الشيك',
                          onChanged: checkNumber,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: cashe,
                                  onChanged: (v) {
                                    if (v == null) {
                                      return;
                                    }
                                    setState(() {
                                      cashe = !cashe;
                                    });
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'نقدا ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: error ? Colors.red : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: viewShikNumber,
                                  onChanged: (v) {
                                    if (v == null) {
                                      return;
                                    }
                                    setState(() {
                                      viewShikNumber = !viewShikNumber;
                                    });
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'اظهار الرقم',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: error ? Colors.red : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        valueToString,
                        style: TextStyle(
                          fontSize: 32,
                          color: error ? Colors.red : null,
                        ),
                      ),
                      const SizedBox(height: 64),
                      PrimaryButton(
                        title: 'تم',
                        onPressed: () {
                          if (numberCont.text.isEmpty) {
                            toast('عليك كتابة رقم الشيك اولا');
                            return;
                          }
                          var r = checkNumber(numberCont.text);
                          if (!r) {
                            return;
                          }
                          valueToString = '';
                          setState(() {
                            shikNumberEntered = !shikNumberEntered;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 450,
                        child: NFocusableField(
                          prefix: const Text('السيد/'),
                          controller: payeeNameCont,
                          node: payeeNameNode,
                          labelTextWillBeTranslated: 'اسم المستفيد',
                          nextController: valueCont,
                          nextNode: valueNode,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 450,
                          height: 50,
                          child: DropdownButton<String>(
                            value: statement,
                            onChanged: (v) {},
                            items: statements
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.description,
                                    child: Text(e.description),
                                    onTap: () {
                                      setState(() {
                                        statement = e.description;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 450,
                        child: NFocusableField(
                          controller: valueCont,
                          node: valueNode,
                          labelTextWillBeTranslated: 'المبلغ',
                          maxLength: '100000000'.length,
                          onChanged: (text) {
                            var value = double.tryParse(text);
                            if (value == null) {
                              var errorMsg = 'الرقم الذي ادخلته $text غير صحيح';
                              toast(errorMsg);
                              setState(() {
                                valueToString = errorMsg;
                                error = true;
                              });
                              return false;
                            } else {
                              setState(() {
                                valueToString = '';
                                error = false;
                              });
                            }
                            // print(value);
                            setState(() {
                              valueToString =
                                  spellNum(value.toDouble(), 1, 'USD');
                            });
                          },
                          nextController: dateCont,
                          nextNode: dateNode,
                        ),
                      ),
                      Text(
                        valueToString,
                        style: TextStyle(
                          fontSize: 32,
                          color: error ? Colors.red : null,
                        ),
                      ),
                      SizedBox(
                        width: 450,
                        child: NFocusableField(
                          controller: dateCont,
                          node: dateNode,
                          labelTextWillBeTranslated: 'التاريخ',
                        ),
                      ),
                      const SizedBox(height: 64),
                      PrimaryButton(
                        title: 'حفظ',
                        onPressed: save,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        title: 'اعادة كتابة الرقم',
                        onPressed: () {
                          setState(() {
                            shikNumberEntered = !shikNumberEntered;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void save() async {
    var number = int.tryParse(numberCont.text);
    if (number == null) {
      toast('تأكد من كتابتك لرقم الشيك بصورة صحيحة');
      return;
    }
    var value = double.tryParse(valueCont.text);
    if (value == null) {
      toast('تأكد من كتابتك لمبلغ الشيك بصورة صحيحة');
      return;
    }
    if (widget.shik != null) {
      await ornik!.removeShik(widget.shikIndex!);
    }
    if (statement == null) {
      // await ornik!.removeShik(widget.shikIndex!);
      toast('عليك تحديد البند اولا');
      return;
    }

    var model = ShikModel(
      0,
      number: number,
      payeeName: payeeNameCont.text,
      value: value,
      date: dateCont.text,
      viewShikNumber: viewShikNumber,
      cashe: cashe,
      statement: statement!,
    );

    await ornik!.addShik(model);
    // print(ornik!.shiks);
    Get.back();
    // await model.add().then((_) {
    // });
  }
}
