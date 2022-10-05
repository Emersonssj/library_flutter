import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/pages/alugueis/selected_alugueis.dart';
import 'package:page_transition/page_transition.dart';
import 'package:livraria/pages/alugueis/add_alugueis.dart';
import 'package:livraria/pages/alugueis/alugueis_controller.dart';

class alugueis extends StatefulWidget {
  const alugueis({Key? key}) : super(key: key);

  @override
  State<alugueis> createState() => _alugueisState();
}

class _alugueisState extends State<alugueis> {
  bool loadingLivros = true;
  final baseurl = 'livraria--back.herokuapp.com';
  final aluguelMap = <Alugueis>[];
  List <Alugueis> alugueisListForSearch = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAluguel().then((value) {
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
          : Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(9, 12, 9, 4),
                child: TextField(
                  onChanged: searchAluguel,
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
                      final itemAluguelList = alugueisListForSearch[index];
                      return ListTile(
                        leading: Icon(Icons.add_chart, size: 48.0),
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        AutoSizeText(itemAluguelList.livro_id.nome))
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                ),
                                Expanded(
                                    child: AutoSizeText(
                                        itemAluguelList.usuario_id.nome)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                itemAluguelList.devolvido
                                    ? Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.transparent),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                        child: Text(
                                          'Devolvido',
                                          style: TextStyle(color: Colors.blueAccent),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        onTap: () => setState(() {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: selectedAlugueis(
                                  selectedAluguel: itemAluguelList),
                              type: PageTransitionType.size,
                              alignment: Alignment.center,
                            ),
                          );
                        }),
                      );
                    },
                    padding: EdgeInsets.all(16),
                    separatorBuilder: (_, __) => Divider(color: Colors.black),
                    itemCount: alugueisListForSearch.length),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: const addUsuarios(),
            type: PageTransitionType.size,
            alignment: Alignment.center,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> loadAluguel() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/alugueis');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      aluguelMap.addAll(data.map((e) => Alugueis.fromMap(e)));
    }
    setState(() => loadingLivros = false);
    alugueisListForSearch = aluguelMap;
  }

  void searchAluguel(String query) {
    final suggestion = aluguelMap.where((itemAluguelList) {
      final itemProcurado = itemAluguelList.livro_id.nome.toLowerCase() +
          itemAluguelList.usuario_id.nome.toLowerCase() +
          itemAluguelList.usuario_id.email.toLowerCase() +
          itemAluguelList.data_previsao.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => alugueisListForSearch = suggestion);
  }
}
