import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/livro_model.dart';

class ChamarPesquisaLivro extends StatefulWidget {
  const ChamarPesquisaLivro({Key? key, required this.whenLivroSelected})
      : super(key: key);
  final ValueChanged<Livros> whenLivroSelected;

  @override
  State<ChamarPesquisaLivro> createState() => _ChamarPesquisaLivroState();
}

class _ChamarPesquisaLivroState extends State<ChamarPesquisaLivro> {
  final livrosData = <Livros>[];
  List<Livros> livrosListForSearch = [];

  @override
  void initState() {
    super.initState();
    loadLivrosDisponiveis().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Selecione o livro'),
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
                      onChanged: searchLivro,
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
                      _buildItem(livrosListForSearch[index]),
                  separatorBuilder: (_, __) => Divider(color: Colors.black),
                  itemCount: livrosListForSearch.length,
                ),
              ),
            ],
          ),
        ),
        actions: [],
      ),
    );
  }

  Widget _buildItem(Livros livro) {
    return ListTile(
      leading: Icon(Icons.menu_book_outlined, size: 27.0),
      title: Text(
        livro.nome,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            livro.autor,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            livro.editora.nome,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
      onTap: () => widget.whenLivroSelected(livro),
    );
  }

  void searchLivro(String query) {
    final suggestion = livrosData.where((itemLivrosList) {
      final itemProcurado = itemLivrosList.nome.toLowerCase() +
          itemLivrosList.autor.toLowerCase() +
          itemLivrosList.editora.nome.toLowerCase() +
          itemLivrosList.lancamento.toString();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => livrosListForSearch = suggestion);
  }

  Future<void> loadLivrosDisponiveis() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/livros');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      livrosData.addAll(data.map((e) => Livros.fromMap(e)));
    }
    livrosListForSearch = livrosData;
  }
}
