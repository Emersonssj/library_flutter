import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/pages/editoras/editar_editoras.dart';
import 'package:livraria/pages/editoras/add_editoras.dart';
import 'package:livraria/pages/editoras/editoras_controller.dart';
import 'dart:convert';
import 'package:page_transition/page_transition.dart';

class editoras extends StatefulWidget {
  const editoras({Key? key}) : super(key: key);

  @override
  State<editoras> createState() => _editorasState();
}

class _editorasState extends State<editoras> {
  bool loadingEditoras = true;
  final baseurl = 'livraria--back.herokuapp.com';
  final editoras = <Editora>[];
  List <Editora> editorasListForSearch = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEditoras().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      loadingEditoras?
      Center(child: Container(width: 200, height: 200,alignment: Alignment.center,child: CircularProgressIndicator(color: Colors.black87, backgroundColor: Colors.grey,))):
      Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(9, 12, 9, 4),
            child: TextField(
              onChanged: searchEditora,
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pesquisa',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.black87)
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  final itemEditoraList = editorasListForSearch[index];
                  return ListTile(
                    leading: Icon(
                      Icons.apartment_outlined,
                      size: 48.0,
                    ),
                    title: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                itemEditoraList.nome,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.apartment_outlined),
                            Expanded(
                              child: AutoSizeText(
                                itemEditoraList.cidade,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        child: editarEditoras(editora: itemEditoraList),
                        type: PageTransitionType.size,
                        alignment: Alignment.center,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.all(16),
                separatorBuilder: (_, __) => Divider(color: Colors.black),
                itemCount: editorasListForSearch.length),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: const addEditoras(),
            type: PageTransitionType.size,
            alignment: Alignment.center,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> loadEditoras() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/editoras');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      editoras.addAll(data.map((e) => Editora.fromMap(e)));
    }
    setState(()=> loadingEditoras = false);
    editorasListForSearch = editoras;
  }

  void searchEditora (String query){
    final suggestion = editoras.where((itemUsuarioList){
      final itemProcurado = itemUsuarioList.nome.toLowerCase() + itemUsuarioList.cidade.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => editorasListForSearch = suggestion);
  }
}
