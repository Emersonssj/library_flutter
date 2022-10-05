import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livraria/pages/alugueis/alugueis_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../main.dart';

class selectedAlugueis extends StatefulWidget {
  const selectedAlugueis({Key? key, required this.selectedAluguel})
      : super(key: key);

  final Alugueis selectedAluguel;

  @override
  State<selectedAlugueis> createState() => _selectedAlugueisState();
}

class _selectedAlugueisState extends State<selectedAlugueis> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerDataAluguel = TextEditingController();
  TextEditingController controllerPrevisao = TextEditingController();
  TextEditingController controllerDataDevolucao = TextEditingController();
  bool notDevolvido = true;
  bool atrasado = false;

  void initState() {
    super.initState();

    DateTime data1 = DateTime.parse(widget.selectedAluguel.data_aluguel);
    DateTime data2 = DateTime.parse(widget.selectedAluguel.data_previsao);


    controllerEmail.text = widget.selectedAluguel.usuario_id.email;
    controllerDataAluguel.text = DateFormat('dd/MM/yyyy').format(data1);
    controllerPrevisao.text = DateFormat('dd/MM/yyyy').format(data2);

    if (widget.selectedAluguel.data_devolucao != '') {
      notDevolvido = false;
      DateTime data3 = DateTime.parse(widget.selectedAluguel.data_devolucao);
      controllerDataDevolucao.text = DateFormat('dd/MM/yyyy').format(data3);
      if (data3.isAfter(data1)) {
        atrasado = true;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livro alugado'),
        backgroundColor: Color(0xff306BAC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            TextFormField(
              readOnly: true,
              controller: controllerEmail,
              decoration: InputDecoration(
                labelText: "Email",
                  prefixIcon: Icon(Icons.email)
              ),
            ),
            TextFormField(
              readOnly: true,
              controller: controllerDataAluguel,
              decoration: InputDecoration(
                labelText: "Data do Aluguel",
                  prefixIcon: Icon(Icons.date_range)
              ),
            ),
            TextFormField(
              readOnly: true,
              controller: controllerPrevisao,
              decoration: InputDecoration(
                labelText: "Previsão de entrega",
                  prefixIcon: Icon(Icons.date_range)
              ),
            ),
            TextFormField(
              readOnly: true,
              controller: controllerDataDevolucao,
              decoration: InputDecoration(
                labelText: "Data de devolução",
                  prefixIcon: Icon(Icons.date_range)
              ),
            ),
            SizedBox(
              height: 20,
            ),
            notDevolvido
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: openDialog,
                        icon: Icon(Icons.warning_amber_outlined),
                        label: Text('Cancelar aluguel'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (states) {
                            return Colors.red;
                          }),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: devolverLivro,
                        icon: Icon(Icons.menu_book),
                        label: Text('Devolver livro'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (states) {
                            return Colors.green;
                          }),
                        ),
                      ),
                    ],
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: atrasado
                        ? Text(
                            'Devolvido com atraso',
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(
                            'Devolvido no prazo',
                            style: TextStyle(color: Colors.blueAccent),
                          ))
          ],
        ),
      ),
    );
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmação'),
          content: Text('Cancelar aluguel?'),
          actions: [
            TextButton(onPressed: cancelarAluguel, child: Text('Sim')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Não')),
          ],
        ),
      );

  void cancelarAluguel() async {
    var uri = Uri.http('livraria--back.herokuapp.com', 'api/aluguel');
    try {
      final response = await http.delete(
        uri,
        body: jsonEncode({
          "data_aluguel": widget.selectedAluguel.data_aluguel,
          "data_devolucao": widget.selectedAluguel.data_devolucao,
          "data_previsao": widget.selectedAluguel.data_previsao,
          "id": widget.selectedAluguel.id,
          "livro_id": widget.selectedAluguel.livro_id.toMap(),
          "usuario_id": widget.selectedAluguel.usuario_id.toMap(),
        }),
        headers: {'content-type': 'application/json'},
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('O aluguel foi deletado!')));
    } catch (er) {}

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 4,)),
            (route) => false
    );
    setState(() {});
  }

  void devolverLivro() async {
    String dataDevolucao = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var uri = Uri.http('livraria--back.herokuapp.com', 'api/aluguel');
    try {
      final response = await http.put(
        uri,
        body: jsonEncode({
          "data_aluguel": widget.selectedAluguel.data_aluguel,
          "data_devolucao": dataDevolucao,
          "data_previsao": widget.selectedAluguel.data_previsao,
          "id": widget.selectedAluguel.id,
          "livro_id": widget.selectedAluguel.livro_id.toMap(),
          "usuario_id": widget.selectedAluguel.usuario_id.toMap(),
        }),
        headers: {'content-type': 'application/json'},
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('O livro foi devolvido!')));
    } catch (er) {
      print(er);
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Livraria WDA',pageId: 4,)),
            (route) => false
    );
    setState(() {
    });
  }
}
