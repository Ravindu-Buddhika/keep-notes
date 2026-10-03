import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/note_controller.dart';
import '../models/note_model.dart';

class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({Key? key}) : super(key: key);

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final TextEditingController _titleController = TextEditingController();

  // Dynamic fields list (Key & Value controllers sanda)
  final List<Map<String, TextEditingController>> _fieldControllers = [];

  @override
  void initState() {
    super.initState();
    // Mudin field ekak automatic add karamu (Udaharanayਕ: Account No / Name sanda)
    _addField();

    // Text listeners to update live preview
    _titleController.addListener(() => setState(() {}));
  }

  void _addField() {
    setState(() {
      _fieldControllers.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
      // Listeners to update preview when user types in fields
      _fieldControllers.last['key']!.addListener(() => setState(() {}));
      _fieldControllers.last['value']!.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var field in _fieldControllers) {
      field['key']!.dispose();
      field['value']!.dispose();
    }
    super.dispose();
  }

  void _saveCard() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // Collect all fields into a Map and convert to JSON string for content column
    Map<String, String> detailsMap = {};
    for (var field in _fieldControllers) {
      String k = field['key']!.text.trim();
      String v = field['value']!.text.trim();
      if (k.isNotEmpty || v.isNotEmpty) {
        detailsMap[k.isEmpty ? 'Detail' : k] = v;
      }
    }

    String jsonContent = jsonEncode(detailsMap);
    final now = DateTime.now().toIso8601String();

    NoteModel cardNote = NoteModel(
      title: title,
      content: jsonContent, // JSON format eken details save karai
      color: '', // Controller eken random light color ekk assign karai
      aiSummary: 'card', // Type identifier
      createdAt: now,
      updatedAt: now,
    );

    await Provider.of<NoteController>(context, listen: false).addNote(cardNote);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Random or default preview color simulation
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blueAccent),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Live Preview Card (Uda ahanda dunna pinkarata anuwa landscape card ekk)
            Container(
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors
                    .pinkAccent
                    .shade200, // Preview color (Saving wela random watenwa)
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isEmpty
                        ? 'Card Title'
                        : _titleController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(color: Colors.black26),
                  Expanded(
                    child: ListView(
                      children: _fieldControllers.map((field) {
                        String k = field['key']!.text;
                        String v = field['value']!.text;
                        if (k.isEmpty && v.isEmpty)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            "${k.isEmpty ? 'Field' : k}: ${v}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Card Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Card Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Dynamic Card Details Input Fields with '+' Button
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fieldControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _fieldControllers[index]['key'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Label (e.g. Acc No)',
                            hintStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _fieldControllers[index]['value'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Value (e.g. 1029384)',
                            hintStyle: TextStyle(color: Colors.white38),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Add Field Button (+)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.blueAccent,
                  size: 32,
                ),
                onPressed: _addField,
              ),
            ),
            const SizedBox(height: 40),

            // 4. Create Card Button at bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveCard,
                child: const Text(
                  'Create card',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
