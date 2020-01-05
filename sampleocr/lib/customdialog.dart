import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'ViewUtil.dart';
import 'main.dart';
class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final double shorterDimention;
  final callback;
  final List<String> suggestions;

  final TextFieldType type;
  BuildContext context;

  GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteGlobalKey = new GlobalKey();

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.shorterDimention,
    @required this.callback,
    @required this.suggestions,
    @required this.type,
    @required this.selectedValue
  }
  );

  String selectedValue;
  AutoCompleteTextField<String> textField;
  TextEditingController controller = new TextEditingController();

  void init(){
      textField = new AutoCompleteTextField<String>(
        controller: controller,
        decoration: new InputDecoration(
            hintText: description, suffixIcon: new Icon(Icons.arrow_drop_down)),
        itemSubmitted: (item) {
          selectedValue = item;
        },
        keyboardType: getKeyboardType(type),
        inputFormatters: getInputFormatters(type),
        key: key,
        clearOnSubmit: false,
        suggestions: suggestions,
        itemBuilder: (context, suggestion) =>
        new Padding(
            child: new ListTile(
              title: new Text(suggestion),
              //trailing: new Text("Stars: ${suggestion}")
            ),
            padding: EdgeInsets.all(8.0)),
        //itemSorter: (a, b) => a.stars == b.stars ? 0 : a.stars > b.stars ? -1 : 1,
        itemSorter: (String a, String b) => a.compareTo(b),
        itemFilter: (suggestion, input) {
          return suggestion.toLowerCase().startsWith(input.toLowerCase());
        },
        expandDropdownByDefault: true,
      );

  }


  Widget getSuggestionsListView(List<String> list, TextEditingController controller){
    if (list==null || list.isEmpty){
      return Container();
    }
    List<Widget> listWidget = List<Widget>();
    for (int x = 0; x < list.length; x++){
      var text = list[x];
      //var itemWidget = new Text(text, style: Theme.of(context).textTheme.subhead);
      var itemWidget = Padding(
          child:  new Text(text, style: Theme.of(context).textTheme.subhead),
          padding: EdgeInsets.all(5.0));
      var gesture = GestureDetector(
        onTap: (){
          selectedValue = text;
          controller.text = selectedValue;
        },
        child: itemWidget,
      );
      var column = Column(
        children: <Widget>[
          gesture,
          Divider(
            color: Colors.black38,
          ),
        ],
      );
      listWidget.add(column);
    }
    return Scrollbar(
      child: new Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent)
        ),
        child: SizedBox (
          height: shorterDimention * 0.5,
          width: shorterDimention * 0.5,
          child: ListView(
            children: listWidget,
          ),
        ),
      ),
    );


  }


  Widget getSimpleTextField(List<String> list, TextEditingController controller, String description, TextFieldType type){
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
            size: 24.0,
          ),
        ),

        Container(
          width: ViewUtil.instance.displayShorterDimension * 0.7,
          child: getTextFieldByTextFieldType(type, controller, description),
        ),
      ],
    );
  }

  getKeyboardType(TextFieldType type){
    if (type==TextFieldType.PRICE){
      return TextInputType.numberWithOptions(decimal: true, signed: false);
    }
  }

  getInputFormatters(TextFieldType type){
    if (type==TextFieldType.PRICE) {
      return <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    init();
    if (selectedValue!=null && selectedValue.isNotEmpty){
      controller.text =  selectedValue;
    }



    var dialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: shorterDimention * 0.5,
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 24.0,
                ),
              ),
            ),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.title,),
            ViewUtil.instance.padding1,
            //Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.title,),
            //textField,
            getSimpleTextField(suggestions, controller, description, type),
            ViewUtil.instance.padding1,
            getSuggestionsListView(suggestions, controller),
            ViewUtil.instance.padding1,
            //buildDropwDown(this.suggestions, this.description, selectedValue, dropDownController),
            Align(
              alignment: Alignment.centerRight,
              child: ViewUtil.instance.getSubmitButton2(buttonText, (){
                if (controller.text!=selectedValue){
                  selectedValue = controller.text;
                }
                callback(selectedValue);
                Navigator.pop(context);
              }),
            ),
//              ViewUtil.instance.getSubmitButton(buttonText, (){
//                callback(selectedValue);
//                Navigator.pop(context);
//              }),
            ViewUtil.instance.padding1,
          ],
        ),
      ),
    );
    //return dialog;
    return dialog;

  }
  /*

  Widget buildDropwDown(List<String> list, String hint, String selected, TextEditingController controller) {
    List<DropdownMenuItem<String>> dropdownMenuItemList = List.generate(list.length, (i){
      return DropdownMenuItem<String>(
        child:
        Container(
          width: ViewUtil.instance.displayShorterDimension * 0.8,
          child: Text(
              list[i],
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.blueGrey, )

          ),
        ),
        value: i.toString(),
      );
    });

    if (selectedValue!=null && selectedValue.isNotEmpty){
      //hint = selectedValue;
    }
    DropdownButton<String> dropdownButton = new DropdownButton(items: dropdownMenuItemList,
        isExpanded: false,
        isDense: true,
        onChanged: (String val) {
          selected = list[int.parse(val)];
          print("dropdown: changed: "+selected);
          selectedValue = selected;
        },
        autofocus: false,
        hint: Text(hint, textAlign: TextAlign.left, style: TextStyle(color: Colors.redAccent)));
    var stack = Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: 24.0,
            ),
        ),
        Container(
          width: ViewUtil.instance.displayShorterDimension * 0.7,
          child: DropdownButtonHideUnderline(
              child: dropdownButton
          ),
        ),
        Container(
          width: ViewUtil.instance.displayShorterDimension * 0.3,
          child: getTextFieldByTextFieldType(type, controller, hint),
        )


      ],
    );
    return stack;


  }
  */



  Widget getTextFieldByTextFieldType(TextFieldType textFieldType, TextEditingController controller, String hint, [bool enabled = true]){
    if (textFieldType==TextFieldType.DATE){
      return TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: hint
        ),
        onChanged: (String val){
          //controller.text = val;
        },
      );
    }
    if (textFieldType==TextFieldType.REMARK){
      return TextField(
        controller: controller,
        decoration: InputDecoration(

            hintText: hint
        ),
        onChanged: (String val){
          //controller.text = val;
        },
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

            hintText: hint
        ),
        onChanged: (String val){
          //controller.text = val;
        },
      );
    }
    return Container();
  }

  void dispose(){
    controller.clear();
    controller = null;
  }
}