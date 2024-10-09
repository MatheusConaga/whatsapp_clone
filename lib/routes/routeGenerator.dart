import 'package:flutter/material.dart';
import 'package:whatsapp2/cadastro.dart';
import 'package:whatsapp2/home.dart';
import 'package:whatsapp2/login.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => Login());
      case Routes.cadastro:
        return MaterialPageRoute(builder: (_) => Cadastro());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => Home());
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(title: Text("Tela nao encontrada!"),),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }

}

class Routes{

  static const String login = "/";
  static const String cadastro = "/cadastro";
  static const String home = "/home";

}
