import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:livraria/pages/livros/add_livros.dart';
import 'package:livraria/pages/livros/livros_controller.dart';
import 'editar_livros.dart';

class livros extends StatefulWidget {
  const livros({Key? key}) : super(key: key);

  @override
  State<livros> createState() => _livrosState();
}

class _livrosState extends State<livros> {
  bool loadingLivros = true;
  final baseurl = 'livraria--back.herokuapp.com';
  final livrosData = <Livros>[];
  List <Livros> livrosListForSearch = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLivros().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadingLivros
          ? Center(
              child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Colors.black87,
                    backgroundColor: Colors.grey,
                  )))
          :
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(9, 12, 9, 4),
                  child: TextField(
                    onChanged: searchLivro,
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Pesquisa',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black87)),
                    ),
                  ),
                ),
                Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final itemLivrosList = livrosListForSearch[index];
                      return ListTile(
                        leading: Icon(Icons.menu_book_outlined, size: 48.0),
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    itemLivrosList.nome,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.person),
                                Text(itemLivrosList.autor),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.apartment_outlined),
                                Expanded(
                                    child:
                                        AutoSizeText(itemLivrosList.editora.nome)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                itemLivrosList.quantidade != 0
                                    ? Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.transparent),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                        child: Text(
                                          'Disponível',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      )
                                    : Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.transparent),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                        child: Text(
                                          'Indisponivel',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      )
                              ],
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            child: editarLivros(livro: itemLivrosList),
                            type: PageTransitionType.size,
                            alignment: Alignment.center,
                          ),
                        ),
                      );
                    },
                    padding: EdgeInsets.all(16),
                    separatorBuilder: (_, __) => Divider(color: Colors.black),
                    itemCount: livrosListForSearch.length),
          ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: const addLivros(),
            type: PageTransitionType.size,
            alignment: Alignment.center,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> loadLivros() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/livros');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      livrosData.addAll(data.map((e) => Livros.fromMap(e)));
    }
    setState(() => loadingLivros = false);
    livrosListForSearch = livrosData;
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
}
