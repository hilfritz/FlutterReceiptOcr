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
  ReceiptUseCase receiptUseCaseView = new ReceiptUseCaseImpl();

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
    String text = visionText.text;

    print(">> "+text);
    var parsed = _receiptParser.getParsedReceiptFromString(text, "\n");
    parsed = _receiptParser.getParsedReceiptFromVisionText(visionText);


    //print(temp);
    String temp = "";
    temp = text;
    print("==========DATES=========");
    print(parsed.dateList);
    print("==========NAMES=========");
    print(parsed.nameList);
    print("==========PRICES=========");
    print(parsed.priceList);

    //temp = parsed;
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
      //temp+=text+"\n";
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        //temp += "\n";
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          //temp += element.text+" ";
        }
      }
    }
    setState(() {
      _ocrResult = temp;
    });
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
    if (width<height){
      receiptWidthHeight = width * 0.5;
    }else{
      receiptWidthHeight = height * 0.5;
    }

    textFieldWidth = receiptWidthHeight;

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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: textFieldWidth,
                      child:  TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter date'
                        ),
                      ),
                    )
                   ,
                    Text("∇"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                    Text("∇"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                    Text("∇"),
                  ],
                ),

              ],
            )
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


  Widget buildDropwDown(List<String> list, String hint, String selected) {
    List<DropdownMenuItem> dropdownMenuItemList = List.generate(list.length, (i){
      return DropdownMenuItem<String>(
        child: Text(list[i]),
        value: i.toString(),
      );
    });
    DropdownButton<String> dropdownButton = new DropdownButton(items: dropdownMenuItemList,
        isExpanded: false,
        onChanged: (String val) {
          selected = val;
        },
        hint: Text(hint));

    return dropdownButton;


  }




  


}
