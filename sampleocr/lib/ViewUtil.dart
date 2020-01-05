import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class ViewUtil {
  ViewUtil._privateConstructor();
  static final ViewUtil instance = ViewUtil._privateConstructor();
  ViewUtil();

  double displayWidth = 0;
  double displayHeight = 0;
  double displayShorterDimension = 0;
  Widget padding1 = Padding(padding: EdgeInsets.all(16.0));
  Widget padding05 = Padding(padding: EdgeInsets.all(4.0));
  Widget padding08 = Padding(padding: EdgeInsets.all(8.0));

  void init(BuildContext context){
    displayWidth = MediaQuery.of(context).size.width;
    displayHeight = MediaQuery.of(context).size.height;
    if (displayWidth<displayHeight){
      displayShorterDimension = displayWidth;
    }else{
      displayShorterDimension = displayHeight;
    }
  }
  Widget getSubmitButton(String text, void callback()){
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
      child: Material(  //Wrap with Material
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
        elevation: 18.0,
        color: Colors.green,
        clipBehavior: Clip.antiAlias, // Add This
        child: MaterialButton(
          minWidth: 200.0,
          height: 35,
          child: new Text(text,
              style: new TextStyle(fontSize: 16.0, color: Colors.white)),
          onPressed: () {
            callback();
          },
        ),
      ),
    );
  }

  Widget getSubmitButton2(String text, void callback()){
    return  GestureDetector(
      onTap: (){
        callback();
      },
      child:
        Container(
          width: 100.0,
          height: 20,
          child: new Text(text,
              style: new TextStyle(fontSize: 16.0, color: Colors.blue)),
        ),
    );
  }

}