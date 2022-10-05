import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:livraria/pages/editoras/editoras_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:validatorless/validatorless.dart';
import 'package:livraria/main.dart';

class editarEditoras extends StatefulWidget {
  const editarEditoras({Key? key, required this.editora}) : super(key: key);
  final Editora editora;

  @override
  State<editarEditoras> createState() => _editarEditorasState();
}

class _editarEditorasState extends State<editarEditoras> {

  final _formKey = GlobalKey<FormState>();
  final controllerNome = TextEditingController();
  final controllerCidade = TextEditingController();

  @override
  void initState() {
    super.initState();
    controllerNome.text = widget.editora.nome;
    controllerCidade.text = widget.editora.cidade;
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
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
                controller: controllerNome,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              TextFormField(
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
                controller: controllerCidade,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Cidade",
                  prefixIcon: Icon(Icons.location_city),
                ),
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
          SpeedDialChild(child: Icon(Icons.save), onTap: atualizarEditoras),
          SpeedDialChild(child: Icon(Icons.delete), onTap: openDialog),
        ],
      ),
    );
  }
  Future openDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmação'),
      content: Text('Deletar editora?'),
      actions: [
        TextButton(onPressed: deleteEditoras, child: Text('Sim')),
        TextButton(onPressed: () {Navigator.pop(context);}, child: Text('Não')),
      ],
    ),
  );

  void atualizarEditoras() async {
    var formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      var uri = Uri.http('livraria--back.herokuapp.com', 'api/editora');
      try {
        final response = await http.put(
          uri,
          body: jsonEncode({
            "cidade": controllerCidade.text,
            "id": widget.editora.id,
            "nome": controllerNome.text,
          }),
          headers: {'content-type': 'application/json'},
        );
        if(response.statusCode == 400){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.red, content: Text('O nome já está sendo utilizado, use outro!')));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor:Colors.green, content: Text('A editora ${controllerNome.text} foi atualizada!')));
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

  void deleteEditoras() async {
    var uri = Uri.http('livraria--back.herokuapp.com', 'api/editora');
    try {
      final response = await http.delete(
        uri,
        body: jsonEncode({
          "cidade": widget.editora.cidade,
          "id": widget.editora.id,
          "nome": widget.editora.nome,
        }),
        headers: {'content-type': 'application/json'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.green,content: Text('${widget.editora.nome} foi deletada!')));
    } catch (er) {
      print('deu erro');
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 1,)),
            (route) => false
    );
  }
}