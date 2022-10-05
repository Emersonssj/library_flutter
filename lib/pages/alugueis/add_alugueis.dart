import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:livraria/pages/usuarios/usuarios_controller.dart';
import 'package:livraria/pages/livros/livros_controller.dart';
import 'package:validatorless/validatorless.dart';

import '../../main.dart';

class addUsuarios extends StatefulWidget {
  const addUsuarios({Key? key}) : super(key: key);

  @override
  State<addUsuarios> createState() => _addUsuariosState();
}

class _addUsuariosState extends State<addUsuarios> {
  bool flagLivro = false;
  bool flagUsuario = false;
  bool flagEntrega = false;
  final usuarios = <Usuario>[];
  final livrosDisponiveis = <Livros>[];
  Usuario? valueOfDropDownButtonUsuarios;
  Livros? valueOfDropDownButtonLivros;
  DateTime dataAluguel = DateTime.now();
  DateTime dataPrevisao = DateTime.now();
  DateTime? newDate = null;
  final controllerDataAluguel = TextEditingController();
  final controllerDataPrevisao = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLivrosDisponiveis().then((value) {
      setState(() {});
    });
    loadUsuarios().then((value) {
      setState(() {});
    });
    controllerDataAluguel.text = DateFormat('dd/MM/yyyy').format(dataAluguel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Aluguel'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 6),
              child: DropdownButton<Livros>(
                menuMaxHeight: 250,
                hint: Text('Selecione o Livro'),
                isExpanded: true,
                iconSize: 30,
                value: valueOfDropDownButtonLivros,
                items: buildMenuItemLivro(livrosDisponiveis),
                onChanged: (valueOfDropDownButtonLivros) => setState(() {
                  this.valueOfDropDownButtonLivros =
                      valueOfDropDownButtonLivros;
                  flagLivro = true;
                }),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 6),
              child: DropdownButton<Usuario>(
                  menuMaxHeight: 250,
                  hint: Text('Selecione o Usuário'),
                  isExpanded: true,
                  iconSize: 30,
                  value: valueOfDropDownButtonUsuarios,
                  items: buildMenuItemUsuario(usuarios),
                  onChanged: (valueOfDropDownButtonUsuarios) => setState(() {
                        this.valueOfDropDownButtonUsuarios =
                            valueOfDropDownButtonUsuarios;
                        flagUsuario = true;
                      })),
            ),
            TextFormField(
              readOnly: true,
              controller: controllerDataAluguel,
              decoration: InputDecoration(
                  labelText: "Data do aluguel",
                  prefixIcon: Icon(Icons.date_range)),
            ),
            TextFormField(
              readOnly: true,
              onTap: chamarDataPicker,
              controller: controllerDataPrevisao,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: "Previsão de entrega",
                  prefixIcon: Icon(Icons.date_range)),
              validator: (value) {
                if (value == '') {
                  return 'Campo Obrigatorio!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: criarAluguel,
        child: const Icon(Icons.save),
      ),
    );
  }

  chamarDataPicker() async {
    newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        dataPrevisao = value!;
        if(value!=null){flagEntrega=true;}
      });
      controllerDataPrevisao.text = DateFormat('dd/MM/yyyy').format(dataPrevisao);
      print(flagEntrega);
    });
    if (newDate == null) {
      return;
    }
  }

  List<DropdownMenuItem<Livros>> buildMenuItemLivro(List<Livros> livrosData) =>
      livrosData
          .map((livro) =>
              DropdownMenuItem(value: livro, child: Text(livro.nome)))
          .toList();

  List<DropdownMenuItem<Usuario>> buildMenuItemUsuario(
          List<Usuario> usuarios) =>
      usuarios
          .map((usuario) =>
              DropdownMenuItem(value: usuario, child: Text(usuario.nome)))
          .toList();

  Future<void> loadUsuarios() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/usuarios');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      usuarios.addAll(data.map((e) => Usuario.fromMap(e)));
    }
  }

  Future<void> loadLivrosDisponiveis() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/disponiveis');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      livrosDisponiveis.addAll(data.map((e) => Livros.fromMap(e)));
    }
  }

  void criarAluguel() async {
    if (flagEntrega == true && flagLivro == true && flagUsuario == true) {
      controllerDataAluguel.text = DateFormat('yyyy-MM-dd').format(dataAluguel);
      controllerDataPrevisao.text = DateFormat('yyyy-MM-dd').format(dataPrevisao);

      var uri = Uri.http('livraria--back.herokuapp.com', 'api/aluguel');
      try {
        final response = await http.post(
          uri,
          body: jsonEncode({
            "data_aluguel": controllerDataAluguel.text,
            "data_devolucao": '',
            "data_previsao": controllerDataPrevisao.text,
            "livro_id": valueOfDropDownButtonLivros!.toMap(),
            "usuario_id": valueOfDropDownButtonUsuarios!.toMap(),
          }),
          headers: {'content-type': 'application/json'},
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('O livro foi alugado!')));
        print(response.body);
      } catch (er) {
        print(er);
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    title: 'Livraria WDA',
                    pageId: 4,
                  )),
          (route) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Preencha todos os campos!'), backgroundColor: Colors.red,));
    }
  }
}
