import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/models/usuario_model.dart';

class ChamarPesquisaUsuario extends StatefulWidget {
  const ChamarPesquisaUsuario({Key? key, required this.whenUsuarioSelected})
      : super(key: key);
  final ValueChanged<Usuario> whenUsuarioSelected;

  @override
  State<ChamarPesquisaUsuario> createState() => _ChamarPesquisaUsuarioState();
}

class _ChamarPesquisaUsuarioState extends State<ChamarPesquisaUsuario> {
  final usuarios = <Usuario>[];
  List<Usuario> usuariosListForSearch = [];

  @override
  void initState() {
    super.initState();
    loadUsuarios().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Selecione o usuario'),
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
                      onChanged: searchUsuario,
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
                      _buildItem(usuariosListForSearch[index]),
                  separatorBuilder: (_, __) => Divider(color: Colors.black),
                  itemCount: usuariosListForSearch.length,
                ),
              ),
            ],
          ),
        ),
        actions: [],
      ),
    );
  }

  Widget _buildItem(Usuario usuario) {
    return ListTile(
      leading: Icon(Icons.account_circle, size: 27.0),
      title: Text(
        usuario.nome,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            usuario.cidade,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            usuario.email,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
      onTap: () => widget.whenUsuarioSelected(usuario),
    );
  }

  void searchUsuario(String query) {
    final suggestionn = usuarios.where((itemUsuariosList) {
      final itemProcurado = itemUsuariosList.nome.toLowerCase() +
          itemUsuariosList.email.toLowerCase() +
          itemUsuariosList.cidade.toLowerCase() +
          itemUsuariosList.endereco.toLowerCase();
      final input = query.toLowerCase();

      return itemProcurado.contains(input);
    }).toList();

    setState(() => usuariosListForSearch = suggestionn);
  }

  Future<void> loadUsuarios() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/usuarios');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      usuarios.addAll(data.map((e) => Usuario.fromMap(e)));
    }
    usuariosListForSearch = usuarios;
  }
}