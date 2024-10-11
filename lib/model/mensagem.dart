import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  String _idUsuario = "";
  String _mensagem = "";
  String _urlImagem = "";
  String _tipo = "";
  Timestamp timestamp; // Mantém a definição do tipo Timestamp

  // Construtor corrigido
  Mensagem({
    String? idUsuario,
    String? mensagem,
    String? urlImagem,
    String? tipo,
    Timestamp? timestamp,
  })  : _idUsuario = idUsuario ?? "", // Inicializa idUsuario
        _mensagem = mensagem ?? "", // Inicializa mensagem
        _urlImagem = urlImagem ?? "", // Inicializa urlImagem
        _tipo = tipo ?? "", // Inicializa tipo
        timestamp = timestamp ?? Timestamp.now(); // Inicializa timestamp

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo": this.tipo,
      "timestamp": timestamp,
    };
    return map;
  }

  // Getters e Setters
  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }
}
