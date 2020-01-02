import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/src/subjects/publish_subject.dart';
import 'package:sampleocr/receiptusecase.dart';

import 'receipt_parser.dart';
import 'package:jiffy/jiffy.dart';

void main() => runApp(MyApp());



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
    setState(() {
      _image = image;
    });
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);  
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    receiptUseCase.run(visionText);
  }

  @override
  void showLoading() {

  }

  @override
  void hideLoading() {

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double receiptWidthHeight = 0;
    double textFieldWidth = 0;
    double shorterDimention = 0;
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


    var firstRow = getColumn(TextEditingController(), "Date:", "Enter or Select Date", dateList.stream, selectedDate);
    var secodRow = getColumn(TextEditingController(), "Remark:", "Enter or Select Remark",  nameList.stream, selectedName);
    var thirdRow = getColumn(TextEditingController(), "Price:", "Enter or Select Price", priceList.stream, selectedPrice);
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
                ? Text('No image selected.')
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


  Widget getColumn(TextEditingController controller, String label, String hint, Stream stream, String selected){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            flex: 15,
            child: Text(label,  textAlign: TextAlign.left,)
        ),
        Expanded(
          flex: 50,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint
            ),
          ),
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
        return Text("-",  textAlign: TextAlign.left,style: TextStyle(color: Colors.red), textDirection: TextDirection.ltr);

      },
    );
  }

  Widget buildDropwDown(List<String> list, String hint, String selected, TextEditingController controller) {
    List<DropdownMenuItem<String>> dropdownMenuItemList = List.generate(list.length, (i){
      return DropdownMenuItem<String>(
        child: Text(
            list[i],
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.blueGrey)),
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

        hint: Text(hint, textAlign: TextAlign.left, style: TextStyle(color: Colors.redAccent)));

    //return dropdownButton;

    //https://github.com/flutter/flutter/issues/16606
    return DropdownButtonHideUnderline(
      child: dropdownButton
    );


  }




  


}
