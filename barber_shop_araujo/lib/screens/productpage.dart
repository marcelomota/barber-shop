import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  late List listProduct;
  late int listProductLenght;
  String selectedProduct = "";
  bool controlViewButton = false;
  var worker;
  String barcode = "";
  double value = 0.0;
  double deduction = 0.0;
  final _tBarcode = TextEditingController();
  final _tDesconto = TextEditingController();
  final _tTotal = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  getServiceOrProduct(String type) {
    final ref = FirebaseDatabase.instance.ref();
    var snapshot = ref.child(type).orderByChild('name');
    snapshot.get().then((snap) {
      setState(() {
        var temp = snap.value as Map<dynamic, dynamic>;
        listProduct = temp.values.toList();
        listProductLenght = temp.values.toList().length;
      });
    });
  }

  getProductByScanner(String barcode) {
    if (barcode == null || barcode == "") {
      return;
    }
    final ref = FirebaseDatabase.instance.ref();
    var snapshot =
        ref.child('Produto').orderByChild('barcode').equalTo(barcode);

    snapshot.get().then((snap) {
      setState(() {
        var temp = snap.value as Map<dynamic, dynamic>;
        selectedProduct = temp.values.first['name'];
        _tBarcode.text = temp.values.first['barcode'];
        value = double.tryParse(temp.values.first['value'])!;
        _tTotal.text = temp.values.first['value'];
        controlViewButton = true;
      });
    });
  }

  @override
  void initState() {
    listProductLenght = 0;
    worker = FirebaseAuth.instance.currentUser?.email;
    // TODO: implement initState
    getServiceOrProduct('Produto');
    super.initState();
  }

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
            children: <Widget>[_body(context)],
          ),
        ),
      ),
    );
  } //end build

  _body(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextButton(
              onPressed: () async {
                var result = await BarcodeScanner.scan();
                barcode = result.rawContent;
                getProductByScanner(barcode);
              },
              child: Text(
                "Scanner",
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 20.0, color: Colors.black),
              )),
          Text("Ou"),
          Material(
              child: TextButton(
            //se selected service for vazio mete esse texto, do contrário exibe
            child: Text(
              selectedProduct == "" ? "Selecionar Produto" : selectedProduct,
              style: style,
            ),
            onPressed: () {
              _optionProduct();
            },
          )),
          _TextFormFieldInput(
              "Desconto", _tDesconto, TextInputType.number, true),
          SizedBox(height: 15.0),
          _TextFormFieldInput(
              "Código de Barras", _tBarcode, TextInputType.number, false),
          SizedBox(height: 15.0),
          _TextFormFieldInput("Total", _tTotal, TextInputType.number, false),
          SizedBox(
            height: 50,
          ),
          Visibility(
              visible: _visibilityButton(),
              child: _optionButton("Registrar", 0xff007aff)),
          SizedBox(height: 5.0),
          _optionButton("Cancelar", 0xff007aff)
        ],
      ),
    );
  } //end body

  _TextFormFieldInput(String name, TextEditingController controller,
      TextInputType type, bool enable) {
    return TextFormField(
      enabled: enable,
      //usando operador ternario para ver qual validador usar.
      validator: _validateInputNumber,
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
      onChanged: (change) async {
        var deductionTotal = 0.0;
        var controlLoseInput = 0.0;
        if (!_formKey.currentState!.validate()) {
          return;
        }
        if (_tDesconto.text == "") {
          deduction += 0.0;
          value -= 0.0;
          setState(() {
            _tDesconto.text = "0";
          });
        } else if (_tDesconto.text == ".") {
          setState(() {
            _tDesconto.text = "0.";
          });
        } else {
          deduction -= double.parse(_tDesconto.text);
        }

        deductionTotal = deduction;
        value = value - double.parse(_tDesconto.text);
        controlLoseInput =
            -1 * (double.parse(_tDesconto.text) + deductionTotal);
        _tTotal.text = (value + controlLoseInput).toStringAsFixed(2);
      },
    );
  } //end form field

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
            newSell(
                "Venda",
                "Produto",
                selectedProduct,
                _tTotal.text,
                deduction.toString(),
                editedTodayDate(),
                DateTime.now().toLocal().toString().substring(11, 19),
                worker.toString());
          }
        },
        child: Text(nameButton,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  } //end option button

  String editedTodayDate() {
    var date = DateTime.now().toLocal().toString().substring(0, 10).split("-");
    String editedDate = date[2] + date[1] + date[0];
    return editedDate;
  }

  String? _validateInputNumber(String? text) {
    if (text!.contains(",") || text.contains(" ")) {
      //NotificationFCM();
      return "Para valores decimais utilize o .";
    }
    return null;
  } //end validiate input number

  bool _visibilityButton() {
    if (controlViewButton == true) {
      return true;
    } else {
      return false;
    }
  }

//Função que captura o erro e trata de alguma forma
  _ErrorMsg(e) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.toString()),
            actions: <Widget>[
              BackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _optionProduct() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: listProductLenght,
                      itemBuilder: (context, index) {
                        return TextButton(
                          child: Text(listProduct[index]['name'], style: style),
                          onPressed: () {
                            deduction = 0.0;
                            value = double.parse(listProduct[index]['value']);
                            setState(() {
                              controlViewButton = true;
                              selectedProduct = listProduct[index]['name'];
                              _tDesconto.text = "";
                              _tTotal.text = value.toString();
                              _tBarcode.text = listProduct[index]['barcode'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      })));
        });
  }

  void newSell(String type, String typeSell, String name, String value,
      String deduction, String date, String hour, String worker) {
    final dataBase = FirebaseDatabase.instance.ref();
    dataBase.child(type).push().set({
      'type': typeSell,
      'name': name,
      'value': value,
      'deduction': deduction,
      'date': date,
      'hour': hour,
      'worker': worker
    }).then((v) {
      setState(() {
        controlViewButton = false;
        selectedProduct = "";
        _tDesconto.text = "";
        _tTotal.text = "";
        _tBarcode.text = "";
      });
    });
  }
}
