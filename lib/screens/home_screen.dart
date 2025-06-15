// screens/home_screen.dart
import 'dart:async' show TimeoutException;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> highlights = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedPageUrl; // Track which page is selected

  // Update this to match your backend port
  static const String baseUrl = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    fetchHighlights();
  }

  Future<void> fetchHighlights() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        return;
      }

      print('🔍 Fetching highlights for user: ${user.uid}');
      final url = '$baseUrl/api/highlight?userId=${user.uid}';
      print('📡 Request URL: $url');

      // Test server health first
      try {
        final healthResponse = await http.get(
          Uri.parse('$baseUrl/api/health'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        print('💓 Health check status: ${healthResponse.statusCode}');
        print('💓 Health check body: ${healthResponse.body}');
      } catch (e) {
        print('❌ Health check failed: $e');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response headers: ${response.headers}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          highlights = data is List ? data : [];
          isLoading = false;
        });
        print('✅ Successfully loaded ${highlights.length} highlights');
      } else {
        setState(() {
          errorMessage =
              "Failed to load highlights (${response.statusCode}): ${response.body}";
          isLoading = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        errorMessage =
            "❌ Cannot connect to server at $baseUrl. Is the server running?";
        isLoading = false;
      });
      print('🔌 Socket Exception: $e');
    } on TimeoutException catch (e) {
      setState(() {
        errorMessage =
            "⏱️ Request timeout. Server might be slow or not responding.";
        isLoading = false;
      });
      print('⏱️ Timeout Exception: $e');
    } on FormatException catch (e) {
      setState(() {
        errorMessage = "📋 Invalid response format from server";
        isLoading = false;
      });
      print('📋 Format Exception: $e');
    } catch (e) {
      setState(() {
        errorMessage = "🚨 Error: $e";
        isLoading = false;
      });
      print('🚨 General Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedPageUrl == null ? 'My Highlights' : 'Page Highlights'),
        actions: [
          if (selectedPageUrl != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  selectedPageUrl = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchHighlights,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new highlight screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading highlights...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchHighlights,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (highlights.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.highlight_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No highlights found", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Start highlighting content to see it here!"),
          ],
        ),
      );
    }

    // If a page is selected, show its highlights
    if (selectedPageUrl != null) {
      return _buildPageHighlights();
    }

    // Otherwise show the page cards
    return _buildPageCards();
  }

  Widget _buildPageCards() {
    // Group highlights by pageUrl
    final Map<String, List<dynamic>> pages = {};
    for (var highlight in highlights) {
      final pageUrl = highlight['pageUrl']?.toString() ?? 'unknown';
      if (!pages.containsKey(pageUrl)) {
        pages[pageUrl] = [];
      }
      pages[pageUrl]!.add(highlight);
    }

    return ListView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final pageUrl = pages.keys.elementAt(index);
        final pageHighlights = pages[pageUrl]!;
        final firstHighlight = pageHighlights.first;
        
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedPageUrl = pageUrl;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firstHighlight['pageImageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        firstHighlight['pageImageUrl'],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    firstHighlight['pageTitle']?.toString() ?? 'Untitled Page',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pageHighlights.length} highlight${pageHighlights.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageHighlights() {
    final pageHighlights = highlights.where((h) => h['pageUrl'] == selectedPageUrl).toList();
    if (pageHighlights.isEmpty) {
      return const Center(child: Text('No highlights found for this page'));
    }

    return ListView.builder(
      itemCount: pageHighlights.length,
      itemBuilder: (context, index) {
        final highlight = pageHighlights[index];
    Color borderColor;
      try {
        final colorHex = highlight['color']?.toString() ?? '#000000';
        borderColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
      } catch (e) {
        borderColor = Colors.blue; // Fallback color
      }
        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 4.0,
              ),
            ),
          ),
          child: Card(
            margin: const EdgeInsets.only(left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight['selectedText']?.toString() ?? 'No text',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (highlight['note'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Note: ${highlight['note']}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (highlight['aiAnalysis'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'AI Analysis: ${highlight['aiAnalysis']}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editHighlight(highlight),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _deleteHighlight(highlight['id']?.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteHighlight(String? id) async {
    if (id == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/highlight?id=$id'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Highlight deleted successfully')),
        );
        await fetchHighlights(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting highlight: $e')),
      );
    }
  }

  Future<void> _editHighlight(Map<String, dynamic> highlight) async {
    final TextEditingController controller = TextEditingController(
      text: highlight['note']?.toString() ?? '',
    );

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your note'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newNote != null) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/api/highlight?id=${highlight['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'note': newNote}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Highlight updated successfully')),
          );
          await fetchHighlights(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating highlight: $e')),
        );
      }
    }
  }
}