import 'package:barber_shop_araujo/controller/size_config.dart';
import 'package:barber_shop_araujo/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = const TextStyle(fontFamily: 'Poppins', fontSize: 20.0);
  String login = "";
  final _tLogin = TextEditingController();
  final _tPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateLogin(String? text) {
    if (text == null || !text.contains("@")) {
      return "Informe um login valido";
    }
    return null;
  }

  String? _validatePassword(String? text) {
    if (text == null || text.length < 3) {
      return "Informe a senha";
    }
    return null;
  }

  _onNavigatorHomePage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  _onClickLoginButton(BuildContext context) async {
    //print(_formKey.currentState);

    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _tLogin.text, password: _tPassword.text);
    } on FirebaseAuthException catch (err) {
      showDialog(
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

    // try {
    //   var user = "araujo@"; //UserAutentication user =
    //   //     await LoginApi.login(_tLogin.text, _tPassword.text);

    //   // if (_tLogin.text == "araujo@") {
    //   //   login = user;

    //   //   _onNavigatorHomePage(context);
    //   // } else {
    //   //   showDialog(
    //   //       context: context,
    //   //       builder: (context) {
    //   //         return AlertDialog(
    //   //           title: Text("Erro ao logar:"),
    //   //           content: Text("Login ou senha inválidos"),
    //   //           actions: <Widget>[
    //   //             RawMaterialButton(
    //   //                 child: Text("ok"),
    //   //                 onPressed: () {
    //   //                   Navigator.pop(context);
    //   //                 })
    //   //           ],
    //   //         );
    //   //       });
    //   // }
    // } on Exception catch (e) {
    //   showDialog(
    //       context: context,
    //       builder: (context) {
    //         return AlertDialog(
    //           title: Text(e.toString()),
    //           actions: <Widget>[
    //             RawMaterialButton(
    //                 child: Text("ok"),
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 })
    //           ],
    //         );
    //       });
    // }
  }

  textFormFieldLogin() {
    return TextFormField(
      controller: _tLogin,
      validator: _validateLogin,
      keyboardType: TextInputType.emailAddress,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  textFormFieldPassword() {
    return TextFormField(
      controller: _tPassword,
      validator: _validatePassword,
      keyboardType: TextInputType.text,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  buttonLogin() {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: const Color(0xff007aff),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _onClickLoginButton(context);
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  _body(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(
                height: SizeConfig(mediaQueryData: MediaQuery.of(context))
                    .dynamicScaleSize(size: 50),
                child: Text("BARBERARIA ARAúJO",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:
                            SizeConfig(mediaQueryData: MediaQuery.of(context))
                                .dynamicScaleSize(size: 30),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
            SizedBox(
                height: SizeConfig(mediaQueryData: MediaQuery.of(context))
                    .dynamicScaleSize(size: 100)),
            textFormFieldLogin(),
            SizedBox(
                height: SizeConfig(mediaQueryData: MediaQuery.of(context))
                    .dynamicScaleSize(size: 15)),
            textFormFieldPassword(),
            SizedBox(
                height: SizeConfig(mediaQueryData: MediaQuery.of(context))
                    .dynamicScaleSize(size: 25)),
            buttonLogin()
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: LayoutBuilder(
                builder: (context, constrans) {
                  return _body(context);
                },
              )),
        ),
      ),
    );
  }
}
