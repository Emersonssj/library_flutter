import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:livraria/models/usuario_model.dart';
import 'package:livraria/models/livro_model.dart';
import '../../main.dart';
import 'package:livraria/widgets/chamar_pesquisa_livro.dart';
import 'package:livraria/widgets/chamar_pesquisa_usuario.dart';

class AddAluguel extends StatefulWidget {
  const AddAluguel({Key? key}) : super(key: key);

  @override
  State<AddAluguel> createState() => _AddAluguelState();
}

class _AddAluguelState extends State<AddAluguel> {
  late Usuario selectedUsuario;
  late Livros selectedLivro;

  bool flagEntrega = false;
  bool flagLivro = false;
  bool flagUsuario = false;

  DateTime dataAluguel = DateTime.now();
  DateTime dataPrevisao = DateTime.now();
  DateTime? newDate = null;

  final controllerLivro = TextEditingController();
  final controllerUsuario = TextEditingController();
  final controllerDataAluguel = TextEditingController();
  final controllerDataPrevisao = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            TextFormField(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ChamarPesquisaLivro(
                    whenLivroSelected: (value) {
                      flagLivro = true;
                      controllerLivro.text = value.nome.toString();
                      selectedLivro = value;
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              readOnly: true,
              controller: controllerLivro,
              decoration: InputDecoration(
                  labelText: "Selecione o livro", prefixIcon: Icon(Icons.book)),
            ),
            TextFormField(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ChamarPesquisaUsuario(
                    whenUsuarioSelected: (value) {
                      flagUsuario = true;
                      controllerUsuario.text = value.nome.toString();
                      selectedUsuario = value;
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              readOnly: true,
              controller: controllerUsuario,
              decoration: InputDecoration(
                  labelText: "Selecione o usuário",
                  prefixIcon: Icon(Icons.person)),
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
        if (value != null) {
          flagEntrega = true;
        }
      });
      controllerDataPrevisao.text = DateFormat('dd/MM/yyyy').format(dataPrevisao);
    });
    if (newDate == null) {
      return;
    }
  }

  void criarAluguel() async {
    if (flagEntrega == true && flagUsuario == true && flagLivro == true) {
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
            "livro_id": selectedLivro.toMap(),
            "usuario_id": selectedUsuario.toMap(),
          }),
          headers: {'content-type': 'application/json'},
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text('O livro foi alugado!')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Preencha todos os campos!'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
