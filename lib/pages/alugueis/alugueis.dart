import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/pages/alugueis/selected_alugueis.dart';
import 'package:page_transition/page_transition.dart';
import 'package:livraria/pages/alugueis/add_alugueis.dart';
import 'package:livraria/models/aluguel_model.dart';

class alugueis extends StatefulWidget {
  const alugueis({Key? key}) : super(key: key);

  @override
  State<alugueis> createState() => _alugueisState();
}

class _alugueisState extends State<alugueis> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loadingLivros = true;
  final baseurl = 'livraria--back.herokuapp.com';
  final alugueisList = <Alugueis>[];
  List<Alugueis> alugueisListForSearch = [];
  final searchController = TextEditingController();

  bool showDevolvidoNoPrazo = true;
  bool showEmAndamento = true;
  bool showAtrasados = true;
  bool showEntregueComAtraso = true;

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
      key: _scaffoldKey,
      body: loadingLivros
          ? Center(
              child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Colors.black87,
                    backgroundColor: Colors.grey,
                  ),
              ),
          )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 10, 2, 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: searchAluguel,
                          controller: searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Pesquisa',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black87)),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _openEndDrawer,
                        icon: Icon(Icons.filter_list_outlined),
                      ),
                    ],
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
                                      child: AutoSizeText(
                                          itemAluguelList.livro_id.nome))
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
                                  itemAluguelList.devolvido                              //primeiro card
                                      ? Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(12)),
                                          ),
                                          child: Text(
                                            'Devolvido',
                                            style: TextStyle(
                                                color: Colors.blueAccent),
                                          ),
                                        )
                                      : Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(12)),
                                          ),
                                          child: Text(
                                            'Alugado',
                                            style: TextStyle(
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                  itemAluguelList.data_devolucao == '' //segundo card
                                      ? Card(
                                          //não devolvidos
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(12)),
                                          ),
                                          child: DateTime.tryParse(itemAluguelList.data_previsao)!.isBefore(DateTime.now())
                                              ? Text(
                                                  'Atrasado',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )
                                              : Text(
                                                  'No prazo',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                ),
                                        )
                                      : Card(                                                     //devolvidos
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(12)),
                                          ),
                                          child: DateTime.tryParse(itemAluguelList.data_devolucao)!.isBefore(DateTime.tryParse(itemAluguelList.data_previsao)!) || itemAluguelList.data_devolucao == itemAluguelList.data_previsao
                                              ? Text(
                                                  'No prazo',
                                                  style: TextStyle(
                                                      color: Colors.green),
                                                )
                                              : Text(
                                                  'Atrasado',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                        ),
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
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: const Text('Filtros'),
            ),
            CheckboxListTile(
              value: showAtrasados,
              onChanged: (v) {
                showAtrasados = v!;
                searchAluguel('');
              },
              title: const Text('Não entregados e atrasados'),
            ),
            CheckboxListTile(
              value: showEmAndamento,
              onChanged: (v) {
                showEmAndamento = v!;
                searchAluguel('');
              },
              title: const Text('Não entregados e no prazo'),
            ),
            CheckboxListTile(
              value: showEntregueComAtraso,
              onChanged: (v) {
                showEntregueComAtraso = v!;
                searchAluguel('');
              },
              title: const Text('Entregado com atraso'),
            ),
            CheckboxListTile(
              value: showDevolvidoNoPrazo,
              onChanged: (v) {
                showDevolvidoNoPrazo = v!;
                searchAluguel('');
              },
              title: const Text('Entregado no prazo'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff306BAC),
        onPressed: () => Navigator.push(
          context,
          PageTransition(
            child: const AddAluguel(),
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
      alugueisList.addAll(data.map((e) => Alugueis.fromMap(e)));
    }
    setState(() => loadingLivros = false);
    alugueisListForSearch = alugueisList;
  }

  void searchAluguel(String query) {
    var filteredData = alugueisList;

    if (!showDevolvidoNoPrazo) {
      filteredData = filteredData
          .where((e) => !e.devolvido || e.devolvidoComAtraso)
          .toList();
    }
    if (!showEmAndamento) {
      filteredData = filteredData.where((e) => !e.emAndamento).toList();
    }
    if (!showAtrasados) {
      filteredData = filteredData.where((e) => !e.atrasado).toList();
    }
    if (!showEntregueComAtraso) {
      filteredData = filteredData.where((e) => !e.devolvidoComAtraso).toList();
    }

    filteredData = filteredData.where((itemAluguelList) {
      final itemProcurado = itemAluguelList.livro_id.nome.toLowerCase() +
          itemAluguelList.usuario_id.nome.toLowerCase() +
          itemAluguelList.usuario_id.email.toLowerCase() +
          itemAluguelList.data_previsao.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => alugueisListForSearch = filteredData);
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }
}
