import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/database_helper.dart';
import 'segunda_tela.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          foregroundColor: Colors.black,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController tarefaController = TextEditingController();

  List<Map<String, dynamic>> tarefas = [];

  int? idTarefaEmEdicao;
  bool carregando = false;
  bool carregandoLista = true;

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  void dispose() {
    tarefaController.dispose();
    super.dispose();
  }

  Future<void> carregarTarefas() async {
    try {
      final dados = await DatabaseHelper.instance.listarTarefas();

      if (!mounted) return;

      setState(() {
        tarefas = dados;
        carregandoLista = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregandoLista = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar tarefas: $e')));
    }
  }

  Future<void> adicionarOuAtualizarTarefa() async {
    final descricao = tarefaController.text.trim();

    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma tarefa antes de continuar.')),
      );
      return;
    }

    if (carregando) return;

    final estavaEditando = idTarefaEmEdicao != null;

    setState(() {
      carregando = true;
    });

    try {
      if (estavaEditando) {
        await DatabaseHelper.instance.atualizarTarefa(
          idTarefaEmEdicao!,
          descricao,
        );
      } else {
        await DatabaseHelper.instance.inserirTarefa(descricao);
      }

      await carregarTarefas();

      if (!mounted) return;

      setState(() {
        idTarefaEmEdicao = null;
        tarefaController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            estavaEditando
                ? 'Tarefa atualizada com sucesso!'
                : 'Tarefa adicionada com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar tarefa: $e')));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void editarTarefa(Map<String, dynamic> tarefa) {
    setState(() {
      idTarefaEmEdicao = tarefa['id'] as int;
      tarefaController.text = tarefa['descricao'] as String;
    });
  }

  Future<void> removerTarefa(int id) async {
    if (carregando) return;

    try {
      await DatabaseHelper.instance.removerTarefa(id);

      if (!mounted) return;

      if (idTarefaEmEdicao == id) {
        setState(() {
          idTarefaEmEdicao = null;
          tarefaController.clear();
        });
      }

      await carregarTarefas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao excluir tarefa: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Tarefas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tarefaController,
                    enabled: !carregando,
                    decoration: InputDecoration(
                      hintText: 'Digite uma tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) {
                      adicionarOuAtualizarTarefa();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: carregando ? null : adicionarOuAtualizarTarefa,
                  child: carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          idTarefaEmEdicao == null ? 'Adicionar' : 'Atualizar',
                        ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: carregandoLista
                  ? const Center(child: CircularProgressIndicator())
                  : tarefas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma tarefa cadastrada.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        final tarefa = tarefas[index];
                        final id = tarefa['id'] as int;
                        final descricao = tarefa['descricao'] as String;

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(descricao),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar tarefa',
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: carregando
                                      ? null
                                      : () => editarTarefa(tarefa),
                                ),
                                IconButton(
                                  tooltip: 'Excluir tarefa',
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: carregando
                                      ? null
                                      : () => removerTarefa(id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SegundaTela()),
              );
            },
            child: const Text('Sobre'),
          ),
        ),
      ),
    );
  }
}
