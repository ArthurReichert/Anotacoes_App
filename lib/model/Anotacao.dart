import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';

class Anotacao{

  int? id;
  String? titulo;
  String? descricao;
  String? data;

  Anotacao(this.titulo, this.descricao, this.data);

  Anotacao.fromMap(Map map){

    id = map["id"];
    titulo = map["titulo"];
    descricao = map["descricao"];
    data = map["data"];

  }

  Map toMap(){

    Map<String, dynamic> map = {

      "titulo" : titulo,
      "descricao" : descricao,
      "data" : data,

    };

    if( id != null ){

      map["id"] = id;

    }

    return map;

  }
}