import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shikat/models/ornik_model.dart';
import 'package:shikat/models/processes_model.dart';
import 'package:shikat/onrik_report_view.dart';
import 'package:shikat/shik_print_view.dart';
import 'package:shikat/views/reports_view.dart';
import 'package:shikat/views/shik_view.dart';
import 'package:shikat/widgets/button.dart';
import 'package:shikat/widgets/focusable_field.dart';

class OrnikView extends StatefulWidget {
  const OrnikView({
    super.key,
    this.ornik,
    this.ornikIndex,
  });
  final OrnikModel? ornik;
  final int? ornikIndex;

  @override
  State<OrnikView> createState() => _OrnikViewState();
}

OrnikModel? ornik;
bool ornikNumberRequested = false;
TextEditingController ornikPayeeNameCont = TextEditingController(text: '');

class _OrnikViewState extends State<OrnikView> {
  @override
  void initState() {
    super.initState();
    if (widget.ornik != null) {
      ornik = widget.ornik;
      ornikPayeeNameCont.text = widget.ornik?.payeeName ?? '';
      ornikNumberRequested = true;
    }
  }

  FocusNode ornikPayeeNameNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض الاورنيك ${ornik?.number ?? ''}'),
      ),
      body: FutureBuilder(future: () async {
        if (ornikNumberRequested) return;
        var number = await ProcessesModel.stored!.requestOrnikNumber();
        // print(number);
        ornik = OrnikModel(
          number,
          number: number,
          shiks: [],
        );
        await ornik!.add();
        ornikNumberRequested = true;
        Future.delayed(const Duration(milliseconds: 50), () {
          setState(() {});
        });
      }(), builder: (context, snapshot) {
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'الشيكات',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ornik?.shiks.isEmpty ?? true
                        ? const Center(
                            child: Text(
                              'لا يوجد',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: ornik?.shiks.length ?? 0,
                            itemBuilder: (context, index) {
                              // print(ornik!.shiks);
                              var shik = ornik!.shiks.toList()[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'رقم: ${shik.number}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Row(
                                            children: [
                                              const Text(
                                                'المبلغ: ',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                numberFormater(shik.value),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.print),
                                            iconSize: 40,
                                            onPressed: () {
                                              Get.to(() =>
                                                  ShikPrintView(shik: shik));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            iconSize: 40,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShikView(
                                                    shik: shik,
                                                    shikIndex: index,
                                                  ),
                                                ),
                                              ).then(
                                                  (value) => setState(() {}));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            iconSize: 40,
                                            onPressed: () async {
                                              await ornik!.removeShik(index);
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 450,
                    child: NFocusableField(
                      prefix: const Text('السيد/'),
                      controller: ornikPayeeNameCont,
                      node: ornikPayeeNameNode,
                      labelTextWillBeTranslated: 'اسم المستفيد',
                      suffix: IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          ornik!.payeeName = ornikPayeeNameCont.text;
                          await ornik!.edit();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    title: 'كتابة شيك',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShikView(),
                        ),
                      ).then((value) => setState(() {}));
                    },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    title: 'طباعة الاورنيك',
                    onPressed: ornik == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrnikPrintView(ornik: ornik!),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    title: 'انهاء',
                    onPressed: ornik == null
                        ? null
                        : () async {
                            ornik = null;
                            ornikNumberRequested = false;
                            numberCont.clear();
                            payeeNameCont.clear();
                            ornikPayeeNameCont.clear();
                            valueCont.clear();
                            dateCont.clear();
                            Get.back();
                          },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    title: 'حذف',
                    color: Colors.red,
                    onPressed: ornik == null
                        ? null
                        : () async {
                            try {
                              await ornik!.deleteWithMID();
                            } catch (e) {
                              await ornik!.delete();
                              //
                            }
                            ornik = null;
                            ornikNumberRequested = false;
                            Get.back();
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
