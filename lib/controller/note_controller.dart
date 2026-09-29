import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/database_helper.dart';

class NoteController with ChangeNotifier {
  List<NoteModel> _notes = [];
  List<Map<String, dynamic>> _labels = [];
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  List<Map<String, dynamic>> get labels => _labels;
  List<Map<String, dynamic>> get folders => _folders;
  bool get isLoading => _isLoading;

  // Random light color generator for new notes
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
    
    return selectedColor.value.toRadixString(16);
  }

  // Fetch all notes, labels, and folders from database
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await DatabaseHelper.instance.getAllNotes();
      _labels = await DatabaseHelper.instance.getAllLabels();
      _folders = await DatabaseHelper.instance.getAllFolders();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Backward compatibility method
  Future<void> fetchNotes() async {
    await fetchAllData();
  }

  // Create new note with optional label and folder linking
  Future<void> addNote(NoteModel note, {int? labelId, int? folderId}) async {
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

    // 1. Insert Note and get generated note id
    int noteId = await DatabaseHelper.instance.insertNote(newNote);

    // 2. Link label if selected
    if (labelId != null) {
      await DatabaseHelper.instance.addLabelToNote(noteId, labelId);
    }

    // 3. Link folder if selected
    if (folderId != null) {
      await DatabaseHelper.instance.addNoteToFolder(noteId, folderId);
    }

    await fetchAllData();
  }

  // Update note
  Future<void> updateNote(NoteModel note) async {
    await DatabaseHelper.instance.updateNote(note);
    await fetchAllData();
  }

  // Delete note
  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.deleteNote(id);
    await fetchAllData();
  }

  // Add new Label dynamically
  Future<void> createLabel(String name, String color) async {
    await DatabaseHelper.instance.insertLabel(name, color);
    await fetchAllData();
  }

  // Add new Folder dynamically
  Future<void> createFolder(String folderName) async {
    await DatabaseHelper.instance.insertFolder(folderName);
    await fetchAllData();
  }
}