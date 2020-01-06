import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';
import 'package:sampleocr/receiptusecase.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'ViewUtil.dart';
import 'customdialog.dart';
import 'receipt_parser.dart';
import 'package:jiffy/jiffy.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

void main() => runApp(MyApp());

enum TextFieldType{
  DATE, REMARK, PRICE
}

enum PageState{
  SHOW_INSTRUCTIONS, SHOW_CAPTURED
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String title = "Sample Receipt OCR";
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements ReceiptUseCaseView{
  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  ReceiptUseCase receiptUseCase = new ReceiptUseCaseImpl();
  @override
  List<String> dateList;
  @override
  List<String> nameList;
  @override
  List<String> priceList;
  File file;
  @override
  String selectedDate;
  @override
  String selectedName;
  @override
  String selectedPrice;
  ProgressDialog pr;
  @override

  PageState pageState = PageState.SHOW_INSTRUCTIONS;

  @override
  void initState() {
    if (textRecognizer==null){
      textRecognizer = FirebaseVision.instance.textRecognizer();
    }
    receiptUseCase.init(this);
    super.initState();
  }

  @override
  void dispose() {
    textRecognizer?.close();
    super.dispose();
  }

  

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    receiptUseCase.run(image, textRecognizer);
    //FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    //final VisionText visionText = await textRecognizer.processImage(visionImage);
    //receiptUseCase.run(visionText);
  }

  @override
  void showLoading() {
    pr.show();
    print("showLoading:");
  }

  @override
  void hideLoading() {


    Future.delayed(const Duration(milliseconds: 1000), () {
      pr.hide().then((x){
        print("hideLoading:");
      });

    });
  }

  void initProcessReceiptLoading(BuildContext context){
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    pr.style(
      message: 'Loading...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
        color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
      );
  }

  void hideKeyboard(){
    FocusScope.of(context).requestFocus(FocusNode());
  }

  var dateController = TextEditingController();
  var remarkController = TextEditingController();
  var priceController = TextEditingController();
  double receiptWidthHeight = 0;
  double textFieldWidth,captureIconWidth = 0;




  @override
  Widget build(BuildContext context) {
    ViewUtil.instance.init(context);
    receiptWidthHeight = 100;
    //pr = new ProgressDialog(context);
    initProcessReceiptLoading(context);

    //See: https://pub.dev/packages/autocomplete_textfield


    textFieldWidth = ViewUtil.instance.displayShorterDimension * 0.5;
    //double labelWidth = shorterDimention * 0.25;
    //double remarkWidth = shorterDimention * 0.65;
    //double dropdownWidth = shorterDimention * 0.1;
    captureIconWidth = ViewUtil.instance.displayShorterDimension * 0.3;

    var firstRow = GestureDetector(
      onTap: () {
        print("");
        showSelectDatePopup(dateList, TextFieldType.DATE);
      },
      child: getColumn2("Date:", (selectedDate.isNotEmpty==true)?selectedDate:"Tap to Select Date", TextFieldType.DATE),
    );

    var secodRow = GestureDetector(
      onTap: () {
        showSelectNamePopup(nameList, TextFieldType.REMARK);
      },
      child: getColumn2("Remark:", (selectedName.isNotEmpty==true)?selectedName:"Tap to Select Remark", TextFieldType.REMARK),
    );

    var thirdRow = GestureDetector(
      onTap: () {
        showSelectPricePopup(priceList, TextFieldType.PRICE);
      },
      child: getColumn2("Price:", (selectedPrice.isNotEmpty==true)?selectedPrice:"Tap to Select Price", TextFieldType.PRICE),
    );


    Widget temp = Container();
    if (PageState.SHOW_INSTRUCTIONS == pageState){
      temp = getInstructionWidget();
    }else if (PageState.SHOW_CAPTURED == pageState){
      temp = getCapturedReceipt();
    }
    print("build: pageState: "+pageState.toString());
    return Scaffold(
      appBar: AppBar(        
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            temp,
            ViewUtil.instance.padding1,
            firstRow,
            ViewUtil.instance.padding08,
            secodRow,
            ViewUtil.instance.padding08,
            thirdRow
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ), 
    );
  }

  Column getInstructionWidget(){
    return Column(
                  children: <Widget>[
                    //Padding(padding: EdgeInsets.all(16.0),),
                    //Text('Enter Receipt Details Below', style: Theme.of(context).textTheme.title,),
                    //Padding(padding: EdgeInsets.all(16.0),),
                    //Text('OR'),
                    ViewUtil.instance.padding1,
                    GestureDetector(
                        onTap: ()  {
                          getImage();
                        },
                        child: Column(
                        children: <Widget>[
                          Icon(Icons.add_a_photo, color: Colors.blueAccent,size: 50,),
                          ViewUtil.instance.padding05,
                          Text('Tap to capture Receipt',  style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                    ViewUtil.instance.padding1,
                  ],
                );
  }



  Widget getCapturedReceipt(){
    Widget image = Container();
    if (file!=null){
      image = Center(child: Image.file(file, width: receiptWidthHeight, height: receiptWidthHeight,),);
    }

    var stack =  Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(child: Text("Loading\nImage...", textAlign: TextAlign.center, style: Theme.of(context).textTheme.title,),),
        image


    ],);

    //return Image.file(file, width: receiptWidthHeight, height: receiptWidthHeight,);

    return Column(
      children: <Widget>[
        //Padding(padding: EdgeInsets.all(16.0),),
        //Text('Enter Receipt Details Below', style: Theme.of(context).textTheme.title,),
        //Padding(padding: EdgeInsets.all(16.0),),
        //Text('OR'),
        ViewUtil.instance.padding1,
        GestureDetector(
          onTap: ()  {
            getImage();
          },
          child: Column(
            children: <Widget>[
              stack,
              ViewUtil.instance.padding05,
              Text('Receipt',  style: Theme.of(context).textTheme.title)
            ],
          ),
        ),
        ViewUtil.instance.padding1,
      ],
    );
  }


  Widget getTextFieldByTextFieldType(TextFieldType textFieldType, TextEditingController controller, String hint, [bool enabled = true]){
    if (textFieldType==TextFieldType.DATE){
      return TextField(
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint
        ),
      );
    }
    if (textFieldType==TextFieldType.REMARK){
      return TextField(
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint
        ),
      );
    }
    if (textFieldType==TextFieldType.PRICE){
      return TextField(
        controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint
        ),
      );
    }
    return Container();
  }


  Widget getColumn2(String label, String hint, TextFieldType textFieldType){
    var widget =  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 5,
          child: Container(),
        ),
        Expanded(
            flex: 20,
            child: Text(label,  textAlign: TextAlign.left, style: Theme.of(context).textTheme.title,)
        ),
        Expanded(
            flex: 30,
            child:
            //getTextFieldByTextFieldType(textFieldType, controller, hint, false)
            Text(
              hint,
              style: Theme.of(context).textTheme.body1,
            )
        ),
        Expanded(
            flex: 5,
            child:
            //getTextFieldByTextFieldType(textFieldType, controller, hint, false)
              Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
              size: 24.0,
              )
        ),
        Expanded(
          flex: 5,
          child: Container(),
        ),
      ],
    );
    return widget;
  }

  Widget getColumn(TextEditingController controller, String label, String hint, Stream stream, String selected, TextFieldType textFieldType){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            flex: 5,
            child: Container(),
        ),
        Expanded(
            flex: 20,
            child: Text(label,  textAlign: TextAlign.left, style: Theme.of(context).textTheme.title,)
        ),
        Expanded(
          flex: 50,
          child:
          getTextFieldByTextFieldType(textFieldType, controller, hint)
        )
        ,
        Expanded(
            flex: 20,
            child: getDropdownStreamBuilder(stream, "", selected, controller)),
      ],
    );
  }

  Widget getDropdownStreamBuilder(Stream stream, String hint, String selected, TextEditingController controller){
    return StreamBuilder<List<String>>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData){
          return buildDropwDown(snapshot.data, hint, selected, controller);
        }
        return Text("-",  textAlign: TextAlign.left,style: TextStyle(color: Colors.black26), textDirection: TextDirection.ltr);

      },
    );
  }

  Widget buildDropwDown(List<String> list, String hint, String selected, TextEditingController controller) {
    List<DropdownMenuItem<String>> dropdownMenuItemList = List.generate(list.length, (i){
      return DropdownMenuItem<String>(
        child:
          Container(
            width: ViewUtil.instance.displayShorterDimension * 0.5,
            child: Text(
                list[i],
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.blueGrey, )

            ),
          ),
        value: i.toString(),
      );
    });
    DropdownButton<String> dropdownButton = new DropdownButton(items: dropdownMenuItemList,
        isExpanded: false,
        isDense: true,
        onChanged: (String val) {
          selected = list[int.parse(val)];
          controller.text = selected;
        },
        autofocus: false,
        hint: Text(hint, textAlign: TextAlign.left, style: TextStyle(color: Colors.redAccent)));

    //return dropdownButton;

    //https://github.com/flutter/flutter/issues/16606
    //return DropdownButtonHideUnderline(
    //  child: dropdownButton
    //);


    var stack = Stack(
      children: <Widget>[

        Container(
          width: 50,
          color: Colors.transparent,
          child: Image.asset('assets/images/dropdown.png', height: 50,),
        ),
        Container(
          width: 50,
          color: Colors.transparent,
          child: DropdownButtonHideUnderline(
              child: dropdownButton
          ),
        ),
       
      ],
    );

    return stack;
   

  }

  @override
  void setPageState(PageState pageState) {
    setState(() {
      this.pageState = pageState;
    });
  }

  @override
  void showSelectDatePopup(List<String> list, TextFieldType type) async{
    String description = "Type";
    if (list!=null && list.length > 0){
      description = "Type or Select from below";
    }
    var cd = CustomDialog(
      title: "Receipt Date",
      description: description,
      buttonText: "PROCEED",
      shorterDimention: ViewUtil.instance.displayShorterDimension,
      callback: (String val){
        setState(() {
          selectedDate = val;
        });

        print("showSelectDatePopup: selectedDate: "+selectedDate);
      },
      suggestions: list,
      type: type,
      selectedValue: selectedDate,
      hideKeyboard: (){
        hideKeyboard();
      },
    );
    showDialog(context: context,
        builder: (BuildContext context){
          return cd;
        }).then((x){
          cd.dispose();
    });
  }

  @override
  void showSelectNamePopup(List<String> list, TextFieldType type) async{
    String description = "Type";
    if (list!=null && list.length > 0){
      description = "Type or Select from below";
    }
    var cd = CustomDialog(
      title: "Remark",
      description: description,
      buttonText: "PROCEED",
      shorterDimention: ViewUtil.instance.displayShorterDimension,
      callback: (String val){
        setState(() {
          selectedName = val;
        });
        print("showSelectNamePopup: selectedName: "+selectedName);
      },
      suggestions: list,
      type: type,
      selectedValue: selectedName,
      hideKeyboard: (){
        hideKeyboard();
      },
    );
    showDialog(context: context,
        builder: (BuildContext context){
          return cd;
        }).then((x){
          cd.dispose();
    });
  }

  @override
  void showSelectPricePopup(List<String> list, TextFieldType type) async {
    String description = "Type";
    if (list!=null && list.length > 0){
      description = "Type or Select from below";
    }
    var cd = CustomDialog(
      title: "Total Amount",
      description: description,
      buttonText: "PROCEED",
      shorterDimention: ViewUtil.instance.displayShorterDimension,
      callback: (String val){
        setState(() {
          selectedPrice = val;
        });

        print("showSelectPricePopup: selectedPrice: "+selectedPrice);
      },
      suggestions: list,
      type: type,
      selectedValue: selectedPrice,
      hideKeyboard: (){
        hideKeyboard();
      },
    );
    showDialog(context: context,
        builder: (BuildContext context){
          return cd;
        }).then((x){
        cd.dispose();
    });
  }

  @override
  void updateImageFile(File file) {
    setState(() {
      this.file = file;
    });
  }

}
