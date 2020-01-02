

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:sampleocr/Receipt.dart';


/**
 * date format limitations: https://github.com/jama5262/jiffy/tree/v2.1.2/doc
 * SUPPORTED DATE FORMATS
 *   // YYYY-MM-DD
 *   // YYYY/MM/DD
 *   // DD-MM-YYYY - experimental, dont support yet
 */

class ReceiptParser{
  final SPLITTER = ",";
  bool distinct = true;
  RegExp regMMDDYYYY = new RegExp(r"^\d{2}-\d{2}-\d{4}$");
  RegExp regDDMMYYYY = new RegExp(r"^\d{2}-\d{2}-\d{4}$");
  RegExp regDDMMYY = new RegExp(r"^\d{2}-\d{2}-\d{2}$");
  RegExp regMMDDYY = new RegExp(r"^\d{2}-\d{2}-\d{2}$");


  Receipt getParsedReceiptFromVisionText(VisionText visionText){
    Receipt retVal = new Receipt();
    List<String> totals = new List<String>();
    for (TextBlock block in visionText.blocks) {
      //final Rect boundingBox = block.boundingBox;
      //final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
      //temp+=text+"\n";
      

      
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        //temp += "\n";
        //print("getParsedReceiptFromVisionText:"+line.text);
        String item = line.text;
        if (isNumeric(item)){
          //retVal.priceList.add(double.tryParse(item));
          retVal.priceList.add(item);
        }else if (isDateString(item)){
          retVal.dateList.add(item);
        }else{
          retVal.nameList.add(item);
        }
      }
      retVal.nameList = retVal.nameList.toSet().toList();
      retVal.dateList = retVal.dateList.toSet().toList();
      retVal.priceList = retVal.priceList.toSet().toList();
      if (retVal.dateList.length==0){
        retVal.dateList.addAll(getDatesFromVisionText(visionText));
      }
      if (retVal.priceList.isEmpty && totals.isNotEmpty){
        totals = totals.reversed;
        retVal.priceList.addAll(totals);
      }else if (retVal.priceList.isNotEmpty==true && totals.isNotEmpty){
        totals = totals.reversed;
        retVal.priceList.insertAll(0, totals);
      }


    }
    //totals = getTotalsFromVisionText(visionText);


    return retVal;
  }

  List<String> getDatesFromVisionText(VisionText visionText){
    List<String> retVal = new List<String>();
    for (TextBlock block in visionText.blocks) {
      //final Rect boundingBox = block.boundingBox;
      //final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
      //temp+=text+"\n";
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
        // Same getters as TextBlock
        //temp += element.text+" ";
        //print("getParsedReceiptFromVisionText: "+element.text);
          if (isDateString(element.text)){
            retVal.add(element.text);
          }
        }
      }
      retVal = retVal.toSet().toList();
    }


    return retVal;
  }

  List<String> getTotalsFromVisionText(VisionText visionText){
    List<String> retVal = new List<String>();
    print("getTotalsFromVisionText: ");
    int blockCout = 0;
    for (TextBlock block in visionText.blocks) {

      //final Rect boundingBox = block.boundingBox;
      //final List<Offset> cornerPoints = block.cornerPoints;

      final String blockText = block.text;
      print("getTotalsFromVisionText: ["+blockCout.toString()+"] "+blockText);
      if (blockText.contains("total")){
        //print("getTotalsFromVisionText: "+blockText);
        for (TextLine line in block.lines) {
          //print("getTotalsFromVisionText: line.text: "+line.text);
          if (line.text.contains("total")){
            //print("getTotalsFromVisionText: line.text: "+line.text);
            for (TextElement element in line.elements) {
              // Same getters as TextBlock
              //temp += element.text+" ";
              //print("getTotalsFromVisionText: textelement "+element.text);
              if (isDateString(element.text)){
                retVal.add(element.text);
              }
            }
          }

        }
      }

      blockCout++;
      retVal = retVal.toSet().toList();
    }


    return retVal;
  }


  /*
  Receipt getParsedReceiptFromString(String str, String splitter){
    Receipt retVal = new Receipt();
    if (str?.isNotEmpty == true){
      String productName = "";

      List<String> splitArrStr = str.split(splitter);
      if (splitArrStr!= null && splitArrStr.length > 0){
        int loopLength = splitArrStr.length;
        for (int x = 0; x < loopLength; x++){
          var item = splitArrStr[x];
          if (isNumeric(item)){
            //productPrice = double.tryParse(item);
            retVal.priceList.add(item);
          }else if (isDateString(item)){
            retVal.dateList.add(item);
          }else{
            retVal.nameList.add(productName);
          }
        }
      }
    }
    return retVal;
  }
  */

  List<Map> getParsedTotalFromString(String str, String splitter){
    List<Map> retVal = new List<Map>();
    if (str?.isNotEmpty == true){
      String productName = "";
      num productPrice = 0;
      List<String> splitArrStr = str.split(splitter);
      if (splitArrStr!= null && splitArrStr.length > 0){
        int loopLength = splitArrStr.length;
        for (int x = 0; x < loopLength; x++){
          var item =splitArrStr[x];
          if (isNumeric(item)){
            productPrice = double.tryParse(item);
            //ADD TO MAP
            Map map = new Map();

            map [productName] = productPrice;
            retVal.add(map);
            //RESET VARIABLES
            productName = "";
            productPrice = 0;
          }else{
            if (productName.isEmpty){
              productName += item;
            }else{
              productName += ","+item;
            }
          }
        }
      }
    }
    return retVal;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool isDateString(String s){
    if (s == null) {
      return false;
    }

    //REMOVE TRAILING AND LEADING SPACE

    //need to transform date strings with '/' to '-'
    //if not DateTime.parse() inside isDate will fail
    if (s.contains("/")){
      s = s.replaceAll(new RegExp(r'/'), "-");
    }


    if (regDDMMYYYY.hasMatch(s)){
      return true;
    }

    if (regMMDDYYYY.hasMatch(s)){
      return true;
    }

    if (regMMDDYY.hasMatch(s)){
      return true;
    }
    if (regDDMMYY.hasMatch(s)){
      return true;
    }
    return isDate(s);
  }

  /// check if the string is a date
  bool isDate(String str) {
    try {
      DateTime.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }


}

