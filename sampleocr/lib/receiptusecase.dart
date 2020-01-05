import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sampleocr/Receipt.dart';
import 'package:sampleocr/main.dart';
import 'package:sampleocr/receipt_parser.dart';

import 'main.dart';
import 'main.dart';
abstract class ReceiptUseCase{
  ReceiptUseCaseView view;

  void init(ReceiptUseCaseView view);
  //void run(VisionText visionText);
  void run(File file, TextRecognizer textRecognizer);
  void dispose();
}
abstract class ReceiptUseCaseView{
  String selectedPrice;
  String selectedDate;
  String selectedName;

  PageState pageState;
  //PublishSubject<List<String>> priceList;
  //PublishSubject<List<String>> dateList;
  //PublishSubject<List<String>> nameList;
  List<String> priceList  = new List<String>();
  List<String> dateList  = new List<String>();
  List<String> nameList  = new List<String>();

  void showSelectDatePopup(List<String> dateList, TextFieldType type);
  void showSelectPricePopup(List<String> list, TextFieldType type);
  void showSelectNamePopup(List<String> list, TextFieldType type);
  void updateImageFile(File file);
  void setPageState(PageState pageState);
  void showLoading();
  void hideLoading();

}

class ReceiptUseCaseImpl implements ReceiptUseCase{
  @override ReceiptUseCaseView view;
  ReceiptParser receiptParser = new ReceiptParser();

  @override
  void dispose() {
    //view?.priceList?.close();
    //view?.dateList?.close();
    //view?.nameList?.close();
    view?.updateImageFile(null);
  }

  @override
  void init(ReceiptUseCaseView view) {
    this.view = view;
    view?.updateImageFile(null);
    //this.view.priceList = new PublishSubject<List<String>>();
    //this.view.dateList = new PublishSubject<List<String>>();
    //this.view.nameList = new PublishSubject<List<String>>();
    this.view.selectedDate = "";
    this.view.selectedPrice = "";
    this.view.selectedName = "";
    view.dateList = new List<String>();
    view.priceList = new List<String>();
    view.nameList = new List<String>();
  }

  @override
  void run(File image, TextRecognizer textRecognizer) async{
    view.setPageState(PageState.SHOW_INSTRUCTIONS);
    view.showLoading();
    
    await Future.delayed(Duration(milliseconds: 1000));

    if (image==null){
      //USER DIDNT CAPTURE PHOTO
      view?.hideLoading();
      return;
    }
    view?.updateImageFile(image);
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final VisionText visionText = await textRecognizer.processImage(visionImage);
  
    Receipt receipt = receiptParser.getParsedReceiptFromVisionText(visionText);
    if (receipt==null){
      view.hideLoading();
      //SHOW ERROR MESSAGE
      return;
    }

    if (receipt!=null){
      if (
      receipt.priceList==null ||
          receipt.nameList==null ||
          receipt.dateList==null
      ){
        view.hideLoading();
        //SHOW ERROR MESSAGE
        return;
      }
    }

    //CLEAR THE LISTS
    //view.priceList.add(new List<String>());
    //view.nameList.add(new List<String>());
    //view.dateList.add(new List<String>());

    view.priceList.clear();
    view.nameList.clear();
    view.dateList.clear();


    view.selectedDate = "";
    view.selectedName = "";
    view.selectedPrice = "";

    if (receipt.priceList.isNotEmpty){
      //view.priceList.add(receipt.priceList);
      view.priceList.addAll(receipt.priceList);
    }

    if (receipt.nameList.isNotEmpty){
      //view.nameList.add(receipt.nameList);
      view.nameList.addAll(receipt.nameList);
    }

    if (receipt.dateList.isNotEmpty){
      view.dateList.addAll(receipt.dateList);
      //view.dateListTemp.addAll(receipt.dateList);

    }
    if (image==null){
      print("run: image null");
    }
    if (image!=null){
      print("run: image ok");
    }

    view.hideLoading();
    view.setPageState(PageState.SHOW_CAPTURED);

  }



}
