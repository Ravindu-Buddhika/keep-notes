import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/database_helper.dart';

class NoteController with ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  // picking random light color for new notes if no color is provided
  String _getRandomLightColor() {
    final List<Color> lightColors = [
      const Color(0xFFFFCC80), // Light Orange
      const Color(0xFFCE93D8), // Light Purple
      const Color(0xFFFFF59D), // Light Yellow
      const Color(0xFFF48FB1), // Light Pink
      const Color(0xFF80DEEA), // Light Cyan
      const Color(0xFFA5D6A7), // Light Green
    ];
    
    final random = Random();
    Color selectedColor = lightColors[random.nextInt(lightColors.length)];
    
    // convert Color to hex string without alpha channel
    return selectedColor.value.toRadixString(16);
  }

  // get all notes from the database
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

  // create new note and add it to the database
  Future<void> addNote(NoteModel note) async {
    String colorToUse = note.color.isEmpty ? _getRandomLightColor() : note.color;

    NoteModel newNote = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      color: colorToUse,
      aiSummary: note.aiSummary,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );

    await DatabaseHelper.instance.insertNote(newNote);
    await fetchNotes();
  }

  // update
  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper.instance.updateNote(note);
    await fetchNotes();
  }

  // delete
  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    await fetchNotes();
  }
}