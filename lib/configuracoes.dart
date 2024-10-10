import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();

  XFile? _imagem;
  XFile? imagemEscolhida;
  String _idUsuarioLogado = "";
  bool _subindoImagem = false;
  String _urlImagemRecuperada = "";


  Future _recuperarImagem(bool fromCamera) async {
    if (fromCamera) {
      imagemEscolhida =
          await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      imagemEscolhida =
          await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _imagem = imagemEscolhida;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("perfil")
        .child( _idUsuarioLogado +".jpg");

    File file = File(_imagem!.path);
    UploadTask task = arquivo.putFile(file);

    task.snapshotEvents.listen((TaskSnapshot snapshot) async{
      if ( snapshot.state == TaskState.running ){
        setState(() {
          _subindoImagem = true;
        });

      } else if ( snapshot.state == TaskState.success ){
        String url = await snapshot.ref.getDownloadURL();
        _atualizarImagemFirestore( url );
        setState(() {
          _subindoImagem = false;
          _urlImagemRecuperada = url;
        });
      }
    }, onError: (e){
      print("Error");
      setState(() {
        _subindoImagem = false;
      });
    });

  }

  Future _recuperarDadosUsuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    if (usuarioLogado != null){
      _idUsuarioLogado = usuarioLogado.uid;

      FirebaseFirestore db = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await db.collection("usuarios")
          .doc(_idUsuarioLogado)
          .get();

      Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
      _controllerNome.text = dados["nome"] ?? "";

      if (dados["urlImagem"] != null){
        _urlImagemRecuperada = dados["urlImagem"];
      }
    }

  }

  _atualizarImagemFirestore( String url ){

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map <String, dynamic> dadosAtualizar = {
      "urlImagem": url
    };

    db.collection("usuarios")
    .doc(_idUsuarioLogado)
    .update(dadosAtualizar);

  }

  _atualizarNomeFirestore(){

    String nome = _controllerNome.text;
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map <String, dynamic> dadosAtualizar = {
      "nome": nome
    };

    db.collection("usuarios")
        .doc(_idUsuarioLogado)
        .update(dadosAtualizar);

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff075E54),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // carregando
               Container(
                 padding: EdgeInsets.all(16),
                 child: _subindoImagem
                     ? const CircularProgressIndicator()
                     : Container(),
               ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada.isNotEmpty
                    ? NetworkImage(_urlImagemRecuperada)
                     : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _recuperarImagem(true);
                      },
                      child: Text("Camera"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _recuperarImagem(false);
                      },
                      child: Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
