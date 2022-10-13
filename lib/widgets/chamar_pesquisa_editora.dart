import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/models/editora_model.dart';

class ChamarPesquisaEditora extends StatefulWidget {
  const ChamarPesquisaEditora({Key? key, required this.whenEditoraSelected})
      : super(key: key);
  final ValueChanged<Editora> whenEditoraSelected;

  @override
  State<ChamarPesquisaEditora> createState() => _ChamarPesquisaEditoraState();
}

class _ChamarPesquisaEditoraState extends State<ChamarPesquisaEditora> {
  final editoras = <Editora>[];
  List<Editora> editorasListForSearch = [];

  @override
  void initState() {
    super.initState();
    loadEditoras().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Selecione a editora'),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: searchEditora,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Pesquisa',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .67,
                width: MediaQuery.of(context).size.width - 10,
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) =>
                      _buildItem(editorasListForSearch[index]),
                  separatorBuilder: (_, __) => Divider(color: Colors.black),
                  itemCount: editorasListForSearch.length,
                ),
              ),
            ],
          ),
        ),
        actions: [],
      ),
    );
  }

  Widget _buildItem(Editora editora) {
    return ListTile(
      leading: Icon(Icons.account_circle, size: 27.0),
      title: Text(
        editora.nome,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            editora.cidade,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      onTap: () => widget.whenEditoraSelected(editora),
    );
  }

  void searchEditora(String query) {
    final suggestionn = editoras.where((itemEditorasList) {
      final itemProcurado = itemEditorasList.nome.toLowerCase() +
          itemEditorasList.cidade.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => editorasListForSearch = suggestionn);
  }

  Future<void> loadEditoras() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/editoras');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      editoras.addAll(data.map((e) => Editora.fromMap(e)));
    }
    editorasListForSearch = editoras;
  }
}