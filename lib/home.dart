import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'model/Anotacao.dart';

class Home extends StatefulWidget {
  
  const Home({ Key? key }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  final _db = AnotacaoHelper();

  List<Anotacao?> _anotacoes = [];

  _exibirTelaCadastro( {Anotacao? anotacao} ){

    String textoSalvarAtualizar = "";
    
    if (anotacao == null){ //Salvando

      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";

    }else{ //Atualizar

      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = "Atualizar";

    }

    showDialog(
      context: context, 
      builder: (context){

        return AlertDialog(
          title: Text(textoSalvarAtualizar),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título..."
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição..."
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancelar")
            ),
            TextButton(
              onPressed: (){

                //Salvar
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                Navigator.pop(context);

              }, 
              child: Text(textoSalvarAtualizar)
            )
          ],
        );
      }
    );
  }

  _recuperarAnotacoes() async{

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao>? listaTemporaria = [];
    for (var item in anotacoesRecuperadas){

      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);

    }

    setState(() {
      _anotacoes = listaTemporaria!; //Exclamação para a lista aceitar null
    });

    listaTemporaria = null;

  }

  _salvarAtualizarAnotacao( {Anotacao? anotacaoSelecionada} ) async{

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if(anotacaoSelecionada == null){ //Salvar

      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);

    }else{ //Atualizar

      anotacaoSelecionada.titulo = titulo; //Se titulo alterado, salva o novo 
      anotacaoSelecionada.descricao = descricao; //Atualiza descrição nova
      anotacaoSelecionada.data = DateTime.now().toString(); //Atualiza Data alterada

      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);

    }

    _tituloController.clear(); //Limpa o título para proxima vez que abrir
    _descricaoController.clear(); //Limpa a descrição para proxima vez que abrir

    _recuperarAnotacoes();

  }

  _formatarData(String data){

    initializeDateFormatting("pt_BR"); //Formatação de data BR

    //Year -> y -- Monath -> M  -- Day -> d
    //Hour -> H -- Minute -> m -- Second -> s

    //var formatador = DateFormat("d/M/y - H:m");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data); //Converte a String para objeto de dateTime
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;

  }

  _removerAnotacao(int? id) async{

    await _db.removerAnotacao(id!); //Apaga o ID

    _recuperarAnotacoes(); //Recupera tudo de novo menos a excluída

  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index){

                final anotacao = _anotacoes[index];

                return Card(
                  child: ListTile(
                    title: Text(anotacao!.titulo.toString()),
                    subtitle: Text("${_formatarData(anotacao.data!)} - ${anotacao.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: (){

                            _exibirTelaCadastro(anotacao: anotacao);

                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){

                            _removerAnotacao(anotacao.id);

                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: _anotacoes.length,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: (){

          _exibirTelaCadastro();

        },
      ),
    );
  }
}
