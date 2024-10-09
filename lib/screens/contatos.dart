import 'package:flutter/material.dart';
import 'package:whatsapp2/model/conversa.dart';


class Contatos extends StatefulWidget {
  const Contatos({super.key});

  @override
  State<Contatos> createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {

  List<Conversa> listaConversa = [
    Conversa(
        "Mariana",
        "Ei puta",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-ef80a.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=c8b70a04-6066-44d3-a85a-8bb671740de7"
    ),
    Conversa(
        "Jorjino",
        "Eae caba",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-ef80a.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=539a498b-0dc4-401c-a324-182eb72a3bde"
    ),
    Conversa(
        "Dona Florinda",
        "Oi neto querido",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-ef80a.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=c794ca8c-b431-406d-8ad2-1750903accb6"
    ),
    Conversa(
        "Jorjeno",
        "Vamo pra lá?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-ef80a.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=d3ba07e5-2a3d-4859-a76b-521e8f3d8337"
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listaConversa.length,
        itemBuilder: (context, index){

          Conversa conversa = listaConversa[index];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage( conversa.caminhoFoto ),
            ),
            title: Text(
              conversa.nome,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          );

        }
    );
  }
}
