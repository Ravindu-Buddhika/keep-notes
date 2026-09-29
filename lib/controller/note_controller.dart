import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/database_helper.dart';

class NoteController with ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  // load all notes from the database
  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await DatabaseHelper.instance.getAllNotes();
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // add new note
  Future<void> addNote(NoteModel note) async {
    await DatabaseHelper.instance.insertNote(note);
    await fetchNotes(); // update the list after adding a new note
  }

  // update note
  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper.instance.updateNote(note);
    await fetchNotes();
  }

  // delete note
  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    await fetchNotes();
  }
}