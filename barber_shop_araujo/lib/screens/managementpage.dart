//Cadastrar novo serviço
//Cadastrar novo produto
//Gerência em geral
import 'package:barber_shop_araujo/screens/createServiceOrProduct.dart';
import 'package:barber_shop_araujo/screens/yieldpage.dart';
import 'package:flutter/material.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _body(context);
        },
      ),
    )));
  }

  _body(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: <Widget>[
        _TextView("CADASTRAMENTO DE PRODUTO/SERVIÇO"),
        _optionButton("Cadastrar", 0xff007aff),
        const SizedBox(
          height: 10,
        ),
        _TextView("GERENCIAMENTO"),
        _optionButton("Faturamento", 0xff007aff),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  _optionButton(String nameButton, int colorButton) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(colorButton),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          sellProductOrService(context, nameButton);
        },
        child: Text(nameButton,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  _TextView(String text) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30.0,
            fontWeight: FontWeight.bold));
  }

  sellProductOrService(BuildContext context, String nameButton) {
    if (nameButton == "Cadastrar") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateServiceOrProduct()));
    } else if (nameButton == "Faturamento") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => YieldPage()));
    }
  }
}
