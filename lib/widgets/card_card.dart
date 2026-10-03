import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';

class CardCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const CardCard({Key? key, required this.note, required this.onTap})
    : super(key: key);

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
      String textToCopy = data.entries
          .map((e) => "${e.key}: ${e.value}")
          .join("\n");

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
        padding: const EdgeInsets.all(14),
        // මෙන්න මෙතනින් Card එකේ උස සීමා කළ හැක (მაგ: max-height එකක් වගේ)
        constraints: const BoxConstraints(
          maxHeight: 160, // Card එක වැඩිපුර දිග වීම වළක්වයි
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyDetails(context, note.content),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(color: Colors.black26, height: 8, thickness: 0.8),
            const SizedBox(height: 4),

            // Card details items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: details.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Text(
                          "${entry.key}: ${entry.value}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
