import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';
import 'package:sampleocr/receiptusecase.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'receipt_parser.dart';
import 'package:jiffy/jiffy.dart';

void main() => runApp(MyApp());

enum TextFieldType{
  DATE, REMARK, PRICE
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

  ReceiptParser _receiptParser = new ReceiptParser();
  File _image;
  String _ocrResult = "";
  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  ReceiptUseCase receiptUseCase = new ReceiptUseCaseImpl();
  double shorterDimention = 0;
  @override
  PublishSubject<List<String>> dateList;
  @override
  PublishSubject<List<String>> nameList;
  @override
  PublishSubject<List<String>> priceList;
  @override
  String selectedDate;
  @override
  String selectedName;
  @override
  String selectedPrice;

  ProgressDialog pr;

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
    setState(() {
      _image = image;
    });
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

  @override
  Widget build(BuildContext context) {
    //pr = new ProgressDialog(context);
    initProcessReceiptLoading(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double receiptWidthHeight = 0;
    double textFieldWidth = 0;


    //See: https://pub.dev/packages/autocomplete_textfield
    if (width<height){
      receiptWidthHeight = width * 0.5;
      shorterDimention = width;
    }else{
      receiptWidthHeight = height * 0.5;
      shorterDimention = height;
    }

    textFieldWidth = receiptWidthHeight;
    double labelWidth = shorterDimention * 0.25;
    double remarkWidth = shorterDimention * 0.65;
    double dropdownWidth = shorterDimention * 0.1;
    double captureIconWidth = shorterDimention * 0.3;

    var firstRow = getColumn(dateController, "Date:", "Enter or Select Date", dateList.stream, selectedDate, TextFieldType.DATE);
    var secodRow = getColumn(remarkController, "Remark:", "Enter or Select Remark",  nameList.stream, selectedName, TextFieldType.REMARK);
    var thirdRow = getColumn(priceController, "Price:", "Enter or Select Price", priceList.stream, selectedPrice, TextFieldType.PRICE);
    //var thirdRow = Container();


    /*
    var firstRow = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Text("Date:")
                      ),
                    Expanded(
                      flex: 60,
                          child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter date'
                          ),
                        ),
                    )
                   ,
                    Expanded(
                      flex: 20,
                      child: getDropdownStreamBuilder(dateList.stream, "", selectedDate)),
                  ],
                );


    var secodRow = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Remark:"
                    ),
                    SizedBox(
                      width: textFieldWidth,
                      child:  TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter remark'
                        ),
                      ),
                    )
                    ,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getDropdownStreamBuilder(nameList.stream, "", selectedName),
                      ],
                    ),
                  ],
                );
    var thirdRow = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Price:"),
                    SizedBox(
                      width: textFieldWidth,
                      child:  TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter price'
                        ),
                      ),
                    )
                    ,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getDropdownStreamBuilder(priceList.stream, "", selectedPrice),
                      ],
                    ),
                  ],
                );
    */

    return Scaffold(
      appBar: AppBar(        
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _image == null
                ? Column(
                  children: <Widget>[
                    //Padding(padding: EdgeInsets.all(16.0),),
                    //Text('Enter Receipt Details Below', style: Theme.of(context).textTheme.title,),
                    //Padding(padding: EdgeInsets.all(16.0),),
                    //Text('OR'),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                    ),
                    GestureDetector(
                        onTap: ()  {
                          getImage();
                        },
                        child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/camera1.png', width: captureIconWidth, height: captureIconWidth,),
                          Text('Try the Receipt Assistant!',  style: Theme.of(context).textTheme.title)
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(16.0),),
                    
                  ],
                )
                : Image.file(_image, width: receiptWidthHeight, height: receiptWidthHeight,),
                Text("")
            ,
            firstRow,
            secodRow,
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


  Widget getTextFieldByTextFieldType(TextFieldType textFieldType, TextEditingController controller, hint){
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
            width: shorterDimention * 0.5,
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




  


}
