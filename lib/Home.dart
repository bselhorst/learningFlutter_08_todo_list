import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:async/async.dart';
import 'dart:convert';
import 'dart:collection';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _lista = [];
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    // Map<String, dynamic> tarefa = Map();
    // tarefa["titulo"] = "Ir ao mercado";
    // tarefa["realizada"] = false;
    // _lista.add(tarefa);

    String dados = json.encode(_lista);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _lista.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _lista = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    // final item = _lista[index]["titulo"];
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        //Recuperar ultimo item
        _ultimaTarefaRemovida = _lista[index];

        //Remove da lista
        _lista.removeAt(index);
        _salvarArquivo();

        //Snackbar
        final snackBar = SnackBar(
          // backgroundColor: Colors.green,
          content: Text("Tarefa Removida"),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _lista.insert(index, _ultimaTarefaRemovida);
              });
              _salvarArquivo();
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      background: Container(
        padding: EdgeInsets.all(16),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
            ),
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_lista[index]['titulo']),
        value: _lista[index]['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            _lista[index]['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
      // onDismissed: (direction) {

      // },
    );
  }

  @override
  Widget build(BuildContext context) {
    _salvarArquivo();
    // print(_lista.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _lista.length,
                itemBuilder: criarItemLista,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration: InputDecoration(
                    labelText: "Digite sua tarefa",
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                    child: Text("Salvar"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
