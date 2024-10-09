import 'package:flutter/material.dart';
import 'package:whatsapp2/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp2/screens/contatos.dart';
import 'package:whatsapp2/screens/conversas.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  String _emailUsuario = "";

  Future _recuperarDadosUsuario() async{

    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    if (usuarioLogado != null){
      setState(() {
        _emailUsuario = usuarioLogado.email ?? "Email nao disponivel";
      });
    } else{
      _emailUsuario = "Usuario não logado";
    }

  }

  @override
  void initState() {

    _recuperarDadosUsuario();
    super.initState();

    _tabController = TabController(
        length: 2,
        vsync: this
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("WhatsApp", style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xff075E54),
        bottom: TabBar(
          indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(
                text: "Conversas",
              ),
              Tab(
                text: "Contatos",
              ),
            ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
          children: [
            Conversas(),
            Contatos(),
          ],
      ),
    );
  }
}
