import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:validatorless/validatorless.dart';
import 'package:livraria/main.dart';

import 'editoras.dart';

class addEditoras extends StatefulWidget {
  const addEditoras({Key? key}) : super(key: key);

  @override
  State<addEditoras> createState() => _addEditorasState();
}

class _addEditorasState extends State<addEditoras> {

  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cidadeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Editora'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children:<Widget> [
              TextFormField(
                controller: nomeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(Icons.work),
                ),
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
              ),
              TextFormField(
                controller: cidadeController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Cidade",
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: postData,
        child: const Icon(Icons.save),
      ),
    );
  }

  void postData()async{
    var formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      String nome = nomeController.text;
      String cidade = cidadeController.text;

      var uri = Uri.http('livraria--back.herokuapp.com', 'api/editora');
      try {
        final response = await http.post(
          uri,
          body: jsonEncode({
            "cidade": "$cidade",
            "nome": "$nome",
          }),
          headers: {'content-type': 'application/json'},
        );
        print(response.statusCode);
        print(response.body);

        if(response.statusCode == 400){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.red, content: Text('O nome já está sendo utilizado, use outro!')));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor:Colors.green, content: Text('A editora $nome foi criada!')));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 1,)),
                  (route) => false
          );
        }
      } catch (er) {
        print('deu erro');
      }
    }
  }
}