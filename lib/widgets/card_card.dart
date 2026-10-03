import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';

class CardCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const CardCard({Key? key, required this.note, required this.onTap}) : super(key: key);

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr));
    } catch (e) {
      return Colors.pinkAccent;
    }
  }

  void _copyDetails(BuildContext context, String contentJson) {
    try {
      Map<String, dynamic> data = jsonDecode(contentJson);
      String textToCopy = data.entries.map((e) => "${e.key}: ${e.value}").join("\n");
      
      Clipboard.setData(ClipboardData(text: "📋 *${note.title}*\n$textToCopy"));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details copied to clipboard!')),
      );
    } catch (e) {
      Clipboard.setData(ClipboardData(text: "${note.title}\n${note.content}"));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = _parseColor(note.color);
    Map<String, dynamic> details = {};
    try {
      details = jsonDecode(note.content);
    } catch (e) {
      details = {"Details": note.content};
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Copy Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyDetails(context, note.content),
                  child: const Icon(Icons.copy, size: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Details list preview inside card
            ...details.entries.take(3).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                "${entry.key}: ${entry.value}",
                style: const TextStyle(fontSize: 11, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}