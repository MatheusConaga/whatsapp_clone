import 'package:flutter/material.dart';
import 'package:whatsapp2/cadastro.dart';
import 'package:whatsapp2/configuracoes.dart';
import 'package:whatsapp2/home.dart';
import 'package:whatsapp2/login.dart';
import 'package:whatsapp2/model/usuario.dart';
import 'package:whatsapp2/screens/mensagens.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => Login());
      case Routes.cadastro:
        return MaterialPageRoute(builder: (_) => Cadastro());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => Home());
      case Routes.configuracoes:
        return MaterialPageRoute(builder: (_) => Configuracoes());
      case Routes.mensagens:
        if (settings.arguments != null && settings.arguments is Usuario) {
          final args = settings.arguments as Usuario;
          return MaterialPageRoute(builder: (_) => Mensagens(args));
        } else {
          return _erroRota();
        }
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tela não encontrada!"),
        ),
        body: const Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}

class Routes {
  static const String login = "/";
  static const String cadastro = "/cadastro";
  static const String home = "/home";
  static const String configuracoes = "/configuracoes";
  static const String mensagens = "/mensagens";
}
