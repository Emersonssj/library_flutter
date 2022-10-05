class Usuario{
  int id;
  String nome;
  String endereco;
  String cidade;
  String email;

  Usuario({
    required this.cidade,
    required this.email,
    required this.endereco,
    required this.id,
    required this.nome,
});
  factory Usuario.fromMap(Map<String, dynamic> map){
    return Usuario(
        cidade: map['cidade'],
        email: map['email'],
        endereco: map['endereco'],
        id: map['id'],
        nome: map['nome'],
    );
  }
  Map <String, dynamic>toMap(){
    return {
      'cidade': cidade,
      'email': email,
      'endereco': endereco,
      'id':id,
      'nome':nome,
    };
  }
}