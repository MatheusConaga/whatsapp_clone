import 'package:flutter/material.dart';
import 'package:whatsapp2/model/conversa.dart';
import 'package:whatsapp2/model/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp2/routes/routeGenerator.dart';

class Contatos extends StatefulWidget {
  const Contatos({super.key});

  @override
  State<Contatos> createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {
  String _idUsuarioLogado = "";
  String _emailUsuarioLogado = "";

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsuarios = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>?;
      if (dados != null) {
        if ( dados["email"] == _emailUsuarioLogado ) continue;
        Usuario usuario = Usuario();
        usuario.idUsuario = item.id;
        usuario.email = dados["email"] ?? "";
        usuario.nome = dados["nome"] ?? "";
        usuario.urlImagem = dados["urlImagem"] ?? "";

        listaUsuarios.add(usuario);
      } else {
        print("Dados do documento são null para o documento: ${item.id}");
      }
    }
    return listaUsuarios;
  }

  Future _recuperarDadosUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    if (usuarioLogado != null){
      _idUsuarioLogado = usuarioLogado.uid;
      _emailUsuarioLogado = usuarioLogado.email ?? "";
    }

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo
              children: [
                Text("Carregando contatos"),
                CircularProgressIndicator()
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Erro ao carregar contatos: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          List<Usuario> listaItens = snapshot.data!;
          return ListView.builder(
            itemCount: listaItens.length,
            itemBuilder: (_, index) {
              Usuario usuario = listaItens[index];
              return ListTile(
                onTap: (){
                  Navigator.pushNamed(context, Routes.mensagens, arguments: usuario);
                },
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                leading: CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: usuario.urlImagem != null
                      ? NetworkImage(usuario.urlImagem) // Corrigido aqui
                      : null,
                ),
                title: Text(
                  usuario.nome,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        } else {
          return Center(child: Text("Nenhum contato encontrado"));
        }
      },
    );
  }
}
