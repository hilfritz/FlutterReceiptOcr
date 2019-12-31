import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sampleocr/Receipt.dart';
import 'package:sampleocr/receipt_parser.dart';
abstract class ReceiptUseCase{
  ReceiptUseCaseView view;

  void init(ReceiptUseCaseView view);
  void run(VisionText visionText);
  void dispose();
}
abstract class ReceiptUseCaseView{
  String selectedPrice;
  String selectedDate;
  String selectedName;

  PublishSubject<List<String>> priceList;
  PublishSubject<List<String>> dateList;
  PublishSubject<List<String>> nameList;
  void showLoading();
  void hideLoading();

}

class ReceiptUseCaseImpl implements ReceiptUseCase{
  @override ReceiptUseCaseView view;
  ReceiptParser receiptParser = new ReceiptParser();

  @override
  void dispose() {
    view?.priceList?.close();
    view?.dateList?.close();
    view?.nameList?.close();
  }

  @override
  void init(ReceiptUseCaseView view) {
    this.view = view;
    this.view.priceList = new PublishSubject<List<String>>();
    this.view.dateList = new PublishSubject<List<String>>();
    this.view.nameList = new PublishSubject<List<String>>();
    this.view.selectedDate = "";
    this.view.selectedPrice = "";
    this.view.selectedName = "";
  }

  @override
  void run(VisionText visionText) {
    view.showLoading();
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


  }



}