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
import 'package:shikat/models/shik_model.dart';
import 'package:shikat/models/system_config.dart';
import 'package:shikat/spell_number.dart';
import 'package:shikat/views/reports_view.dart';
import 'package:updater/updater.dart' as updater;

class OrnikPrintView extends StatefulWidget {
  const OrnikPrintView({
    Key? key,
    required this.ornik,
  }) : super(key: key);
  final OrnikModel ornik;

  @override
  State<OrnikPrintView> createState() => _OrnikPrintViewState();
}

class _OrnikPrintViewState extends State<OrnikPrintView> {
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
        stdout.writeln(process.stdout);
        stdout.writeln(process.stderr.runtimeType);
      } catch (e) {
        stdout.writeln(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
                                stdout.writeln(
                                    'Done Successfully, Save To ${outputFile.path}');
                                toast(
                                  'Done Successfully, Save To ${outputFile.path}',
                                );
                              },
                              onError: (e) {
                                stdout.writeln(e);
                                toast(
                                  e.toString(),
                                );
                              },
                            );
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
// late PageController uniPageCont = PageController();
// late Widget _invoiceWidget;
List<Uint8List> imagesData = [];
bool editMode = false;
GlobalKey? pageKey;

class Invoice extends StatefulWidget {
  const Invoice({
    Key? key,
    required this.ornik,
    required this.renderRepaintBoundaryKey,
  }) : super(key: key);
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
    getAwaiters();
  }

  Future getAwaiters() async {}

  @override
  Widget build(BuildContext context) {
    try {
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
                        const SizedBox(height: 4),
                        const Text(
                          'بسم ألله ألرحمن ألرحيم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'arial',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'وزارة ألداخلية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'رئاسة قوات ألشرطة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ألإدارة ألعامة للشرطة ألمجتمعية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Text(
                              'اورنيك حسابات مالي نمرة ( 17 )',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
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
                                  '.الوحدة: ألإدارة ألعامة للشرطة ألمجتمعية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '............................................................................................................'
                                  ' /المدفوع له: السيد',
                                  // '${widget.ornik.payeeName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '.${DateTime.now().year}' ' :السنة المالية',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '........................................ '
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
                          columnWidths: const {
                            0: FixedColumnWidth(150),
                            2: FixedColumnWidth(100),
                          },
                          border: TableBorder.symmetric(
                            outside: const BorderSide(width: 1),
                          ),
                          children: [
                            TableRow(
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
                                ShikModel shik;
                                try {
                                  shik = widget.ornik.shiks[index];
                                  shiks.add(
                                    TableRow(
                                      children: [
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
                                                    numberFormater(shik.value),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                } catch (e) {
                                  shiks.add(
                                    TableRow(
                                      children: [
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              // height: 100,
                              width: 500,
                              child: Text(
                                // ' ..........................................................................................................'
                                'صافي المبلغ كتابة: ${spellNum(widget.ornik.value ?? 0, 1, 'USD')}.',
                                // ' :صافي المبلغ كتابة',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              '................................................................................................................'
                              ' :تتابع بواسطة',
                              style: TextStyle(
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
                                    'أشهد بان المبلغ مستحق وأنه صحيح فيما يتعلق بالتضريب والجمع وفئات الدفع والقيام بالخدمات المطلوبة على الوجه الاكمل وعليه فأني اطلب دفع المبلغ المذكور أعلاه.',
                                    // textAlign: TextAlign.end,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                Row(
                                  children: const [
                                    Text(
                                      '.......................................................'
                                      ' :توقيع ثاني',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '.الموظف المسئول عن مراجعة الحساب',
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
                            fontFamily: 'cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.ornik.shiks.isNotEmpty)
                              Text(
                                '${widget.ornik.shiks.first.number}'
                                ' :دفع شيك رقم',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(width: 16),
                            const Text(
                              '.......................................................'
                              ' :توقيع أول',
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
                            Text(
                              '${DateTime.now().year} /......./......./'
                              'التاريخ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '................................................................'
                              ' :الموظف المسؤول',
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
                                      ' :التاريخ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '........................'
                                      ' :التوقيع',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '.............................................'
                                      ' :اسم المستلم',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '..................................................................................................................'
                                  ' :رقم الاستمارة',
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
      stdout.writeln(E);
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

// class TestThePain extends StatelessWidget {
//   const TestThePain({Key? key, required this.child}) : super(key: key);
//   final Widget child;
//   @override
//   Widget build(BuildContext context) {
//     return child;
//   }
// }

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

// Text(
//                           SystemNodeModel.stored!.placeName!,
//                           style: TextStyle(
//                             fontSize: 20 * multiplier,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: fontFamily,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'تقرير عام للمشترك',
//                           style: TextStyle(
//                             fontSize: 14 * multiplier,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: fontFamily,
//                           ),
//                         ),
//                         // const SizedBox(height: 14),
//                         // SizedBox(height: 14 * multiplier),
//                         const Divider(),
//                         SizedBox(height: 14 * multiplier),
//                         Text(
//                           "تحريرا في: ${dateToString(DateTime.now(), '/')}",
//                           style: TextStyle(
//                             fontSize: 12 * multiplier,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: fontFamily,
//                           ),
//                         ),
//                         const SizedBox(height: 14),

//                         SizedBox(height: 14 * multiplier),
//                         Table(
//                           border: const TableBorder(
//                             horizontalInside: BorderSide(),
//                             verticalInside: BorderSide(),
//                             bottom: BorderSide(),
//                             top: BorderSide(),
//                             left: BorderSide(),
//                             right: BorderSide(),
//                           ),
//                           children: [
//                             TableRow(
//                               children: [
//                                 SizedBox(
//                                   width: 100,
//                                   child: Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(2, 4, 2, 4),
//                                     child: Text(
//                                       'الشهر',
//                                       style: TextStyle(
//                                         fontSize: 12 * multiplier,
//                                         fontFamily: fontFamily,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(2, 4, 2, 4),
//                                   child: Text(
//                                     'تاريخ السداد',
//                                     style: TextStyle(
//                                       fontSize: 12 * multiplier,
//                                       fontFamily: fontFamily,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(2, 4, 2, 4),
//                                   child: Text(
//                                     'القيمة',
//                                     style: TextStyle(
//                                       fontSize: 12 * multiplier,
//                                       fontFamily: fontFamily,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(2, 4, 2, 4),
//                                   child: Text(
//                                     'المدفوع',
//                                     style: TextStyle(
//                                       fontSize: 12 * multiplier,
//                                       fontFamily: fontFamily,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // ...subs.entries.map((entry) {
//                             //   return TableRow(
//                             //     children: [
//                             //       SizedBox(
//                             //         width: 100,
//                             //         child: Padding(
//                             //           padding:
//                             //               const EdgeInsets.fromLTRB(0, 2, 2, 2),
//                             //           child: Text(
//                             //             (entry.value.id.split('.').last)
//                             //                 .toString(),
//                             //             style: TextStyle(
//                             //               fontSize: 12 * multiplier,
//                             //               fontFamily: fontFamily,
//                             //             ),
//                             //           ),
//                             //         ),
//                             //       ),
//                             //       Padding(
//                             //         padding:
//                             //             const EdgeInsets.fromLTRB(0, 2, 2, 2),
//                             //         child: Text(
//                             //           (dateToString(entry.value.time))
//                             //               .toString(),
//                             //           style: TextStyle(
//                             //             fontSize: 12 * multiplier,
//                             //             fontFamily: fontFamily,
//                             //           ),
//                             //         ),
//                             //       ),
//                             //       Padding(
//                             //         padding:
//                             //             const EdgeInsets.fromLTRB(0, 2, 2, 2),
//                             //         child: Text(
//                             //           (entry.value.value).toString(),
//                             //           style: TextStyle(
//                             //             fontSize: 12 * multiplier,
//                             //             fontFamily: fontFamily,
//                             //           ),
//                             //         ),
//                             //       ),
//                             //       Padding(
//                             //         padding:
//                             //             const EdgeInsets.fromLTRB(0, 2, 2, 2),
//                             //         child: Text(
//                             //           (entry.value.payed).toString(),
//                             //           style: TextStyle(
//                             //             fontSize: 12 * multiplier,
//                             //             fontFamily: fontFamily,
//                             //           ),
//                             //         ),
//                             //       ),
//                             //     ],
//                             //   );
//                             // }).toList()
//                           ],
//                         ),
