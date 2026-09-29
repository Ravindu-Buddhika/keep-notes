import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/note_controller.dart';
import '../widgets/note_card.dart';
//import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notes when the HomeScreen is initialized
    Future.microtask(() =>
      Provider.of<NoteController>(context, listen: false).fetchNotes()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Title (Keep Notes)
              const Text(
                "Keep\nNotes",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Filter Chips (All, Important, Check, etc.)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", true),
                    _buildFilterChip("Important", false),
                    _buildFilterChip("Check", false),
                    _buildFilterChip("Lesson", false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Notes List / Grid (Dynamic from Database)
              Expanded(
                child: Consumer<NoteController>(
                  builder: (context, noteController, child) {
                    if (noteController.isLoading) {
                      const Center(child: CircularProgressIndicator(color: Colors.orange));
                    }

                    if (noteController.notes.isEmpty) {
                      return const Center(
                        child: Text(
                          "No notes yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      );
                    }

                    // Display notes in a grid format
                    return GridView.builder(
                      itemCount: noteController.notes.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final note = noteController.notes[index];
                        return NoteCard(
                          note: note,
                          onTap: () {
                            // Navigate to Note Editor Screen with the selected note
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 4. Floating Action Button 
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          // Navigate to Note Editor Screen for creating a new note
        },
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  // Build a filter chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white38),
        ),
        onSelected: (bool selected) {},
      ),
    );
  }
}