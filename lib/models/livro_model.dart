import 'package:livraria/models/editora_model.dart';

class Livros{
  String autor;
  Editora editora;
  int id;
  int lancamento;
  String nome;
  int quantidade;
  int totalalugado;

  Livros({
    required this.autor,
    required this.editora,
    required this.id,
    required this.lancamento,
    required this.nome,
    required this.quantidade,
    required this.totalalugado,
});
  factory Livros.fromMap(Map<String, dynamic> map){
    return Livros(
        autor: map['autor'],
        editora: Editora.fromMap(map['editora']),
        id: map['id'],
        lancamento: map['lancamento'],
        nome: map['nome'],
        quantidade: map['quantidade'],
        totalalugado: map['totalalugado'],
    );
  }
  Map <String, dynamic>toMap(){
    return {
      'autor': autor,
      'editora': editora.toMap(),
      'id': id,
      'lancamento': lancamento,
      'nome': nome,
      'quantidade': quantidade,
      'totalalugado': totalalugado,
    };
  }
  bool get disponivel => quantidade != 0;
  bool get indisponivel => quantidade == 0;
}