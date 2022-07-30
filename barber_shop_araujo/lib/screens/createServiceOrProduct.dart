import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:convert';

class CreateServiceOrProduct extends StatefulWidget {
  const CreateServiceOrProduct({Key? key}) : super(key: key);

  @override
  State<CreateServiceOrProduct> createState() => _CreateServiceOrProductState();
}

class _CreateServiceOrProductState extends State<CreateServiceOrProduct> {
  final dataBase = FirebaseDatabase.instance.ref();

  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  final List<bool> _selections = List.generate(2, (_) => false);
  final List<bool> _selectionEditBarcode = List.generate(2, (_) => false);

  String type = "";
  String typeReaderBarcode = "";
  String barcode = "";
  bool visibilitBarCodeButtonAndInput = false;
  bool visilityButton = false;
  bool editBarcode = false;
  final _tName = TextEditingController();
  final _tValor = TextEditingController();
  final _tBarcode = TextEditingController();
  final _tTotal = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _body(context),
            ],
          ),
        ),
      ),
    );
  }

  _body(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          ToggleButtons(
            direction: Axis.vertical,
            children: [
              Text("Serviço",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0,
                      color: type == "Serviço" ? Color(0xff007aff) : null)),
              Text("Produto",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0,
                      color: type == "Produto" ? Color(0xff007aff) : null))
            ],
            isSelected: _selections,
            onPressed: (int index) {
              setState(() {
                if (index == 0) {
                  type = "Serviço";
                  visibilitBarCodeButtonAndInput = false;
                  typeReaderBarcode = "";
                  _tBarcode.text = "";
                } else if (index == 1) {
                  type = "Produto";
                  visibilitBarCodeButtonAndInput = true;
                  typeReaderBarcode = "";
                  _tBarcode.text = "";
                }
              });
            },
            renderBorder: false,
          ),
          _TextFormFieldInput("Nome", _tName, TextInputType.name, true),
          SizedBox(height: 5.0),
          _TextFormFieldInput("Valor", _tValor, TextInputType.number, true),
          SizedBox(height: 5.0),
          Visibility(
              visible: visibilitBarCodeButtonAndInput,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ToggleButtons(
                    direction: Axis.vertical,
                    children: [
                      Text("Scanner",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20.0,
                              color: typeReaderBarcode == "Scanner"
                                  ? Color(0xff007aff)
                                  : null)),
                      Text("Digitar",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20.0,
                              color: typeReaderBarcode == "Digitar"
                                  ? Color(0xff007aff)
                                  : null))
                    ],
                    isSelected: _selectionEditBarcode,
                    onPressed: (int index) async {
                      if (index == 0) {
                        var result = await BarcodeScanner.scan();
                        barcode = result.rawContent;
                        setState(() {
                          typeReaderBarcode = "Scanner";
                          editBarcode = false;
                          _tBarcode.text = barcode;
                        });
                      } else if (index == 1) {
                        setState(() {
                          typeReaderBarcode = "Digitar";
                          editBarcode = true;
                        });
                      }
                    },
                    renderBorder: false,
                  ),
                  _TextFormFieldInput("Código de Barras", _tBarcode,
                      TextInputType.number, editBarcode)
                ],
              )),
          SizedBox(
            height: 50,
          ),
          Visibility(
              visible: visilityButton,
              child: _optionButton("Registrar", 0xff007aff)),
          SizedBox(height: 5.0),
          _optionButton("Cancelar", 0xff007aff)
        ],
      ),
    );
  }

  _TextFormFieldInput(String name, TextEditingController controller,
      TextInputType type, bool enable) {
    return TextFormField(
      enabled: enable,
      //usando operador ternario para ver qual validador usar.
      validator: name == "Nome" ? _validateInputName : _validateInputNumber,
      controller: controller,
      keyboardType: type,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          labelText: name,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: name,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (tap) {
        if (!_formKey.currentState!.validate()) {
          setState(() {
            visilityButton = false;
          });
          return;
        } else {
          setState(() {
            visilityButton = true;
          });
        }
      },
    );
  }

  _optionButton(String nameButton, int colorButton) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(colorButton),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          //
          if (nameButton == "Cancelar") {
            Navigator.pop(context);
          } else {
            //gravar as informações no firebase
            if (_tName.text == "" || _tValor.text == "") {
              return;
            }
            try {
              addServiceOrProduct(type, _tName.text, _tValor.text,
                  _tBarcode.text, editedTodayDate());
            } on FirebaseException catch (err) {
              errorMsg(err);
            }
          }
        },
        child: Text(nameButton,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String editedTodayDate() {
    var date = DateTime.now().toLocal().toString().substring(0, 10).split("-");
    String editedDate = date[2] + date[1] + date[0];
    return editedDate;
  }

  String? _validateInputNumber(String? text) {
    if (text!.contains(",") || text.contains("-") || text.contains(" ")) {
      //NotificationFCM();
      return "Para valores decimais utilize o .";
    } else if (type == "") {
      return "Selecione um Serviço ou Produto";
    }
    return null;
  }

  String? _validateInputName(String? text) {
    if (text == "") {
      return "Insira um nome para o produto";
    } else if (type == "") {
      return "Selecione um Serviço ou Produto";
    }
    return null;
  }

  void addServiceOrProduct(
      String type, String name, String value, String barcode, String date) {
    if (type == "Produto") {
      dataBase.child(type).push().set({
        'name': name,
        'value': value,
        'barcode': barcode,
        'date': date,
        // 'hour': hour,
        // 'worker': worker
      }).then((c) {
        //após gravar no firebase limpa os campos.
        setState(() {
          _tName.text = "";
          _tValor.text = "";
          type = "";
          visilityButton = false;
          barcode = "";
          visibilitBarCodeButtonAndInput = false;
        });
      });
    } else {
      dataBase.child(type).push().set({
        'name': name,
        'value': value,
        // 'deduction': deduction,
        'date': date,
        // 'hour': hour,
        // 'worker': worker
      }).then((c) {
        //após gravar no firebase limpa os campos.
        setState(() {
          _tName.text = "";
          _tValor.text = "";
          type = "";
          visilityButton = false;
          barcode = "";
          visibilitBarCodeButtonAndInput = false;
        });
      });
    }
  }

  errorMsg(FirebaseException err) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(err.message.toString()),
            actions: <Widget>[
              RawMaterialButton(
                  child: Text("ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
