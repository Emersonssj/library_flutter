import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraria/models/usuario_model.dart';
import 'package:livraria/models/editora_model.dart';
import 'package:livraria/models/livro_model.dart';
import 'package:livraria/models/aluguel_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/maisAlugados_model.dart';

class home_page extends StatefulWidget {
  const home_page({Key? key}) : super(key: key);

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  List<ChartDataModel> dataG1 = <ChartDataModel>[];
  late TooltipBehavior _tooltipG1;
  int maxYLivrosMaisAlugados = 10;
  bool loadingUsuarios = true;
  bool loadingEditoras = true;
  bool loadingLivros = true;
  bool loadingAlugueis = true;
  bool loadingGrafico = true;
  var quantidadeUsuarios;
  var quantidadeEditoras;
  var quantidadeLivros;
  var quantidadeAlugueis;
  final baseurl = 'livraria--back.herokuapp.com';
  final usuarios = <Usuario>[];
  final editoras = <Editora>[];
  final livrosData = <Livros>[];
  final livrosMaisAlugados = <Livros>[];
  final aluguel = <Alugueis>[];

  @override
  void initState() {
    super.initState();
    loadUsuarios().then((value) {
      setState(() {});
    });
    loadEditoras().then((value) {
      setState(() {});
    });
    loadLivros().then((value) {
      setState(() {});
    });
    loadAluguel().then((value) {
      setState(() {});
    });
    maisAlugados().then((value) {
      setState(() {});
    });
    _tooltipG1 = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                children: [
                  gerarClipReact(
                    'https://www.gestaodacrise.com.br/wp-content/uploads/2020/12/todo-lider-precisar-ser-bom-leitor.jpg',
                    '$quantidadeUsuarios Usuarios',
                    loadingUsuarios,
                  ),
                  gerarClipReact(
                    'https://www.jejcontabilidade.com.br/site/upload/conteudo/103/2011111050194486.jpg',
                    '$quantidadeEditoras Editoras',
                    loadingEditoras,
                  ),
                  if (orientation == Orientation.landscape) ...[
                    gerarClipReact(
                      'https://p7z2w8n8.rocketcdn.me/wp-content/uploads/2020/12/livros-sobre-investimentos-para-todos-os-niveis-de-investidores.jpg',
                      '$quantidadeLivros Livros',
                      loadingLivros,
                    ),
                    gerarClipReact(
                      'https://cdn.culturagenial.com/imagens/dicas-livros-og.jpg',
                      '$quantidadeAlugueis Alugueis',
                      loadingAlugueis,
                    ),
                  ],
                ],
              ),
              if (orientation == Orientation.portrait)
                Row(
                  children: [
                    gerarClipReact(
                      'https://p7z2w8n8.rocketcdn.me/wp-content/uploads/2020/12/livros-sobre-investimentos-para-todos-os-niveis-de-investidores.jpg',
                      '$quantidadeLivros Livros',
                      loadingLivros,
                    ),
                    gerarClipReact(
                      'https://cdn.culturagenial.com/imagens/dicas-livros-og.jpg',
                      '$quantidadeAlugueis Alugueis',
                      loadingAlugueis,
                    ),
                  ],
                ),
              SizedBox(height: 10),
              loadingGrafico
                  ? Center(
                      child: Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.black87,
                            backgroundColor: Colors.white70,
                          )),
                    )
                  : Row(
                      children: [
                        SizedBox(width: 4, height: 4),
                        Expanded(
                          child: SfCartesianChart(
                            borderColor: Colors.black87,
                            title: ChartTitle(
                              text: 'Top ${dataG1.length} livros mais alugados',
                            ),
                            primaryXAxis: CategoryAxis(
                              title: AxisTitle(text: 'Livros'),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0,
                              maximum: maxYLivrosMaisAlugados.toDouble(),
                              interval: 5,
                            ),
                            tooltipBehavior: _tooltipG1,
                            series: <ChartSeries<ChartDataModel, String>>[
                              ColumnSeries<ChartDataModel, String>(
                                dataSource: dataG1,
                                xValueMapper: (ChartDataModel data, _) =>
                                    data.x,
                                yValueMapper: (ChartDataModel data, _) =>
                                    data.y,
                                name: 'Livro',
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 4, height: 4),
                      ],
                    ),
            ],
          ),
        );
      },
    ));
  }

  Future<void> maisAlugados() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/maisalugados');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      livrosMaisAlugados.addAll(data.map((e) => Livros.fromMap(e)));
    }
    for (int i = 0; i < livrosMaisAlugados.length && i < 5; i++) {
      final p = ChartDataModel(
        abrevear(livrosMaisAlugados[i].nome),
        livrosMaisAlugados[i].totalalugado,
      );
      dataG1.add(p);
      maxYLivrosMaisAlugados = max(maxYLivrosMaisAlugados, p.y);
    }
    maxYLivrosMaisAlugados += 10 - (maxYLivrosMaisAlugados % 10);
    setState(() => loadingGrafico = false);
  }

  Future<void> loadUsuarios() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/usuarios');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      usuarios.addAll(data.map((e) => Usuario.fromMap(e)));
    }
    quantidadeUsuarios = usuarios.length;
    setState(() => loadingUsuarios = false);
  }

  Future<void> loadEditoras() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/editoras');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      editoras.addAll(data.map((e) => Editora.fromMap(e)));
    }
    quantidadeEditoras = editoras.length;
    setState(() => loadingEditoras = false);
  }

  Future<void> loadLivros() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/livros');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      livrosData.addAll(data.map((e) => Livros.fromMap(e)));
    }
    quantidadeLivros = livrosData.length;
    setState(() => loadingLivros = false);
  }

  Future<void> loadAluguel() async {
    var uri = Uri.https('livraria--back.herokuapp.com', 'api/alugueis');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      aluguel.addAll(data.map((e) => Alugueis.fromMap(e)));
    }
    quantidadeAlugueis = aluguel.length;
    setState(() => loadingAlugueis = false);
  }

  Widget gerarClipReact(String imagePath, String title, bool loading) {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 150),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridTile(
              child: Image.network(imagePath, fit: BoxFit.fitHeight),
              footer: loading
                  ? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: Colors.black87,
                        backgroundColor: Colors.white70,
                      ))
                  : GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(title),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String abrevear(String s) {
    return s.length <= 5 ? s : "${s.substring(0, 5)}...";
  }
}
