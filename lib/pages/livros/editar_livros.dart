import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:livraria/pages/livros/livros_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:livraria/pages/editoras/editoras_controller.dart';
import 'package:validatorless/validatorless.dart';
import '../../main.dart';

class editarLivros extends StatefulWidget {
  const editarLivros({Key? key, required this.livro}) : super(key: key);
  final Livros livro;

  @override
  State<editarLivros> createState() => _editarLivrosState();
}

class _editarLivrosState extends State<editarLivros> {

  final _formKey = GlobalKey<FormState>();
  final editoras = <Editora>[];
  late final List<String> items;
  Editora? valueOfDropDownButton;
  bool flagEditora = false;
  TextEditingController controllerNome = TextEditingController();
  TextEditingController controllerAutor = TextEditingController();
  TextEditingController controllerLancamento = TextEditingController();
  TextEditingController controllerQuantidade = TextEditingController();

  @override
  void initState() {
    super.initState();
    controllerNome.text = widget.livro.nome;
    controllerAutor.text = widget.livro.autor;
    controllerLancamento.text = widget.livro.lancamento.toString();
    controllerQuantidade.text = widget.livro.quantidade.toString();
    super.initState();
    loadEditoras().then((value) {
      setState(() {});
      items = editoras.map((e) => e.nome).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Livro'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children:<Widget> [
              TextFormField(
                controller: controllerNome,
                decoration: InputDecoration(
                  labelText: "Nome",
                    prefixIcon: Icon(Icons.book)
                ),
                validator: Validatorless.required('Campo obrigatório'),
              ),
              TextFormField(
                validator: Validatorless.multiple([Validatorless.required('Campo obrigatório'),Validatorless.min(3, 'Mínimo 3 caracteres')]),
                controller: controllerAutor,
                decoration: InputDecoration(
                  labelText: "Autor",
                    prefixIcon: Icon(Icons.person)
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: controllerLancamento,
                decoration: InputDecoration(
                  labelText: "Lançamento",
                    prefixIcon: Icon(Icons.date_range)
                ),
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
                keyboardType: TextInputType.number,
                controller: controllerQuantidade,
                decoration: InputDecoration(
                  labelText: "Quantidade",
                    prefixIcon: Icon(Icons.edit)
                ),
                validator: Validatorless.required('Campo obrigatório'),
              ),
              Container(
                padding: EdgeInsets.only(top: 6),
                child: DropdownButton<Editora>(
                  hint: Text('Selecione a Editora'),
                  menuMaxHeight: 250,
                  isExpanded: true,
                  iconSize: 30,
                  value: valueOfDropDownButton,
                  items: buildMenuItem(editoras),
                  onChanged: (valueOfDropDownButton) => setState(() {
                    this.valueOfDropDownButton = valueOfDropDownButton;
                    flagEditora = true;
                  }),
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
          SpeedDialChild(
            child: Icon(Icons.save),
            onTap: atualizarLivros,
          ),
          SpeedDialChild(
              child: Icon(Icons.delete),
              onTap:openDialog),
        ],
      ),
    );
  }

  Future openDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmação'),
      content: Text('Deletar livro?'),
      actions: [
        TextButton(onPressed: deleteLivros, child: Text('Sim')),
        TextButton(onPressed: () {Navigator.pop(context);}, child: Text('Não')),
      ],
    ),
  );

  void atualizarLivros() async {
    if (flagEditora == true) {
    var formValid = _formKey.currentState?.validate() ?? false;
    if (formValid) {
      var uri = Uri.http('livraria--back.herokuapp.com', 'api/livro');
      try {
        final response = await http.put(
          uri,
          body: jsonEncode({
            "autor": controllerAutor.text,
            "editora": valueOfDropDownButton!.toMap(),
            "id": widget.livro.id,
            "lancamento": controllerLancamento.text,
            "nome": controllerNome.text,
            "quantidade": controllerQuantidade.text,
            "totalalugado": widget.livro.totalalugado,
          }),
          headers: {'content-type': 'application/json'},
        );
        if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('O nome já está sendo utilizado, use outro!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content:
              Text('O livro ${controllerNome.text} foi atualizado!')));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(
                        title: 'Livraria WDA',
                        pageId: 3,
                      )),
                  (route) => false);
        }
      } catch (er) {
        print('deu erro');
      }
    }
  }else{
      var formValid = _formKey.currentState?.validate() ?? false;
      if (formValid) {}
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Preencha a Editora!')));
    }
  }

  void deleteLivros() async {
    var uri = Uri.http('livraria--back.herokuapp.com', 'api/livro');
    try {
      final response = await http.delete(
        uri,
        body: jsonEncode({
          "autor": widget.livro.autor,
          "editora": widget.livro.editora.toMap(),
          "id": widget.livro.id,
          "lancamento": widget.livro.lancamento,
          "nome": widget.livro.nome,
          "quantidade": widget.livro.quantidade,
          "totalalugado": widget.livro.totalalugado,
        }),
        headers: {'content-type': 'application/json'},
      );
      if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('Não é possível deletar um livro com associação à alugueis!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content:
            Text('O livro ${widget.livro.nome} foi deletado!')));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(
                      title: 'Livraria WDA',
                      pageId: 3,
                    )),
                (route) => false);
      }
    } catch (er) {
      print('deu erro');
    }
  }

  List <DropdownMenuItem<Editora>> buildMenuItem(List<Editora>editoras) => editoras.map((editora) =>
      DropdownMenuItem(value:editora, child:Text(editora.nome))).toList();

  Future<void> loadEditoras() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/editoras');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      editoras.addAll(data.map((e) => Editora.fromMap(e)));
    }
  }
}

