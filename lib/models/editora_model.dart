class Editora{
  String cidade;
  int id;
  String nome;

  Editora({
    required this.cidade,
    required this.id,
    required this.nome,
});
  factory Editora.fromMap(Map<String, dynamic> map){
    return Editora(
      cidade: map['cidade'],
      id: map['id'],
      nome: map['nome'],
    );
  }
  Map <String, dynamic>toMap(){
    return {
      'cidade': cidade,
      'id':id,
      'nome':nome,
    };
  }
}