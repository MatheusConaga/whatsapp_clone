import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp2/model/conversa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp2/model/usuario.dart';
import 'package:whatsapp2/routes/routeGenerator.dart';


class Conversas extends StatefulWidget {
  const Conversas({super.key});

  @override
  State<Conversas> createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  List<Conversa> _listaConversa = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado = "";
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();

    Conversa conversa = Conversa();
    conversa.nome = "Mariana";
    conversa.mensagem = "Ei princesa";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-ef80a.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=c8b70a04-6066-44d3-a85a-8bb671740de7";

    _listaConversa.add(conversa);
  }

  Stream <QuerySnapshot> _adicionarListenerConversas(){

    final stream = db.collection("conversas")
        .doc( _idUsuarioLogado )
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados){
      _controller.add(dados);
    });

    return stream;

  }

  _recuperarDadosUsuario() async {
    User? usuarioLogado = await auth.currentUser;
    if (usuarioLogado != null) {
      setState(() {
        _idUsuarioLogado = usuarioLogado.uid;
        _adicionarListenerConversas();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando conversas"),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError){
                return Text("Erro ao carregar dados!");
              } else{
                QuerySnapshot querySnapshot = snapshot.data!;

                if( querySnapshot.docs.length == 0){

                  return Center(
                    child: Text(
                        "Voce não tem mensagens ainda!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );

                }

                return ListView.builder(
                    itemCount: _listaConversa.length,
                    itemBuilder: (context, index) {

                      List<DocumentSnapshot> conversas = querySnapshot.docs.toList();
                      DocumentSnapshot item = conversas[index];

                      String urlImagem = item["caminhoFoto"];
                      String tipo = item["tipoMensagem"];
                      String mensagem = item["mensagem"];
                      String nome = item["nome"];
                      String idDestinatario = item["idDestinatario"];


                      Usuario usuario = Usuario();
                      usuario.nome = nome;
                      usuario.urlImagem = urlImagem;
                      usuario.idUsuario = idDestinatario;

                      return ListTile(
                        onTap: (){
                          Navigator.pushNamed(context, Routes.mensagens, arguments: usuario);
                        },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImagem!=null ?
                          NetworkImage( urlImagem )
                          : null,
                        ),
                        title: Text(
                          nome,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                        tipo == "texto"
                        ? mensagem
                          : "Imagem....",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      );
                    });

              }
          }
    });


  }
}
