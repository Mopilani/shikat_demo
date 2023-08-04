import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdfx/pdfx.dart';
import 'package:shikat/models/ornik_model.dart';
import 'package:shikat/models/system_config.dart';
import 'package:shikat/spell_number.dart';
import 'package:updater/updater.dart' as updater;

class KhetabView extends StatefulWidget {
  const KhetabView({
    Key? key,
    required this.ornik,
  }) : super(key: key);
  final OrnikModel ornik;

  @override
  State<KhetabView> createState() => _KhetabViewState();
}

class _KhetabViewState extends State<KhetabView> {
  @override
  void initState() {
    super.initState();
    // getAwaiters();
  }

  late PdfController pdfController;

  int currentIndex = 0;
  double zoom = 100.0;
  bool wasInitialized = false;
  bool pdfIsReady = false;
  // DepartmentModel? selectedDepartment;

  @override
  void dispose() {
    super.dispose();
    imagesData.clear();
  }

  PageController pageController = PageController();

  static Completer? completer = Completer();
  Widget? wgt;

  Future<void> printPages() async {
    String path = 'BITSYSTEM/${DateTime.now().millisecondsSinceEpoch}.png';
    var outputFile = File(path);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final rrb =
          pageKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final imgData = await rrb.toImage(pixelRatio: 3.0);
      final byteData =
          await (imgData.toByteData(format: ui.ImageByteFormat.png));

      final pngBytes = byteData!.buffer.asUint8List();
      if (!outputFile.existsSync()) outputFile.createSync(recursive: true);
      outputFile.writeAsBytesSync(pngBytes);
      try {
        final process = await Process.run('printing/raw_print_helper.exe', [
          'print',
          // 'HP LaserJet Professional P1109w',
          // // 'Microsoft Print To PDF',
          SystemConfig.stored!.printer,
          path,
        ]);
        print(process.stdout);
        print(process.stderr.runtimeType);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 400,
            //   child: updater.UpdaterBlocWithoutDisposer(
            //     updater: ThisPageUpdater(
            //       init: '',
            //       updateForCurrentEvent: true,
            //     ),
            //     update: (context, s) {
            //       return DropdownButton<DepartmentModel>(
            //         items: departments.map((e) {
            //           return DropdownMenuItem<DepartmentModel>(
            //             value: e,
            //             child: Text(e.description),
            //             onTap: () {
            //               selectedDepartment = e;
            //               ThisPageUpdater().add(0);
            //             },
            //           );
            //         }).toList(),
            //         value: () {
            //           if (selectedDepartment == null) {
            //             return null;
            //           }
            //           for (var element in departments) {
            //             if (selectedDepartment!.description ==
            //                 element.description) {
            //               return element;
            //             }
            //           }
            //         }(),
            //         onChanged: (value) {},
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
        actions: [
          updater.UpdaterBloc(
            updater: AppBarUpdater(
              initialState: 0,
              updateForCurrentEvent: true,
            ),
            update: (context, snapshot) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () async {
                      await printPages();
                      // for (var i = 0; i < pagesCount; i++) {
                      //   print('Pge $i');
                      //   uniPageCont.jumpToPage(i);
                      //   await Future.delayed(const Duration(seconds: 3));
                      //   // print(pagesKyes);
                      //   await Future.delayed(const Duration(seconds: 3));
                      // }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: pagesCount > 1
                        ? null
                        : () async {
                            var outputFile = File(
                              'BITSYSTEM/${DateTime.now().millisecondsSinceEpoch}.png',
                            );
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              final rrb = pageKey!.currentContext!
                                  .findRenderObject() as RenderRepaintBoundary;
                              final imgData =
                                  await rrb.toImage(pixelRatio: 2.0);
                              final byteData = await (imgData.toByteData(
                                  format: ui.ImageByteFormat.png));

                              final pngBytes = byteData!.buffer.asUint8List();
                              outputFile.writeAsBytesSync(pngBytes);
                            });

                            InvoicePageUpdater().add(0);
                            await completer!.future.then(
                              (value) {
                                print(
                                    'Done Successfully, Save To ${outputFile.path}');
                                toast(
                                  'Done Successfully, Save To ${outputFile.path}',
                                );
                              },
                              onError: (e) {
                                print(e);
                                toast(
                                  e.toString(),
                                );
                              },
                            );
                          },
                  ),
                  IconButton(
                    icon: editMode
                        ? const Icon(Icons.close)
                        : const Icon(Icons.edit),
                    onPressed: () {
                      editMode = !editMode;
                      PainterUpdater().add('');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: () {
                      // uniPageCont.animateToPage(
                      //     currentIndex,
                      //     duration: const Duration(milliseconds: 200),
                      //     curve: Curves.ease,
                      //   );
                      // try {
                      //   pagesCount = uniPageCont.pagesCount!;
                      // } catch (e) {
                      //   pagesCount = imagesData.length;
                      // }
                      if (currentIndex > 0) {
                        currentIndex--;
                      }
                      try {
                        uniPageCont.animateToPage(
                          currentIndex,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      } catch (e) {
                        pageController.animateToPage(
                          currentIndex,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      }
                      AppBarUpdater().add('');
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    child: Text('${imagesData.length} - ${currentIndex + 1}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: () {
                      print(pagesCount);
                      // try {
                      //   pagesCount = uniPageCont.pagesCount!;
                      // } catch (e) {
                      //   pagesCount = imagesData.length;
                      // }
                      if (currentIndex < (pagesCount - 1)) {
                        currentIndex++;
                      }
                      try {
                        uniPageCont.animateToPage(
                          currentIndex,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      } catch (e) {
                        pageController.animateToPage(
                          currentIndex,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      }
                      AppBarUpdater().add('');
                    },
                  ),
                  const SizedBox(width: 32),
                ],
              );
            },
          ),
        ],
      ),
      body: updater.UpdaterBloc(
        updater: InvoiceBodyUpdater(
          initialState: 'thereIsMore',
          updateForCurrentEvent: true,
        ),
        update: (context, snapshot) {
          if (snapshot.hasData) {}
          pageKey = GlobalKey();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Center(
              child: SingleChildScrollView(
                child: Invoice(
                  renderRepaintBoundaryKey: pageKey!,
                  ornik: widget.ornik,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

int pagesCount = 0;
late PageController uniPageCont = PageController();
late Widget _invoiceWidget;
List<Uint8List> imagesData = [];
bool editMode = false;
GlobalKey? pageKey;

class Invoice extends StatefulWidget {
  Invoice({
    Key? key,
    required this.ornik,
    // required this.startIndex,
    required this.renderRepaintBoundaryKey,
  }) : super(key: key);
  // final SubscriperModel subscriper;
  // final int startIndex;
  final GlobalKey renderRepaintBoundaryKey;
  final OrnikModel ornik;

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  bool takeScreenShot = false;
  bool takeingScreenShot = false;
  final double multiplier = 1.1;

  bool pageDone = false;
  bool allDone = false;

  int currnentPageIndex = 0;
  int lastIndex = 0;

  Widget? validWid;

  int currentIndex = 0;
  // int payedMonthsNumber = 0;

  double reminingHeightSpace = 0;

  List<TableRow> oldRows = [];
  List<Map> pagesData = [
    {
      'first': true,
      'last': false,
    }
  ];

  @override
  void initState() {
    super.initState();
    // getAwaiters();
  }

  // Future getAwaiters() async {
  //   int inc = 0;
  //   int max = 16;
  //   // print(inc);
  //   // print(widget.subscriper.subs.length);
  //   // for (var i = widget.startIndex; i < widget.subscriper.subs.length; i++) {
  //   //   // print(i);
  //   //   var subData = widget.subscriper.subs[i];
  //   //   if (inc >= max) return;
  //   //   var sub = await SubscriptionModel.get(subData.id);
  //   //   if (sub != null) {
  //   //     // Navigator.pop(context);

  //   //     subs.addAll({sub.id: sub});
  //   //   }
  //   //   PainterUpdater().add(0);
  //   //   inc++;
  //   // }
  // }

  // Map<String, SubscriptionModel> subs = {};

  @override
  Widget build(BuildContext context) {
    try {
      // if (loadedPages.containsKey(widget.startIndex)) {
      //   return loadedPages[widget.startIndex]!;
      // } else {
      return updater.UpdaterBlocWithoutDisposer(
        updater: PainterUpdater(
          initialState: '',
          updateForCurrentEvent: true,
        ),
        update: (context, state) {
          if (takeScreenShot) {
            takeScreenShot = false;
            takeingScreenShot = true;
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              final rrb = widget.renderRepaintBoundaryKey.currentContext!
                  .findRenderObject() as RenderRepaintBoundary;
              final imgData = await rrb.toImage(pixelRatio: 1.0);
              final byteData =
                  await (imgData.toByteData(format: ui.ImageByteFormat.png));

              imagesData.add(byteData!.buffer.asUint8List());

              InvoiceBodyUpdater().add('');
              AppBarUpdater().add('');
              pageDone = false;
              takeingScreenShot = false;
              Future.delayed(const Duration(milliseconds: 5), () {
                PainterUpdater().add('');
              });
            });
          }

          return RepaintBoundary(
            key: widget.renderRepaintBoundaryKey,
            child: SizedBox(
              height: pdf.PdfPageFormat.a4.height * multiplier,
              width: pdf.PdfPageFormat.a4.width * multiplier,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: SizedBox(
                  height: pdf.PdfPageFormat.a4.height * multiplier,
                  width: pdf.PdfPageFormat.a4.width * multiplier,
                  child: Padding(
                    padding: EdgeInsets.all(
                        pdf.PdfPageFormat.a3.marginRight * multiplier),
                    child: Column(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'بسم الله الرحمن الرحيم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'وزارة الداخلية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'رئاسة قوات الشرطة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'الادارة العامة للشرطة المجتمعية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'اورنيك حسابات مالي نمرة ( 17 )',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '(                       ) الرقم المتسلسل',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'الوحدة: الادارة العامة للشرطة المجتمعية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '........................................................................................'
                                  ' /المدفوع له: السيد',
                                  // '${widget.ornik.payeeName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${DateTime.now().year}' ' :السنة المالية',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '................................. '
                                  ' :بالخصم على',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Table(
                          // border: const TableBorder(
                          //   bottom: BorderSide(),
                          //   left: BorderSide(),
                          //   top: BorderSide(),
                          //   right: BorderSide(),
                          // ),
                          columnWidths: {
                            // 0: FixedColumnWidth(100),
                            0: FixedColumnWidth(150),
                            // 1: FixedColumnWidth(100),
                            2: FixedColumnWidth(100),
                            // 3: FixedColumnWidth(50),
                            // 2: const FixedColumnWidth(100),
                            // 4: FixedColumnWidth(180),
                            // 5: FixedColumnWidth(35),
                            // 0: IntrinsicColumnWidth(flex: 2),
                          },
                          // textDirection: ui.TextDirection.rtl,
                          border: TableBorder.symmetric(
                            // inside: const BorderSide(width: 1),
                            outside: const BorderSide(width: 1),
                          ),
                          children: [
                            TableRow(
                              // decoration: BoxDecoration(
                              //   border:
                              //   sh
                              // ),,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(),
                                            left: BorderSide(),
                                            right: BorderSide(),
                                            top: BorderSide(),
                                          ),
                                          color: Colors.black12,
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 4, 4, 4),
                                          child: Text(
                                            'جنيه سوداني',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: const [
                                //     Padding(
                                //       padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                //       child: Text('قرش'),
                                //     ),
                                //   ],
                                // ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: const [
                                //     Padding(
                                //       padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                //       child: Text('جنيه'),
                                //     ),
                                //   ],
                                // ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: const [
                                //     Padding(
                                //       padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                //       child: Text('قرش'),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(),
                                            left: BorderSide(),
                                            right: BorderSide(),
                                            top: BorderSide(),
                                          ),
                                          color: Colors.black12,
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 4, 4, 4),
                                          child: Text(
                                            'البيان',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(),
                                            left: BorderSide(),
                                            right: BorderSide(),
                                            top: BorderSide(),
                                          ),
                                          color: Colors.black12,
                                        ),
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 4, 4, 4),
                                          child: Text(
                                            'رقم المستند',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ...() {
                              // int count = 0;
                              // count++;
                              var shiks = [];

                              for (var index = 0; 5 > index; index++) {
                                var shik;
                                try {
                                  shik = widget.ornik.shiks[index];
                                  shiks.add(
                                    TableRow(
                                      children: [
                                        // const Text(''),
                                        // const Text(''),
                                        // Text(shik.value.toString()),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(),
                                                    left: BorderSide(),
                                                    right: BorderSide(),
                                                    top: BorderSide(),
                                                  ),
                                                  color: Colors.black12,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          4, 0, 4, 0),
                                                  child: Text(
                                                      shik.value.toString()),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // const Text(''),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  4, 0, 4, 0),
                                              child: Text(
                                                  '.....................................................................................'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(),
                                                    left: BorderSide(),
                                                    right: BorderSide(),
                                                    top: BorderSide(),
                                                  ),
                                                  color: Colors.black12,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          4, 0, 4, 0),
                                                  child: Text(''),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  shiks.add(
                                    TableRow(
                                      children: [
                                        // const Text(''),
                                        // const Text(''),
                                        // Text(shik.value.toString()),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(),
                                                    left: BorderSide(),
                                                    right: BorderSide(),
                                                    top: BorderSide(),
                                                  ),
                                                  color: Colors.black12,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4, 0, 4, 0),
                                                  child: Text(''),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // const Text(''),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  4, 0, 4, 0),
                                              child: Text(
                                                  '.....................................................................................'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(),
                                                    left: BorderSide(),
                                                    right: BorderSide(),
                                                    top: BorderSide(),
                                                  ),
                                                  color: Colors.black12,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4, 0, 4, 0),
                                                  child: Text(''),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                              return shiks;
                            }(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              // ' ..........................................................................................................'
                              'صافي المبلغ كتابة: ${spellNum(widget.ornik.value!, 1, 'USD')}',
                              // ' :صافي المبلغ كتابة',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              '................................................................................................'
                              ' تتابع بواسطة',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 8),
                        // const Text(
                        //   'تصديق بالدفع',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 60,
                                  width: 500,
                                  child: Text(
                                    'أشهد بان المبلغ مستحق وأنه صحيح فيما يتعلق بالتضريب والجمع وفئات الدفع والقيام بالخدمات المطلوبة على الوجه الاكمل وعليه فأني اطلب دفع المبلغ المذكور أعلاه',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '.......................................................'
                                      'توقيع ثاني',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  ' الموظف المسئول عن مراجعة الحساب',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تصدق بالدفع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.ornik.shiks.first.number}'
                              ' :دفع شيك رقم',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '.......................................................'
                              'توقيع أول',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${DateTime.now().year} /......./......./'
                              'التاريخ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '...............................................................'
                              'الموظف المسؤول ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // const     Text(
                                //         '.........................................'
                                //         ' '),
                                Row(
                                  children: const [
                                    Text(
                                      '...................'
                                      'التاريخ ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '...........................'
                                      'التوقيع ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '..............................................'
                                      'اسم المستلم',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '.....................................................................................................'
                                  'رقم الاستمارة ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      // loadedPages.addAll({widget.startIndex: widg});
      // return widg;
      // }
    } catch (E) {
      print(E);
      return const CircularProgressIndicator();
    }
  }

  Widget testColumn() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(itemBuilder: (context, index) {
              return Text('$index');
            }),
          ),
          // Card(
          //   color: Colors.black,
          // ),
        ],
      ),
    );
  }

  Widget wid53(String title, [bool weight = false, int flex = 1]) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.black26,
          border: Border(
            top: BorderSide(color: Colors.black45),
            bottom: BorderSide(color: Colors.black45),
            right: BorderSide(color: Colors.black45),
            left: BorderSide(color: Colors.black45),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: weight ? FontWeight.bold : null,
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String fontFamily = 'cairo';
}

class InvoiceBodyUpdater extends updater.Updater {
  InvoiceBodyUpdater({
    initialState,
    bool updateForCurrentEvent = false,
  }) : super(initialState, updateForCurrentEvent: updateForCurrentEvent);
}

class InvoicePageUpdater extends updater.Updater {
  InvoicePageUpdater({
    initialState,
    bool updateForCurrentEvent = false,
  }) : super(initialState, updateForCurrentEvent: updateForCurrentEvent);
}

class AppBarUpdater extends updater.Updater {
  AppBarUpdater({
    initialState,
    bool updateForCurrentEvent = false,
  }) : super(initialState, updateForCurrentEvent: updateForCurrentEvent);
}

class PainterUpdater extends updater.Updater {
  PainterUpdater({
    initialState,
    bool updateForCurrentEvent = false,
  }) : super(initialState, updateForCurrentEvent: updateForCurrentEvent);
}

class ThisPageUpdater extends updater.Updater {
  ThisPageUpdater({
    init,
    bool updateForCurrentEvent = false,
  }) : super(init, updateForCurrentEvent: updateForCurrentEvent);
}