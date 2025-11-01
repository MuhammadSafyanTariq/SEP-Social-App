import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AIChatMessage {
  final int? id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String chatType; // 'inbox' or 'contact'

  AIChatMessage({
    this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    required this.chatType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'chatType': chatType,
    };
  }

  factory AIChatMessage.fromMap(Map<String, dynamic> map) {
    return AIChatMessage(
      id: map['id'],
      message: map['message'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      chatType: map['chatType'],
    );
  }
}

class AIChatDatabase {
  static final AIChatDatabase _instance = AIChatDatabase._internal();
  factory AIChatDatabase() => _instance;
  AIChatDatabase._internal();

  static AIChatDatabase get instance => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ai_chat_messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ai_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT NOT NULL,
            isUser INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            chatType TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertMessage(AIChatMessage message) async {
    final db = await database;
    return await db.insert('ai_messages', message.toMap());
  }

  Future<List<AIChatMessage>> getMessages(String chatType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_messages',
      where: 'chatType = ?',
      whereArgs: [chatType],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return AIChatMessage.fromMap(maps[i]);
    });
  }

  Future<List<AIChatMessage>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_messages',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AIChatMessage.fromMap(maps[i]);
    });
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete('ai_messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllMessages(String chatType) async {
    final db = await database;
    return await db.delete(
      'ai_messages',
      where: 'chatType = ?',
      whereArgs: [chatType],
    );
  }

  Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete('ai_messages');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
