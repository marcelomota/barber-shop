import 'package:barber_shop_araujo/screens/spendingpage.dart';
import 'package:barber_shop_araujo/screens/managementpage.dart';
import 'package:barber_shop_araujo/screens/servicepage.dart';
import 'package:barber_shop_araujo/screens/productpage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        _optionButton("Serviço", 0xff007aff),
        const SizedBox(
          height: 10,
        ),
        _optionButton("Produto", 0xff007aff),
        const SizedBox(
          height: 10,
        ),
        _optionButton("Gastos", 0xff007aff),
        const SizedBox(
          height: 10,
        ),
        _optionButton("Gerenciamento", 0xff007aff)
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
          optionMenu(context, nameButton);
        },
        child: Text(nameButton,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  optionMenu(BuildContext context, String nameButton) {
    if (nameButton == "Gastos") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SpendingPage()));
    } else if (nameButton == "Serviço") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ServicePage()));
    } else if (nameButton == "Produto") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProductPage()));
    } else if (nameButton == "Gerenciamento") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ManagementPage()));
    }
  }
}
