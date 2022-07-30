import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SpendingPage extends StatefulWidget {
  const SpendingPage({Key? key}) : super(key: key);

  @override
  State<SpendingPage> createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  final dataBase = FirebaseDatabase.instance.ref();
  final worker = FirebaseAuth.instance.currentUser?.email;
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);

  String type = "";
  String typeReaderBarcode = "";
  String barcode = "";
  bool visibilitBarCodeButtonAndInput = false;
  bool visilityButton = false;
  bool editBarcode = false;
  final _tName = TextEditingController();
  final _tValor = TextEditingController();
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
          _TextFormFieldInput("Nome", _tName, TextInputType.name, true),
          SizedBox(height: 5.0),
          _TextFormFieldInput("Valor", _tValor, TextInputType.number, true),
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
            addSpending(
                "Gastos",
                _tName.text,
                _tValor.text,
                editedTodayDate(),
                DateTime.now().toLocal().toString().substring(11, 19),
                worker.toString());
            //getServiceOrProduct();
            //DateTime.now().toLocal().toString().substring(0, 10));
            //após gravar no firebase limpa os campos.
            setState(() {
              _tName.text = "";
              _tValor.text = "";
              type = "";
              visilityButton = false;
            });
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
    }
    return null;
  }

  String? _validateInputName(String? text) {
    if (text == "") {
      return "Insira um nome para o produto";
    }
    return null;
  }

  void addSpending(String type, String name, String value, String date,
      String hour, String worker) {
    dataBase.child(type).push().set({
      'name': name,
      'value': value,
      // 'deduction': deduction,
      'date': date,
      'hour': hour,
      'worker': worker
    });
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
