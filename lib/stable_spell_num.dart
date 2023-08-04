library spell_num;

String spellNum(double num, int decimal, String cur) {
  String getDigit(String num) {
    String temp = "";
    switch (num) {
      case "1":
        temp = "واحد ";
        break;
      case "2":
        temp = "اثنان ";
        break;
      case "3":
        temp = "ثلاثة ";
        break;
      case "4":
        temp = "اربع ";
        break;
      case "5":
        temp = "خمسة ";
        break;
      case "6":
        temp = "ستة ";
        break;
      case "7":
        temp = "سبعة ";
        break;
      case "8":
        temp = "ثمانية ";
        break;
      case "9":
        temp = "تسعة ";
        break;
      default:
        temp = "";
    }
    return temp;
  }
  // String getHundereds(String num) {
  //   String temp = "";
  //   switch (num) {
  //     case "1":
  //       temp = "مائة ";
  //       break;
  //     default:
  //       temp = "";
  //   }
  //   return temp;
  // }

  String getTens(String digit) {
    String result;
    print('digit: $digit');

    if (digit[0] == '1') {
      switch (digit) {
        case "10":
          result = "عشرة ";
          break;
        case "11":
          result = "احدى عشر ";
          break;
        case "12":
          result = "اثنى عشر ";
          break;
        case "13":
          result = "ثلاثة عشر ";
          break;
        case "14":
          result = "اربعة عشر ";
          break;
        case "15":
          result = "خمسة عشر ";
          break;
        case "16":
          result = "ستة عشر ";
          break;
        case "17":
          result = "سبعة عشر ";
          break;
        case "18":
          result = "ثمانية عشر ";
          break;
        case "19":
          result = "تسعة عشر ";
          break;
        default:
          result = "";
      }
    } else {
      switch (digit[0]) {
        case '2':
          result = "عشرون ";
          break;
        case '3':
          result = "ثلاثون ";
          break;
        case '4':
          result = "اربعون ";
          break;
        case '5':
          result = "خمسون ";
          break;
        case '6':
          result = "ستون ";
          break;
        case '7':
          result = "سبعون ";
          break;
        case '8':
          result = "ثمانون ";
          break;
        case '9':
          result = "تسعون ";
          break;
        default:
          result = "";
          break;
      }
      result =
          '${getDigit((digit.substring(1)))} ${getDigit((digit.substring(1))).isEmpty ? '' : 'و'}$result';
    }
    return result;
  }

  String result = "";
  String spellDec = "";
  String spellNum = "";

  List<int> numbers = [];
//round the decimal in case you want no decimals
  if (decimal == 0) {
    numbers.add(num.ceilToDouble().toInt());
  } else {
    numbers = (num.toStringAsFixed(decimal)
        .split('.')
        .map((e) => int.parse(e))
        .toList());
  }
  String numAsString = numbers.elementAt(0).toString().padLeft(2, '0');
  print(numbers);
  print(numAsString.length);
  if (numAsString.length >= 2) {
    for (int i = 0; i < numAsString.length; i++) {
      print('$i - $spellNum');
      if (i == numAsString.length - 9) {
        print('==== $i numAsString.length - 9');
        if (numAsString.substring(i, i + 1) == '1') {
          // spellNum += " مائة و";
          // spellNum +=
          //     getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : 'مائة و';
          spellNum +=
              "مائة ${getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
        } else if (numAsString.substring(i, i + 1) == '2') {
          spellNum +=
              "مائتان ${getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          // spellNum += " مائتان و";
          // spellNum += getTens(numAsString.substring(i, i + 1)).isEmpty
          //     ? ''
          //     : 'مائتان و';
        } else {
          spellNum += getDigit(numAsString.substring(i, i + 1));
          if (!(numAsString.substring(i, i + 1) == ("0"))) {
            print('==== ${numAsString.substring(i, i + 1)} == ("0"))');
            spellNum +=
                "مائة ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          }
        }
      }
      if (numAsString.length == 7) {
        print('==== numAsString.length == 7');
        if (i == numAsString.length - 7) {
          print('==== $i numAsString.length - 7');
          spellNum += getDigit(numAsString.substring(i, i + 1));
          spellNum +=
              "مليون ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          continue;
        }
      }
      if (numAsString.length > 7) {
        print('==== numAsString.length > 7');
        if (i == numAsString.length - 7) {
          print('==== $i == numAsString.length - 7');
          --i;
          if (i == numAsString.length - 8) {
            print('==== $i == numAsString.length - 8');
            spellNum += getTens(numAsString.substring(i, i + 2));
            spellNum += " مليون و";
            ++i;
            continue;
          }

          spellNum += getDigit(numAsString.substring(i, i + 1));
          spellNum +=
              "مليون ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          continue;
        }
      }

      if (i == numAsString.length - 6) {
        print('==== $i == numAsString.length - 6');
        if (numAsString
            .substring(
              i,
            )
            .contains('000000')) {
          // continue;
        } else {
          if (numAsString.substring(i, i + 1) == '1') {
            spellNum +=
                "مائة ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          } else if (numAsString.substring(i, i + 1) == '2') {
            spellNum +=
                "مائتان ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
          } else {
            spellNum +=
                "مائة ${getDigit(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و'}";
            spellNum += getDigit(numAsString.substring(i, i + 1));
          }
        }
      }
      if (numAsString.length > 4) {
        print('==== numAsString.length > 4');
        if (i == numAsString.length - 4) {
          print('==== $i == numAsString - 4');
          --i;
          if (i == numAsString.length - 5) {
            print('==== $i == $numAsString - 5');
            spellNum += getTens(numAsString.substring(i, i + 2));
            if (!numAsString.substring(i).contains('00000')) {
              // print('--------------${spellNum.substring(spellNum.length - 2)}');
              // spellNum += getTens(numAsString.substring(i, i + 2)).isEmpty
              //     ? ''
              //     : ' الف و';
              spellNum +=
                  " ${getTens(numAsString.substring(i, i + 3)) == '' ? '' : 'و'} ";
              spellNum += "الف";
            } else {
              if (numAsString.length < 7 && spellNum.contains('مائة')) {
                spellNum = spellNum.replaceRange(
                    spellNum.length - 2, spellNum.length, '');
                spellNum += "الف";
              }
            }
            ++i;
            continue;
          }
          if (i == numAsString.length - 4) {
            print('==== $i == numAsString.length - 4');
            spellNum += getTens(numAsString.substring(i, i + 1));
            // spellNum += "الف و ";
            // print('--------------${spellNum.substring(spellNum.length - 2)}');
            // if (spellNum.substring(spellNum.length - 2) == ' و') {
            //   print('--------------');
            // }
            spellNum +=
                getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : ' و';
            spellNum += "الف";
            // spellNum +=
            //     " ${getTens(numAsString.substring(i, i + 2)) == '' ? '' : 'و'} ";
            continue;
          }
        }
      }
      if (numAsString.length == 4) {
        print('==== numAsString.length == 4');
        if (i == numAsString.length - 4) {
          print('==== $i == numAsString.length - 4');
          spellNum += getDigit(numAsString.substring(i, i + 1));
          // print('--------------${spellNum.substring(spellNum.length - 2)}');
          spellNum += " الف و";
          // spellNum +=
          //     getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : 'الف و';
          // spellNum +=
          //     "الف ${getTens(numAsString.substring(i, i + 2)).isEmpty ? '' : 'و'} ";
          continue;
        }
      }

      if (i == numAsString.length - 3) {
        print('==== $i == numAsString.length - 3');
        if (numAsString.substring(i, i + 1) == '1') {
          spellNum += " مائة و";
          // spellNum +=
          //     getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : 'مائة و';
          // spellNum +=
          //     "مائة ${getTens(numAsString.substring(i, i + 1)).isEmpty ? '' : 'و'} ";
        } else if (numAsString.substring(i, i + 1) == '2') {
          spellNum += " مائتان و";
          // spellNum += getTens(numAsString.substring(i, i + 1)).isEmpty
          //     ? ''
          //     : 'مائتان و';
        } else {
          spellNum += getDigit(numAsString.substring(i, i + 1));
          if (!(numAsString.substring(i, i + 1) == ("0"))) {
            print('==== ${numAsString.substring(i, i + 1)} == ("0")');
            // spellNum += getTens(numAsString.substring(i, i + 1)).isEmpty
            //     ? ''
            //     : 'مائة و';
            spellNum += " مائة و";
          }
        }
      }

      if (i == numAsString.length - 2) {
        print('==== $i == numAsString.length - 2');
        spellNum += getTens(numAsString.substring(i));
      }
    }
  } else {
    getDigit(numAsString);
  }

  spellNum = spellNum.trimRight();

  try {
    print('sdsdf: ${spellNum.substring(spellNum.length - 2)}');
    if (spellNum.substring(spellNum.length - 2).contains(' و')) {
      // spellNum[spellNum.length + 1] = '';
      spellNum = spellNum.replaceRange(spellNum.length - 2, null, '');
      // spellNum = spellNum.trimRight();
    }
  } catch (e) {
    //
  }

  if (numbers.elementAt(1) != 0) {
    String dec = numbers.elementAt(1).toString().padLeft(2, '0');
    if (cur == ("\$") || cur == "USD") spellDec += "و ${getTens(dec)}قرش";
    if (cur == ("€") || cur == "EUR") spellDec += "و ${getTens(dec)}قرش";
    if (cur == ("AED")) spellDec += "و ${getTens(dec)}Cents";
  }

  if (cur == ("\$") || cur == "SDG") spellNum += " جنيه ";
  if (cur == ("\$") || cur == "USD") spellNum += " جنيه ";
  if (cur == ("€") || cur == "EUR") spellNum += " جنيه ";
  if (cur == ("AED")) spellNum += "Emirati Dirhams";
  if (cur == ("LBP")) spellNum += " Lebanese Pounds";

  result = "$spellNum $spellDec";

  return result;
}

void main() {
  var r = spellNum(985432723.55, 2, 'USD');
  print(r);

  r = spellNum(985432.55, 2, 'USD');
  print(r);
  // Nine Hundred Eighty Five Million Four Hundred Thirty Two Thousand Seven Hundred Twenty Three Euros and Fifty Five Cents

  r = spellNum(18.06, 2, 'USD');
  print(r);
  //Eighteen Dollars and Six Cents

  r = spellNum(9.9, 2, '\$');
  print(r);
  //Nine Dollars and Ninety Cents

  r = spellNum(3330.00, 2, '\$');
  print(r);

  //Three Thousand Three Hundred Thirty Dollars
}
