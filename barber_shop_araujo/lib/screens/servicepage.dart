import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  late List listService;
  late int listServiceLenght;
  String selectedService = "";
  bool controlViewButton = false;
  var worker;

  //bool controlBorderService = false;
  // bool controlBorderHair = false;
  // bool controlBorderBeard = false;
  double value = 0.0;
  double deduction = 0.0;

  final _tDesconto = TextEditingController();
  final _tTotal = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  getServiceOrProduct(String type) {
    final ref = FirebaseDatabase.instance.ref();
    var snapshot = ref.child(type).orderByChild('name');
    snapshot.get().then((snap) {
      setState(() {
        var temp = snap.value as Map<dynamic, dynamic>;
        listService = temp.values.toList();
        listServiceLenght = temp.values.toList().length;
      });
    });
  }

  @override
  void initState() {
    listServiceLenght = 0;
    worker = FirebaseAuth.instance.currentUser?.email;
    // TODO: implement initState
    getServiceOrProduct('Serviço');
    //_selections = List.generate(listServiceLenght, (_) => false);
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
          Material(
              child: TextButton(
            //se selected service for vazio mete esse texto, do contrário exibe
            child: Text(
              selectedService == "" ? "Selecionar Serviços" : selectedService,
              style: style,
            ),
            onPressed: () {
              _optionService();
            },
          )),
          _TextFormFieldInput(
              "Desconto", _tDesconto, TextInputType.number, true),
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
        //_tDescontoTotal.text = deduction.toString();
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
                "Serviço",
                selectedService,
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
    if ( //controlBorderBeard == true ||
        //controlBorderHair == true ||
        //controlBorderService == true) {
        controlViewButton == true) {
      return true;
    } else {
      return false;
    }
  }

  // _optionServiceHair(String img) {
  //   return TextButton(
  //       onPressed: () {
  //         if (controlBorderHair == true) {
  //           setState(() {
  //             controlBorderHair = false;
  //           });
  //         } else {
  //           setState(() {
  //             controlBorderHair = true;
  //           });
  //         }
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //             border: controlBorderHair == false
  //                 ? Border.all(color: Colors.transparent)
  //                 : Border.all(color: Colors.red, width: 1.0)),
  //         child: Image.asset(img, width: 80.0, height: 80.0),
  //       ));
  // } //end option service

  // _optionServiceBeard(String img) {
  //   return TextButton(
  //       onPressed: () {
  //         if (controlBorderBeard == true) {
  //           setState(() {
  //             controlBorderBeard = false;
  //           });
  //         } else {
  //           setState(() {
  //             controlBorderBeard = true;
  //           });
  //         }
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //             border: controlBorderBeard == false
  //                 ? Border.all(color: Colors.transparent)
  //                 : Border.all(color: Colors.red, width: 1.0)),
  //         child: Image.asset(img, width: 80.0, height: 80.0),
  //       ));
  // } //end option service

  // _optionService(String name) {
  //   return TextButton(
  //       onPressed: () {
  //         print(name);
  //         if (controlBorderService == true) {
  //           setState(() {
  //             controlBorderService = false;
  //           });
  //         } else {
  //           setState(() {
  //             controlBorderService = true;
  //           });
  //         }
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //             border: controlBorderService == false
  //                 ? Border.all(color: Colors.transparent)
  //                 : Border.all(color: Colors.red, width: 1.0)),
  //         child: Text(name,
  //             style: TextStyle(
  //                 fontFamily: 'Poppins',
  //                 fontSize: 25,
  //                 fontWeight: FontWeight.bold)),
  //       ));
  // } //end option service

  _optionService() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: listServiceLenght,
                      itemBuilder: (context, index) {
                        return TextButton(
                          child: Text(listService[index]['name']),
                          onPressed: () {
                            deduction = 0.0;
                            value = double.parse(listService[index]['value']);
                            setState(() {
                              controlViewButton = true;
                              selectedService = listService[index]['name'];
                              _tDesconto.text = "";
                              _tTotal.text = value.toString();
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
        selectedService = "";
        _tDesconto.text = "";
        _tTotal.text = "";
      });
    });
  }
}
