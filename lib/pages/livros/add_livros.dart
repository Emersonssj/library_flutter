import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livraria/models/editora_model.dart';
import 'package:validatorless/validatorless.dart';
import '../../main.dart';
import 'package:livraria/widgets/chamar_pesquisa_editora.dart';

class addLivros extends StatefulWidget {
  const addLivros({Key? key}) : super(key: key);

  @override
  State<addLivros> createState() => _addLivrosState();
}

class _addLivrosState extends State<addLivros> {
  final _formKey = GlobalKey<FormState>();

  late Editora selectedEditora;
  final editoras = <Editora>[];
  bool flagEditora = false;

  final autorController = TextEditingController();
  final controllerEditora = TextEditingController();
  final lancamentoController = TextEditingController();
  final nomeController = TextEditingController();
  final quantidadeController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Livro'),
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
                    labelText: "Nome", prefixIcon: Icon(Icons.book)),
              ),
              TextFormField(
                validator: Validatorless.multiple([
                  Validatorless.required('Campo obrigatório'),
                  Validatorless.min(3, 'Mínimo 3 caracteres')
                ]),
                controller: autorController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Autor", prefixIcon: Icon(Icons.person)),
              ),
              TextFormField(
                controller: lancamentoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Ano de lançamento",
                    prefixIcon: Icon(Icons.date_range)),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Campo Obrigatorio!';
                  } else if (int.parse(value) > 2022) {
                    return 'O ano deve ser anterior ou igual a 2022';
                  } else if (int.parse(value) < 999) {
                    return 'O ano deve ser posterior a 999';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Quantidade", prefixIcon: Icon(Icons.edit)),
                validator: Validatorless.required('Campo obrigatório'),
              ),
              TextFormField(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ChamarPesquisaEditora(
                      whenEditoraSelected: (value) {
                        flagEditora = true;
                        controllerEditora.text = value.nome.toString();
                        selectedEditora = value;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                readOnly: true,
                controller: controllerEditora,
                decoration: InputDecoration(
                    labelText: "Selecione a editora", prefixIcon: Icon(Icons.apartment_outlined),
                ),
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

  void postData() async {
    if (flagEditora == true) {
      var formValid = _formKey.currentState?.validate() ?? false;
      if (formValid) {
        var uri = Uri.http('livraria--back.herokuapp.com', 'api/livro');
        try {
          final response = await http.post(
            uri,
            body: jsonEncode({
              "autor": autorController.text,
              "editora": selectedEditora.toMap(),
              "lancamento": lancamentoController.text,
              "nome": nomeController.text,
              "quantidade": quantidadeController.text,
            }),
            headers: {'content-type': 'application/json'},
          );
          print(response.body);
          if(response.statusCode == 400){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text('O nome já está sendo utilizado, use outro!')));
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor:Colors.green, content: Text('O livro ${nomeController.text} foi criado!')));
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 3,)),
                    (route) => false
            );
          }
        } catch (er) {
          print('deu erro');
        }
      }
    }else{
      var formValid = _formKey.currentState?.validate() ?? false;
      if (formValid) {}
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Selecione uma Editora!')));
    }
  }

  List<DropdownMenuItem<Editora>> buildMenuItem(List<Editora> editoras) =>
      editoras
          .map((editora) =>
              DropdownMenuItem(value: editora, child: Text(editora.nome)))
          .toList();

  Future<void> loadEditoras() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/editoras');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      editoras.addAll(data.map((e) => Editora.fromMap(e)));
    }
  }
}
