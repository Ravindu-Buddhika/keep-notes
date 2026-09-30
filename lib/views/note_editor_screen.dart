import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/note_controller.dart';
import '../models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note; // If editing an existing note, pass it here

  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  bool _showToolbar = false; // Floating toolbar visibility when selecting text/holding cursor

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Save Note function
  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now().toIso8601String();
    
    if (widget.note == null) {
      // Create new note
      final newNote = NoteModel(
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        color: '', // Controller will assign a random light color
        createdAt: now,
        updatedAt: now,
      );
      Provider.of<NoteController>(context, listen: false).addNote(newNote);
    } else {
      // Update existing note
      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: title,
        content: content,
        color: widget.note!.color,
        aiSummary: widget.note!.aiSummary,
        createdAt: widget.note!.createdAt,
        updatedAt: now,
      );
      Provider.of<NoteController>(context, listen: false).updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark theme background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _saveNote, // Save automatically on back press
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.orangeAccent),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title Input
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                
                // 2. Content Input with Floating Toolbar Trigger simulation
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onTap: () {
                      // Toggle toolbar example when clicking/typing
                      setState(() {
                        _showToolbar = true;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Note something down...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Toolbar (Camera, Gallery, Drawing, Section Break)
          if (_showToolbar)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800]?.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement Camera capture
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement Gallery picker
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement Freehand drawing / Pen
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.horizontal_rule, color: Colors.white),
                        onPressed: () {
                          // Insert Section Break (Horizontal line) into content
                          setState(() {
                            _contentController.text += "\n-------------------\n";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}