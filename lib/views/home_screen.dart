import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/note_controller.dart';
import '../widgets/note_card.dart';
import '../views/note_editor_screen.dart';
import '../views/card_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    // Fetch notes when the HomeScreen is initialized
    Future.microtask(
      () => Provider.of<NoteController>(context, listen: false).fetchNotes(),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // 1. Main Home Screen Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. App Title (Keep Notes)
                  Text(
                    "Keep\nNotes",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Filter Chips (All, Important, Check, etc.)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("All", true, isDarkMode),
                        _buildFilterChip("Important", false, isDarkMode),
                        _buildFilterChip("Check", false, isDarkMode),
                        _buildFilterChip("Lesson", false, isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Notes List / Grid (Dynamic from Database)
                  Expanded(
                    child: Consumer<NoteController>(
                      builder: (context, noteController, child) {
                        if (noteController.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }

                        if (noteController.notes.isEmpty) {
                          return Center(
                            child: Text(
                              "No notes yet.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        // Display notes in a grid format
                        return GridView.builder(
                          itemCount: noteController.notes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    2, // Number of columns in the grid
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoteEditorScreen(note: note),
                                  ),
                                );
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

          // 2. Background Overlay when menu is open
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: (isDarkMode ? Colors.black : Colors.white).withOpacity(
                  0.9,
                ),
              ),
            ),

          // 3. Circular Options Menu (Design match)
          if (_isMenuOpen)
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: _toggleMenu,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. Create new Note
                            _buildCircularOption(
                              icon: Icons.edit_note,
                              label: "Create new\nNote",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _toggleMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NoteEditorScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 40),
                            // 2. Create new Check list
                            _buildCircularOption(
                              icon: Icons.checklist,
                              label: "Create new\nCheck list",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                _toggleMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CardEditorScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // 3. Create new card
                        _buildCircularOption(
                          icon: Icons.credit_card,
                          label: "Create new\ncard",
                          isDarkMode: isDarkMode,
                          onTap: () {
                            _toggleMenu();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CardEditorScreen(),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      // 4. Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: _toggleMenu,
        child: Icon(
          _isMenuOpen ? Icons.close : Icons.add,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }

  // Build a filter chip
  Widget _buildFilterChip(String label, bool isSelected, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: isDarkMode ? Colors.white : Colors.black,
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected
              ? (isDarkMode ? Colors.black : Colors.white)
              : (isDarkMode ? Colors.white70 : Colors.black54),
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDarkMode ? Colors.white38 : Colors.black26),
        ),
        onSelected: (bool selected) {},
      ),
    );
  }

  // Circular Option Widget based on user design
  Widget _buildCircularOption({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
