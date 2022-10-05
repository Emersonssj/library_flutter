import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:livraria/pages/usuarios/usuarios_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:livraria/pages/usuarios/add_usuarios.dart';
import 'package:livraria/pages/usuarios/editar_usuarios.dart';

class usuariosPage extends StatefulWidget {
  const usuariosPage({Key? key}) : super(key: key);

  @override
  State<usuariosPage> createState() => _usuariosPageState();
}

class _usuariosPageState extends State<usuariosPage> {
  bool loadingUsuarios = true;
  final baseurl = 'livraria--back.herokuapp.com';
  final usuarios = <Usuario>[];
  List<Usuario> usuariosListForSearch = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsuarios().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadingUsuarios
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
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(9, 12, 9, 4),
                  child: TextField(
                    onChanged: searchUsuario,
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
                        final itemUsuarioList = usuariosListForSearch[index];
                        return ListTile(
                          leading: Icon(Icons.account_circle, size: 48.0),
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      itemUsuarioList.nome,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                  ),
                                  Expanded(
                                    child: AutoSizeText(
                                      itemUsuarioList.email,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cabin),
                                  Text(itemUsuarioList.cidade)
                                ],
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          onTap: () => setState(() {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: editarUsuarios(usuario: itemUsuarioList),
                                type: PageTransitionType.size,
                                alignment: Alignment.center,
                              ),
                            );
                          }),
                        );
                      },
                      padding: EdgeInsets.all(16),
                      separatorBuilder: (_, __) => Divider(color: Colors.black),
                      itemCount: usuariosListForSearch.length),
                )
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

  Future<void> loadUsuarios() async {
    setState(() => loadingUsuarios = true);
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/usuarios');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      usuarios.addAll(data.map((e) => Usuario.fromMap(e)));
    }
    setState(() => loadingUsuarios = false);
    usuariosListForSearch = usuarios;
  }

  void searchUsuario(String query) {
    final suggestion = usuarios.where((itemUsuarioList) {
      final itemProcurado = itemUsuarioList.nome.toLowerCase() +
          itemUsuarioList.email.toLowerCase() +
          itemUsuarioList.cidade.toLowerCase() +
          itemUsuarioList.endereco.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => usuariosListForSearch = suggestion);
  }
}
