import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class YieldPage extends StatefulWidget {
  const YieldPage({Key? key}) : super(key: key);

  @override
  State<YieldPage> createState() => _YieldPageState();
}

class _YieldPageState extends State<YieldPage> {
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  final ref = FirebaseDatabase.instance.ref();
  late var listServiceProductorSpending;
  late int listServiceProductorSpendingLenght;
  String emptyService = "";
  double valueTotal = 0.0;
  double revenueTotal = 0.0;
  var typesSearch = ['Gastos', 'Vendas'].toList();
  late String typeSearch;
  List subTypesSearch = List.empty(growable: true);
  late String subTypeSearch;
  final _tDayInitial = TextEditingController();
  final _tMonthInitial = TextEditingController();
  final _tYearInitial = TextEditingController();
  final _tDayFinal = TextEditingController();
  final _tMonthFinal = TextEditingController();
  final _tYearFinal = TextEditingController();
  final _tTotal = TextEditingController();
  final _tMediaTotal = TextEditingController();
  final _tReceita = TextEditingController();
  final _tReceitaMedia = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String editedTodayDate() {
    var date = DateTime.now().toLocal().toString().substring(0, 10).split("-");
    String editedDate = date[2] + date[1] + date[0];
    return editedDate;
  }

  String dateFormat(String dateString) {
    String dateFormated = dateString.substring(0, 2) +
        '/' +
        dateString.substring(2, 4) +
        '/' +
        dateString.substring(4, 8);
    return dateFormated;
  }

  String? _validateInputNumber(String? text) {
    if (text!.contains(",") || text.contains(" ")) {
      //NotificationFCM();
      return "Para valores decimais utilize o .";
    }
    return null;
  }

  String? _validateInputNumberDay(String? text) {
    RegExp dayValidator = RegExp(r'[0-9]{2}$');

    if (!dayValidator.hasMatch(text.toString()) ||
        text!.contains(" ") ||
        text == "") {
      return "Apenas números";
    } else if (int.tryParse(text)! > 31) {
      return "Um mês tem no máximo 31 dias";
    } else if (int.tryParse(text) == 0) {
      return "Não existe dia 0";
    } else if (_verifyFinalDate()) {
      //NotificationFCM();
      return "Período Inválido";
    }
    return null;
  }

  String? _validateInputNumberMonth(String? text) {
    RegExp dayValidator = RegExp(r'[0-9]{2}$');

    if (!dayValidator.hasMatch(text.toString()) ||
        text!.contains(" ") ||
        text == "") {
      //NotificationFCM();
      return "Apenas números";
    } else if (int.tryParse(text)! > 12) {
      //NotificationFCM();
      return "Um mês tem no máximo 31 dias";
    } else if (int.tryParse(text) == 0) {
      //NotificationFCM();
      return "Não existe mês zero";
    } else if (_verifyFinalDate()) {
      //NotificationFCM();
      return "Período Inválido";
    }
    return null;
  }

  String? _validateInputNumberYear(String? text) {
    RegExp dayValidator = RegExp(r'[0-9]{4}$');

    if (!dayValidator.hasMatch(text.toString()) ||
        text!.contains(" ") ||
        text == "") {
      //NotificationFCM();
      return "Apenas números";
    } else if (int.tryParse(text)! > DateTime.now().year) {
      //NotificationFCM();
      return "Ano inválido";
    } else if (_verifyFinalDate()) {
      //NotificationFCM();
      return "Período Inválido";
    }
    return null;
  }

  bool _verifyFinalDate() {
    DateTime dateToday = DateTime.now();
    if (_tDayFinal.text == "" ||
        _tMonthFinal.text == "" ||
        _tYearFinal.text == "") {
      return true;
    } else if (int.tryParse(_tDayFinal.text)! > dateToday.day &&
        int.tryParse(_tMonthFinal.text)! >= dateToday.month &&
        int.tryParse(_tYearFinal.text)! >= dateToday.year) {
      return true;
    } else if (int.tryParse(_tMonthFinal.text)! > dateToday.month &&
        int.tryParse(_tYearFinal.text)! >= dateToday.year) {
      return true;
    } else {
      return false;
    }
  }

  getCompleteYield(String type, String initialDay, String finalDay) {
    if (type == 'Vendas') {
      type = 'Venda';
    }
    var snapshot = ref
        .child(type)
        .orderByChild('date')
        .startAt(initialDay)
        .endAt(finalDay);
    snapshot.get().then((snap) {
      if (snap.children.isEmpty) {
        setState(() {
          listServiceProductorSpendingLenght = 0;
        });
      } else {
        valueTotal = 0.0;
        var control;
        for (var element in snap.children) {
          control = element.value as Map<dynamic, dynamic>;

          valueTotal += double.tryParse(control['value'])!;
        }
        var temp = snap.value as Map<dynamic, dynamic>;
        listServiceProductorSpending = temp.values.toList();
        listServiceProductorSpendingLenght = temp.values.toList().length;
      }
    }).then((v) {
      getSpending(type, initialDay, finalDay);
    });
  }

  getSpending(String type, String initialDay, String finalDay) {
    String controlRevenue;
    double spending = 0.0;
    int qtdSpending = 1;
    if (type == 'Gastos') {
      controlRevenue = 'Venda';
    } else {
      controlRevenue = 'Gastos';
    }
    var snapshotRevenue = ref
        .child(controlRevenue)
        .orderByChild('date')
        .startAt(initialDay)
        .endAt(finalDay);
    snapshotRevenue.get().then((snap) {
      if (snap.children.isNotEmpty) {
        qtdSpending = snap.children.length;
        var control;
        for (var element in snap.children) {
          control = element.value as Map<dynamic, dynamic>;

          spending += double.tryParse(control['value'])!;
        }
      }
    }).then((x) {
      int controlExibSpending = 1;
      if (type == "Gastos") {
        controlExibSpending = -1;
      }
      setState(() {
        _tTotal.text = valueTotal.toString();
        _tMediaTotal.text = (valueTotal /
                double.tryParse(listServiceProductorSpendingLenght.toString())!)
            .toStringAsFixed(2);
        _tReceita.text =
            (controlExibSpending * (valueTotal - spending)).toString();
        _tReceitaMedia.text = (controlExibSpending *
                (valueTotal - spending) /
                (qtdSpending + listServiceProductorSpendingLenght))
            .toStringAsFixed(2);
      });
    });
  }

  getFilteredYield(String subType, String initialDay, String finalDay) {
    var snapshot = ref
        .child('Venda')
        .orderByChild('date')
        .startAt(initialDay)
        .endAt(finalDay);
    snapshot.get().then((snap) {
      if (snap.children.isEmpty) {
        setState(() {
          listServiceProductorSpendingLenght = 0;
        });
      } else {
        valueTotal = 0.0;
        var control;
        List? specificSearch = List.empty(growable: true);
        for (var element in snap.children) {
          control = element.value as Map<dynamic, dynamic>;

          if (control['name'] == subType) {
            specificSearch.add(control);
            valueTotal += double.tryParse(control['value'])!;
          }
        }
        // var temp = snap.value as Map<dynamic, dynamic>;
        if (specificSearch.isNotEmpty) {
          listServiceProductorSpending = specificSearch;
          listServiceProductorSpendingLenght = specificSearch.length;
        } else {
          setState(() {
            listServiceProductorSpendingLenght = 0;
          });
        }
      }
    }).then((v) {
      if (listServiceProductorSpendingLenght != 0) {
        getSpending("Venda", initialDay, finalDay);
      }
    });
  }

  getSubTypeSearch() {
    var snapshot = ref.child('Serviço');
    snapshot.get().then((snap) {
      var temp = snap.value as Map<dynamic, dynamic>;
      subTypesSearch = temp.values.toList();
    }).then((s) {
      var snapshot = ref.child('Produto');
      snapshot.get().then((snap2) {
        var temp = snap2.value as Map<dynamic, dynamic>;
        var initialSubTypeSearch = {'name': 'Todas'};
        subTypesSearch += temp.values.toList();
        subTypesSearch.add(initialSubTypeSearch);
        subTypeSearch = subTypesSearch.last['name'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Visibility(
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildDropDownOptionSearchType(),
                    Visibility(
                        visible: typeSearch == 'Vendas' ? true : false,
                        child: _buildDropDownOptionSearchSubType()),
                    Text(
                      "INFORME O PERÍODO",
                      style: style,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text("De", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Dia",
                                _tDayInitial,
                                TextInputType.number,
                                true,
                                2,
                                _validateInputNumberDay)),
                        Flexible(
                          child: Text("/", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Mês",
                                _tMonthInitial,
                                TextInputType.number,
                                true,
                                2,
                                _validateInputNumberMonth)),
                        Flexible(
                          child: Text("/", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Ano",
                                _tYearInitial,
                                TextInputType.number,
                                true,
                                4,
                                _validateInputNumberYear))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: Text("Até", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Dia",
                                _tDayFinal,
                                TextInputType.number,
                                true,
                                2,
                                _validateInputNumberDay)),
                        Flexible(
                          child: Text("/", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Mês",
                                _tMonthFinal,
                                TextInputType.number,
                                true,
                                2,
                                _validateInputNumberMonth)),
                        Flexible(
                          child: Text("/", style: style),
                        ),
                        Flexible(
                            child: _TextFormFieldInput(
                                "Ano",
                                _tYearFinal,
                                TextInputType.number,
                                true,
                                4,
                                _validateInputNumberYear))
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    _optionButton("Buscar", 0xff3ff51b5),
                  ],
                )),
          ),
          Material(
            child: listServiceProductorSpendingLenght == 0
                ? Text(
                    emptyService,
                    style: style,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: listServiceProductorSpendingLenght,
                    itemBuilder: (context, index) {
                      if (listServiceProductorSpendingLenght == 0) {
                        return Text(
                          emptyService,
                          style: style,
                        );
                      } else {
                        return _listItem(
                            listServiceProductorSpending[index]['name'],
                            dateFormat(
                                listServiceProductorSpending[index]['date']),
                            listServiceProductorSpending[index]['value']);
                      }
                    }),
          ),
          Row(
            children: <Widget>[
              Flexible(child: _listItem("Total", "", "")),
              Flexible(
                  child: _TextFormFieldInput("Total", _tTotal,
                      TextInputType.number, false, 40, _validateInputNumber))
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(child: _listItem("Média T.", "", "")),
              Flexible(
                  child: _TextFormFieldInput("Média Total", _tMediaTotal,
                      TextInputType.number, false, 40, _validateInputNumber))
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(child: _listItem("Receita", "", "")),
              Flexible(
                  child: _TextFormFieldInput("Receita", _tReceita,
                      TextInputType.number, false, 40, _validateInputNumber))
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: _listItem("Média R.", "", "")),
              Expanded(
                  child: _TextFormFieldInput("Receita Média", _tReceitaMedia,
                      TextInputType.number, false, 40, _validateInputNumber))
            ],
          )
        ],
      )),
    ));
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
          if (!_formKey.currentState!.validate()) {
            return;
          } else {
            String initialDay =
                _tDayInitial.text + _tMonthInitial.text + _tYearInitial.text;
            String finalDay =
                _tDayFinal.text + _tMonthFinal.text + _tYearFinal.text;
            try {
              if (typeSearch == "Vendas" && subTypeSearch != "Todas") {
                getFilteredYield(subTypeSearch, initialDay, finalDay);
              } else {
                getCompleteYield(typeSearch, initialDay, finalDay);
              }
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

  _listItem(String name, String date, String value) {
    return Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(name,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(date,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text("R\$" + value,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ));
  }

  _buildDropDownOptionSearchType() {
    return DropdownButton<String>(
        value: typeSearch,
        items: typesSearch.map((val) {
          return DropdownMenuItem(
              child: Text(
                val,
                style: style,
              ),
              value: val);
        }).toList(),
        onChanged: (option) {
          setState(() {
            typeSearch = option.toString();
          });
        });
  }

  _buildDropDownOptionSearchSubType() {
    return DropdownButton(
        value: subTypeSearch,
        items: subTypesSearch.map((val) {
          return DropdownMenuItem(
              child: Text(
                val['name'],
                style: style,
              ),
              value: val['name']);
        }).toList(),
        onChanged: (option) {
          setState(() {
            subTypeSearch = option.toString();
          });
        });
  }

  _TextFormFieldInput(
      String name,
      TextEditingController controller,
      TextInputType type,
      bool enable,
      int maxLength,
      String? Function(String?)? func) {
    return TextFormField(
      buildCounter: (BuildContext context,
              {int? currentLength, int? maxLength, bool? isFocused}) =>
          null,
      enabled: enable,
      //usando operador ternario para ver qual validador usar.
      validator: func,
      controller: controller,
      keyboardType: type,
      obscureText: false,
      style: style,
      maxLength: maxLength,
      decoration: InputDecoration(
          labelText: name,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: name,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (change) {
        if (!_formKey.currentState!.validate()) {
          return;
        }
      },
    );
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

  @override
  void initState() {
    typeSearch = typesSearch.first;
    subTypeSearch = "Todas";
    listServiceProductorSpendingLenght = 0;
    // TODO: implement initState
    //getFilteredYield('Barba', '01012020', '18082022');
    getSubTypeSearch();
    super.initState();
  }
}
