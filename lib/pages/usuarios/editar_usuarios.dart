import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:livraria/pages/usuarios/usuarios_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:validatorless/validatorless.dart';
import 'package:livraria/main.dart';

class editarUsuarios extends StatefulWidget {
  const editarUsuarios({Key? key, required this.usuario}) : super(key: key);
  final Usuario usuario;

  @override
  State<editarUsuarios> createState() => _editarUsuariosState();
}

class _editarUsuariosState extends State<editarUsuarios> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final cidadeController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cidadeController.text = widget.usuario.cidade;
    emailController.text = widget.usuario.email;
    enderecoController.text = widget.usuario.endereco;
    nomeController.text = widget.usuario.nome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Editora'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.min(3, 'Mínimo 3 caracteres')
                ]),
                controller: nomeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              TextFormField(
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.min(3, 'Mínimo 3 caracteres')
                ]),
                controller: enderecoController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Endereco",
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              TextFormField(
                controller: cidadeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Cidade", prefixIcon: Icon(Icons.location_city)),
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.min(3, 'Mínimo 3 caracteres')
                ]),
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "E-mail", prefixIcon: Icon(Icons.email)),
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.email('E-mail inválido')
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Color(0xff306BAC),
        spacing: 15,
        overlayOpacity: 0,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(child: Icon(Icons.save), onTap: atualizarUsuario),
          SpeedDialChild(child: Icon(Icons.delete), onTap: openDialog),
        ],
      ),
    );
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmação'),
          content: Text('Deletar usuário?'),
          actions: [
            TextButton(onPressed: deleteUsuario, child: Text('Sim')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Não')),
          ],
        ),
      );

  void atualizarUsuario() async {
    var formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      var uri = Uri.http('livraria--back.herokuapp.com', 'api/usuario');
      try {
        final response = await http.put(
          uri,
          body: jsonEncode({
            "cidade": cidadeController.text,
            "email": emailController.text,
            "endereco": enderecoController.text,
            "id": widget.usuario.id,
            "nome": nomeController.text,
          }),
          headers: {'content-type': 'application/json'},
        );
        if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('O email já está sendo utilizado, use outro!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content:
                  Text('O usuário ${nomeController.text} foi atualizado!')));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        title: 'Livraria WDA',
                        pageId: 0,
                      )),
              (route) => false);
        }
      } catch (er) {
        print('deu erro');
      }
    }
  }

  void deleteUsuario() async {
    var uri = Uri.http('livraria--back.herokuapp.com', 'api/usuario');
    try {
      final response = await http.delete(
        uri,
        body: jsonEncode({
          "cidade": widget.usuario.cidade,
          "email": widget.usuario.email,
          "endereco": widget.usuario.endereco,
          "id": widget.usuario.id,
          "nome": widget.usuario.nome,
        }),
        headers: {'content-type': 'application/json'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green,content: Text('O usuário ${widget.usuario.nome} foi deletado!')));
    } catch (er) {}
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 0,)),
            (route) => false
    );
  }
}
