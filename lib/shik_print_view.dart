import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdfx/pdfx.dart';
import 'package:shikat/models/shik_model.dart';
import 'package:shikat/models/system_config.dart';
import 'package:shikat/spell_number.dart';
import 'package:shikat/views/reports_view.dart';
import 'package:shikat/widgets/focusable_field.dart';
import 'package:updater/updater.dart' as updater;

class ShikPrintView extends StatefulWidget {
  const ShikPrintView({
    Key? key,
    required this.shik,
  }) : super(key: key);
  final ShikModel shik;

  @override
  State<ShikPrintView> createState() => _ShikPrintViewState();
}

class _ShikPrintViewState extends State<ShikPrintView> {
  @override
  void initState() {
    super.initState();
    try {
      var paddings = json.decode(SystemConfig.stored!.paddings!);
      allPadBottom = paddings['allPadBottom'];
      allPadBottomCont.text = allPadBottom.toString();
      allPadRight = paddings['allPadRight'];
      allPadRightCont.text = allPadRight.toString();
      allPadLeft = paddings['allPadLeft'];
      allPadLeftCont.text = allPadLeft.toString();
    } catch (e) {
      stdout.writeln(e);
    }
  }

  late PdfController pdfController;

  int currentIndex = 0;
  double zoom = 100.0;
  bool wasInitialized = false;
  bool pdfIsReady = false;
  bool khetabView = false;

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
          // 'Microsoft Print To PDF',
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
          children: const [],
        ),
        backgroundColor: Colors.red,
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
                    icon: const Icon(Icons.request_page),
                    onPressed: !widget.shik.cashe
                        ? null
                        : () async {
                            setState(() {
                              khetabView = !khetabView;
                            });
                          },
                  ),
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
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      var paddings = {
                        'allPadBottom': allPadBottom,
                        'allPadRight': allPadRight,
                        'allPadLeft': allPadLeft,
                      };
                      SystemConfig.stored!.paddings = json.encode(paddings);
                    },
                  ),
                  SizedBox(
                    width: 100,
                    child: NFocusableField(
                      controller: allPadBottomCont,
                      node: allPadBottomNode,
                      labelTextWillBeTranslated: 'تحت',
                      onChanged: (text) {
                        var r = double.tryParse(text);
                        if (r != null) {
                          allPadBottom = r;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: NFocusableField(
                      controller: allPadLeftCont,
                      node: allPadLeftNode,
                      labelTextWillBeTranslated: 'يسار',
                      onChanged: (text) {
                        var r = double.tryParse(text);
                        if (r != null) {
                          allPadLeft = r;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: NFocusableField(
                      controller: allPadRightCont,
                      node: allPadRightNode,
                      labelTextWillBeTranslated: 'يمين',
                      onChanged: (text) {
                        var r = double.tryParse(text);
                        if (r != null) {
                          allPadRight = r;
                          setState(() {});
                        }
                      },
                    ),
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
                child: khetabView
                    ? KhetabInvoice(
                        renderRepaintBoundaryKey: pageKey!,
                        shik: widget.shik,
                      )
                    : Stack(
                        children: [
                          Invoice(
                            renderRepaintBoundaryKey: pageKey!,
                            shik: widget.shik,
                          ),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.black,
                            child: SizedBox(
                              height: pdf.PdfPageFormat.a4.height * 1.1,
                              width: pdf.PdfPageFormat.a4.height * 1.1,
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RotatedBox(
                                    quarterTurns: 3,
                                    child: Invoice(
                                      renderRepaintBoundaryKey: GlobalKey(),
                                      shik: widget.shik,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
PageController uniPageCont = PageController();

// ignore: must_be_immutable
class KhetabInvoice extends StatefulWidget {
  KhetabInvoice({
    Key? key,
    required this.shik,
    required this.renderRepaintBoundaryKey,
  }) : super(key: key);
  final GlobalKey renderRepaintBoundaryKey;
  final ShikModel shik;

  @override
  State<KhetabInvoice> createState() => _KhetabInvoiceState();
}

class _KhetabInvoiceState extends State<KhetabInvoice> {
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
                        const Text(
                          'بسم ألله ألرحمن ألرحيم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'arial',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'جمهورية ألسودان',
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
                        const SizedBox(height: 32),
                        const Divider(),
                        const Text(
                          'ألإدارة ألعامة للشئون ألمالية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(),
                              left: BorderSide(),
                              right: BorderSide(),
                              top: BorderSide(),
                            ),
                            // color: Colors.black12,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ألتاريخ : ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '------------------------------ ألنمرة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'ألسيد / وكيل بنك ألسودان',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ألسلام عليكم ورحمة ألله وبركاته',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ألموضوع شيك نقدا',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 64),
                        SizedBox(
                          height: 100,
                          child: Text(
                            '''
    ألرجاء ألتكرم بصرف ألشيك رقم ${widget.shik.number} بتاريخ ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} بمبلغ وقدره ${numberFormater(widget.shik.value)} (${spellNum(widget.shik.value, 1, 'USD')}) عبارة عن قيمة ألامر ألمستلم للشرطة ألمجتمعية باسم / ألصراف / ${widget.shik.payeeName} ولكم فائق ألشكر وألتقدير.''',
                            textDirection: ui.TextDirection.rtl,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 64),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '...............................................',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ':توقيع اول ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '...............................................',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ':توقيع ثاني ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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

// bool imageReady = false;
List<Uint8List> imagesData = [];
bool editMode = false;
// Map<int, Widget> loadedPages = {};
GlobalKey? pageKey;

// ignore: must_be_immutable
class Invoice extends StatefulWidget {
  Invoice({
    Key? key,
    required this.shik,
    // required this.startIndex,
    required this.renderRepaintBoundaryKey,
  }) : super(key: key);
  // final SubscriperModel subscriper;
  // final int startIndex;
  final GlobalKey renderRepaintBoundaryKey;
  final ShikModel shik;

  @override
  State<Invoice> createState() => _InvoiceState();
}

TextEditingController allPadBottomCont = TextEditingController(text: '0.0');
TextEditingController allPadLeftCont = TextEditingController(text: '0.0');
TextEditingController allPadRightCont = TextEditingController(text: '0.0');
double allPadBottom = 105;
FocusNode allPadBottomNode = FocusNode();
double allPadLeft = 0;
FocusNode allPadLeftNode = FocusNode();
double allPadRight = 0;
FocusNode allPadRightNode = FocusNode();

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
                    padding: EdgeInsets.only(
                      left: pdf.PdfPageFormat.a3.marginRight * multiplier,
                      right: pdf.PdfPageFormat.a3.marginRight * multiplier,
                    ),
                    // padding: EdgeInsets.all(
                    //     pdf.PdfPageFormat.a3.marginRight * multiplier),
                    child: Stack(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        // const Opacity(
                        //   opacity: 0.2,
                        //   child: Text(
                        //       '0000000000000000 22222222222222222222222222222222222 0000000000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000010000000100 11111111111111111111111111111111111 0000100000000000\n'
                        //       '0000000000000000 11111111111111111111111111111111111 0000000000000000\n'
                        //       '0000000000000000 11111111111111111111111111111111111 0000000000000000\n'
                        //       '0000000000000000 11111111111111111111111111111111111 0000000000000000\n'
                        //       '0000000000000000 22222222222222222222222222222222222 0000000000000000\n'),
                        // ),
                        if (widget.shik.viewShikNumber)
                          Positioned(
                            right: allPadRight.toDouble() + 130,
                            left: allPadLeft,
                            bottom: allPadBottom + 320,
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(widget.shik.number.toString()),
                            ),
                          ),
                        if (widget.shik.viewShikNumber)
                          Positioned(
                            right: allPadRight.toDouble() + 145,
                            left: allPadLeft,
                            bottom: allPadBottom + 320,
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(widget.shik.cashe ? 'نقدا' : ''),
                            ),
                          ),
                        Positioned(
                          right: allPadRight.toDouble() + 170,
                          bottom: allPadBottom + 320,
                          left: allPadLeft,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(widget.shik.date),
                          ),
                        ),
                        Positioned(
                          right: allPadRight.toDouble() + 195,
                          bottom: allPadBottom + 320,
                          left: allPadLeft,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text('السيد/ ' + widget.shik.payeeName),
                          ),
                        ),
                        Positioned(
                          right: allPadRight.toDouble() + 223,
                          bottom: allPadBottom + 320,
                          left: allPadLeft,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: SizedBox(
                              width: 420,
                              child: Text(
                                spellNum(widget.shik.value, 1, 'USD'),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: allPadRight.toDouble() + 290,
                          bottom: allPadBottom + 340,
                          left: allPadLeft,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                                numberFormater(widget.shik.value).toString()),
                          ),
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
