import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keep_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Notes Table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color TEXT NOT NULL,
        ai_summary TEXT,
        type TEXT NOT NULL DEFAULT 'note', -- 'note', 'card', 'checklist'
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL
      )
    ''');

    // 3. Folders Table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL
      )
    ''');

    // 4. Note-Folders Connecting Table (അලුතින් එකතු කළා)
    await db.execute('''
      CREATE TABLE note_folders (
        note_id INTEGER NOT NULL,
        folder_id INTEGER NOT NULL,
        PRIMARY KEY (note_id, folder_id),
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    // 5. Labels Table
    await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label_name TEXT NOT NULL,
        label_color TEXT NOT NULL
      )
    ''');

    // 6. Note-Labels Connecting Table
    await db.execute('''
      CREATE TABLE note_labels (
        note_id INTEGER NOT NULL,
        label_id INTEGER NOT NULL,
        PRIMARY KEY (note_id, label_id),
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (label_id) REFERENCES labels (id) ON DELETE CASCADE
      )
    ''');

    // 7. Checklist Items Table
    await db.execute('''
      CREATE TABLE checklist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        item_text TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS note_labels');
      await db.execute('DROP TABLE IF EXISTS note_folders');
      await db.execute('DROP TABLE IF EXISTS checklist_items');
      await db.execute('DROP TABLE IF EXISTS labels');
      await db.execute('DROP TABLE IF EXISTS folders');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS notes');
      await _createDB(db, newVersion);
    }
  }

  // --- CRUD Operations for Notes ---

  Future<int> insertNote(NoteModel note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<NoteModel>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'updated_at DESC');
    return result.map((json) => NoteModel.fromMap(json)).toList();
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // --- Folder Operations (ਅලුතින් එකතු කළ මෙවලම්) ---

  // 1. අලුත් Folder එකක් සෑදීම
  Future<int> insertFolder(String folderName) async {
    final db = await instance.database;
    return await db.insert('folders', {'folder_name': folderName});
  }

  // 2. සියලුම Folders ලබා ගැනීම
  Future<List<Map<String, dynamic>>> getAllFolders() async {
    final db = await instance.database;
    return await db.query('folders');
  }

  // 3. Note එකක් Folder එකකට ඇතුළත් කිරීම (Link Note with Folder)
  Future<void> addNoteToFolder(int noteId, int folderId) async {
    final db = await instance.database;
    await db.insert('note_folders', {
      'note_id': noteId,
      'folder_id': folderId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Label Operations ---

  Future<int> insertLabel(String name, String color) async {
    final db = await instance.database;
    return await db.insert('labels', {
      'label_name': name,
      'label_color': color,
    });
  }

  Future<List<Map<String, dynamic>>> getAllLabels() async {
    final db = await instance.database;
    return await db.query('labels');
  }

  Future<void> addLabelToNote(int noteId, int labelId) async {
    final db = await instance.database;
    await db.insert('note_labels', {
      'note_id': noteId,
      'label_id': labelId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
