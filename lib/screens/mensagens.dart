import 'package:flutter/material.dart';
import 'dart:io';
import 'package:whatsapp2/model/mensagem.dart';
import 'package:whatsapp2/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Mensagens extends StatefulWidget {
  final Usuario contato;

  const Mensagens(this.contato, {super.key});

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {


  bool _subindoImagem = false;
  String _idUsuarioLogado = "";
  String _idUsuarioDestinatario = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      //Salvar mensagem pro remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      // Salvar mensagem pro destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {

    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    XFile? imagemEscolhida = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imagemEscolhida != null) {
      setState(() {
        _subindoImagem = true;
      });

      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference pastaRaiz = storage.ref();
      Reference arquivo = pastaRaiz
          .child("mensagens")
          .child(_idUsuarioLogado)
          .child(nomeImagem + ".jpg");

      File file = File(imagemEscolhida.path);
      UploadTask task = arquivo.putFile(file);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            _subindoImagem = true;
          });
        } else if (snapshot.state == TaskState.success) {
          String url = await snapshot.ref.getDownloadURL();

          Mensagem mensagem = Mensagem();
          mensagem.idUsuario = _idUsuarioLogado;
          mensagem.mensagem = "";
          mensagem.urlImagem = url;
          mensagem.tipo = "imagem";

          // Salvar mensagem para o remetente
          _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

          // Salvar mensagem para o destinatário
          _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

          setState(() {
            _subindoImagem = false;
          });
        }
      }, onError: (e) {
        print("Erro ao enviar a imagem: $e");
        setState(() {
          _subindoImagem = false;
        });
      });
    }
  }


  _recuperarDadosUsuario() async {
    User? usuarioLogado = await auth.currentUser;
    if (usuarioLogado != null) {
      setState(() {
        _idUsuarioLogado = usuarioLogado.uid;
        _idUsuarioDestinatario = widget.contato.idUsuario;
      });
    }
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Digite uma mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                  prefixIcon:
                  _subindoImagem ? CircularProgressIndicator()
                  : IconButton(icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        _enviarFoto();
                      },
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              _enviarMensagem();
            },
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
          ),
        ],
      ),
    );

    var streamMensagens = StreamBuilder(
      stream: db
          .collection("mensagens")
          .doc(_idUsuarioLogado)
          .collection(_idUsuarioDestinatario)
          .orderBy("timestamp")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                Text("Carregando mensagens"),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Expanded(
            child: Text("Erro ao carregar dados!"),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Expanded(
            child: Center(child: Text("Sem mensagens")),
          );
        }

        QuerySnapshot querySnapshot = snapshot.data!;
        List<DocumentSnapshot> mensagens = querySnapshot.docs.toList();

        return Expanded(
          child: ListView.builder(
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                DocumentSnapshot item = mensagens[index];
                double larguraContainer =
                    MediaQuery.of(context).size.width * 0.8;

                // Definir cores e alinhamentos
                Alignment alinhamento = Alignment.centerRight;
                Color cor = Color(0xffd2ffa5);
                if (_idUsuarioLogado != item["idUsuario"]){
                  alinhamento = Alignment.centerLeft;
                  cor = Colors.white;
                }

                return Align(
                  alignment: alinhamento,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      width: larguraContainer,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cor,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child:
                      item["tipo"] == "texto"
                          ? Text(item["mensagem"], style: TextStyle(fontSize: 18),)
                          : Image.network(item["urlImagem"]),
                    ),
                  ),
                );
              }),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null
                  ? NetworkImage(widget.contato.urlImagem)
                  : null,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                widget.contato.nome,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xff075E54),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                streamMensagens,
                caixaMensagem,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
