import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validatorless/validatorless.dart';
import 'package:livraria/pages/usuarios/usuarios.dart';
import '../../main.dart';

class addUsuarios extends StatefulWidget {
  const addUsuarios({Key? key}) : super(key: key);

  @override
  State<addUsuarios> createState() => _addUsuariosState();
}

class _addUsuariosState extends State<addUsuarios> {

  final _formKey = GlobalKey<FormState>();
  final baseurl = 'livraria--back.herokuapp.com';
  final nomeController = TextEditingController();
  final enderecoController = TextEditingController();
  final cidadeController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Usuário'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nomeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                    prefixIcon: Icon(Icons.person)
                ),
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
              ),
              TextFormField(
                controller: enderecoController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Endereço",
                    prefixIcon: Icon(Icons.location_on)
                ),
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
              ),
              TextFormField(
                controller: cidadeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Cidade",
                    prefixIcon: Icon(Icons.location_city)
                ),
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "E-mail",
                    prefixIcon: Icon(Icons.email)
                ),
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.email('E-mail inválido')
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        child: const Icon(Icons.save),
        onPressed: postData,
      ),
    );
  }
  void postData()async{
    var formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      String cidade = cidadeController.text;
      String email = emailController.text;
      String endereco = enderecoController.text;
      String nome = nomeController.text;

      var uri = Uri.http('livraria--back.herokuapp.com', 'api/usuario');
      try {
        final response = await http.post(
          uri,
          body: jsonEncode({
            "cidade": "$cidade",
            "email": "$email",
            "endereco": "$endereco",
            "nome": "$nome",
          }),
          headers: {'content-type': 'application/json'},
        );
        print(response.statusCode);
        print(response.body);

        if(response.statusCode == 400){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.red, content: Text('O email já está sendo utilizado, use outro!')));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor:Colors.green, content: Text('O usuário $nome foi criado!')));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 0,)),
                  (route) => false
          );
        }
      } catch (er) {
      }
    }
  }
}
