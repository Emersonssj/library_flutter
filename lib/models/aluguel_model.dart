import 'package:livraria/models/usuario_model.dart';
import 'package:livraria/models/livro_model.dart';

class Alugueis{
  String data_aluguel;
  String data_devolucao;
  String data_previsao;
  int id;
  Livros livro_id;
  Usuario usuario_id;

  Alugueis({
    required this.data_aluguel,
    required this.data_devolucao,
    required this.data_previsao,
    required this.id,
    required this.livro_id,
    required this.usuario_id,
  });
  factory Alugueis.fromMap(Map<String, dynamic> map){
    return Alugueis(
      data_aluguel: map['data_aluguel'],
      data_devolucao: map['data_devolucao']?? '',
      data_previsao: map['data_previsao'],
      id: map['id'],
      livro_id: Livros.fromMap(map['livro_id']),
      usuario_id: Usuario.fromMap(map['usuario_id']),
    );
  }
  Map <String, dynamic>toMap(){
    return {
      'data_aluguel': data_aluguel,
      'data_devolucao': data_devolucao,
      'data_previsao': data_previsao,
      'id': id,
      'livros_id': livro_id.toMap,
      'usuario_id': usuario_id.toMap,
    };
  }
  bool get devolvido => data_devolucao != '';
  bool get emAndamento => !devolvido && !atrasado;
  bool get atrasado => !devolvido && DateTime.now().toUtc().isAfter(DateTime.parse(data_previsao));
  bool get devolvidoComAtraso => devolvido && DateTime.parse(data_devolucao)!.isAfter(DateTime.parse(data_previsao));
}