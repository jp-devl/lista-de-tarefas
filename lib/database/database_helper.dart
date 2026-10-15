
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('tarefas.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL
      )
    ''');
  }

  // Adicionar tarefa
  Future<int> inserirTarefa(String descricao) async {
    final db = await database;

    return db.insert(
      'tarefas',
      {'descricao': descricao},
    );
  }

  // Listar tarefas
  Future<List<Map<String, dynamic>>> listarTarefas() async {
    final db = await database;

    return db.query(
      'tarefas',
      orderBy: 'id DESC',
    );
  }

  // Excluir tarefa pelo ID
  Future<int> removerTarefa(int id) async {
    final db = await database;

    return db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualizar tarefa pelo ID
  Future<int> atualizarTarefa(int id, String descricao) async {
    final db = await database;

    return db.update(
      'tarefas',
      {'descricao': descricao},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
