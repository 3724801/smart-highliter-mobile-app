import 'dart:async'; // Added for TimeoutException
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_profile_screen.dart';
import 'dart:math';
import '../models/Highlight.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts _flutterTts = FlutterTts();
  // final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'en-US';
  bool _isLoading = true;
  bool _showOnlyUserHighlights = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // Web-compatible API base URL
  String get _apiBaseUrl {
    if (kIsWeb) {
      // For web, use relative URLs or configure CORS properly
      return 'http://localhost:3000'; // or your actual backend URL
    } else {
      // For mobile emulator
      return 'http://10.0.2.2:5000';
    }
  }

  List<Highlight> _allHighlights = [];
  List<Highlight> _displayedHighlights = [];
  List<Highlight> _randomHighlights = [];
  Set<String> _favoriteIds = {};
  Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeSpeech();
    _initializeTts();
    _getCurrentUserAndLoadData();
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Initialize TTS for web
  void _initializeTts() async {
    try {
      await _flutterTts.setLanguage(_selectedLanguage);

      if (kIsWeb) {
        // Web-specific TTS settings
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
      }
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Initialize speech recognition
  void _initializeSpeech() async {
    // Note: Speech recognition may not work properly in web browsers
    // due to security restrictions and API limitations
    if (kIsWeb) {
      print('Speech recognition has limited support in web browsers');
    } else {
      print('Speech recognition initialization for mobile');
    }
  }

  // Start listening for speech - Web compatible
  void _startListening() async {
    if (kIsWeb) {
      // For web, you might want to use the Web Speech API directly
      // or show a message that this feature is limited
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech recognition has limited support in web browsers'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });
    print('Started listening...');
  }

  // Stop listening for speech
  void _stopListening() async {
    setState(() {
      _isListening = false;
    });
    print('Stopped listening...');
  }

  Future<void> _getCurrentUserAndLoadData() async {
    try {
      _currentUser = _auth.currentUser;
      if (_currentUser != null) {
        print('Current user: ${_currentUser?.uid}');
      } else {
        print('No user is currently signed in');
      }

      await _loadHighlightsFromApi();
    } catch (e) {
      print('Error getting current user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHighlightsFromApi() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Remove CORS headers - they don't work on client side
      // Only add Authorization if user is logged in
      if (_currentUser != null) {
        String? token = await _currentUser?.getIdToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      // Check if user is logged in
      if (_currentUser == null) {
        setState(() {
          _allHighlights = [];
          _displayedHighlights = [];
          _isLoading = false;
        });
        return;
      }

      // Build request URL with userId as query parameter
      final requestUri = Uri.parse('$_apiBaseUrl/api/highlight?userId=${_currentUser!.uid}');
      print('Fetching highlights for user: ${_currentUser!.uid}');
      print('API URL: $requestUri');

      final response = await http.get(
        requestUri,
        headers: headers,
      ).timeout(Duration(seconds: 30));

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API returned ${data.length} highlights');

        setState(() {
          _allHighlights = data.map((json) => Highlight.fromJson(json)).toList();
          _displayedHighlights = List.from(_allHighlights);
        });
      } else if (response.statusCode == 400) {
        print('Bad request - likely missing userId');
        setState(() {
          _allHighlights = [];
          _displayedHighlights = [];
        });
      } else {
        print('Failed to load highlights: ${response.statusCode}');
        setState(() {
          _allHighlights = [];
          _displayedHighlights = [];
        });
      }
    } on TimeoutException catch (e) {
      print('Request timeout: $e');
      _showErrorSnackBar('Request timeout. Please check your connection.');
      setState(() {
        _allHighlights = [];
        _displayedHighlights = [];
      });
    } catch (e) {
      print('Error loading highlights: $e');
      _showErrorSnackBar('Error loading highlights: ${e.toString()}');
      setState(() {
        _allHighlights = [];
        _displayedHighlights = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _deleteHighlight(String highlightId) async {
    try {
      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to delete highlights')),
        );
        return;
      }

      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Highlight'),
            content: Text('Are you sure you want to delete this highlight?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (kIsWeb) {
        headers['Access-Control-Allow-Origin'] = '*';
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
        headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization';
      }

      String? token = await _currentUser?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/api/highlight?id=$highlightId'),
        headers: headers,
      ).timeout(Duration(seconds: 30));

      // Hide loading
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Delete response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadHighlightsFromApi();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Highlight deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMessage = 'Failed to delete highlight';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // Use default message if parsing fails
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Request timeout. Please try again.');
    } catch (e) {
      // Hide loading if it's showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Error deleting highlight: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting highlight: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editHighlight(String highlightId, String currentNote) async {
    TextEditingController noteController = TextEditingController(text: currentNote);

    bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Note'),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Enter your note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldUpdate != true) return;

    try {
      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to edit highlights')),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (kIsWeb) {
        headers['Access-Control-Allow-Origin'] = '*';
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
        headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization';
      }

      String? token = await _currentUser?.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$_apiBaseUrl/api/highlight?id=$highlightId'),
        headers: headers,
        body: json.encode({
          'note': noteController.text,
        }),
      ).timeout(Duration(seconds: 30));

      // Hide loading
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Edit response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadHighlightsFromApi();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Highlight updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMessage = 'Failed to update highlight';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // Use default message if parsing fails
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Request timeout. Please try again.');
    } catch (e) {
      // Hide loading if it's showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Error updating highlight: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating highlight: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      noteController.dispose();
    }
  }

  void _applyUserFilter() {
    if (_allHighlights.isEmpty) {
      setState(() {
        _displayedHighlights = [];
      });
      return;
    }

    setState(() {
      if (_showOnlyUserHighlights && _currentUser != null) {
        _displayedHighlights = _allHighlights.where((highlight) {
          return highlight.userId == _currentUser!.uid;
        }).toList();
      } else {
        _displayedHighlights = List.from(_allHighlights);
      }
    });
  }

  void _generateRandomHighlights() {
    if (_displayedHighlights.isEmpty) {
      _randomHighlights = [];
      return;
    }

    final random = Random();
    _randomHighlights = List.from(_displayedHighlights);
    _randomHighlights.shuffle(random);
    _randomHighlights =
        _randomHighlights.take(min(5, _randomHighlights.length)).toList();
  }

  List<Highlight> _getFilteredHighlights() {
    List<Highlight> filteredHighlights = _displayedHighlights;

    if (_searchController.text.isEmpty) {
      return filteredHighlights;
    }

    final searchText = _searchController.text.toLowerCase();
    return filteredHighlights.where((highlight) {
      return highlight.selectedText.toLowerCase().contains(searchText) ||
          highlight.pageTitle.toLowerCase().contains(searchText) ||
          highlight.tags.any((tag) => tag.toLowerCase().contains(searchText));
    }).toList();
  }

  Map<String, List<Highlight>> _getGroupedHighlights(List<Highlight> highlights) {
    Map<String, List<Highlight>> groups = {};

    for (var highlight in highlights) {
      String key = highlight.pageUrl.isNotEmpty ? highlight.pageUrl : highlight.pageTitle;

      if (!groups.containsKey(key)) {
        groups[key] = [];
        if (!_expandedGroups.containsKey(key)) {
          _expandedGroups[key] = false;
        }
      }

      groups[key]!.add(highlight);
    }

    return groups;
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      setState(() {
        _favoriteIds = favorites.toSet();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String highlightId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_favoriteIds.contains(highlightId)) {
        _favoriteIds.remove(highlightId);
      } else {
        _favoriteIds.add(highlightId);
      }

      await prefs.setStringList('favorites', _favoriteIds.toList());
      setState(() {});
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }

  Future<void> _speakText(String text) async {
    try {
      if (kIsWeb) {
        // Additional web-specific TTS handling
        await _flutterTts.stop(); // Stop any ongoing speech
        await Future.delayed(Duration(milliseconds: 100)); // Small delay
      }
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
      if (kIsWeb) {
        _showErrorSnackBar('Text-to-speech may not be fully supported in this browser');
      }
    }
  }

  void _shareHighlight(Highlight highlight) {
    final shareText = '''
"${highlight.selectedText}"

From: ${highlight.pageTitle}
${highlight.pageUrl.isNotEmpty ? 'URL: ${highlight.pageUrl}' : ''}
${highlight.note != null && highlight.note!.isNotEmpty ? '\nNote: ${highlight.note}' : ''}
    '''.trim();

    if (kIsWeb) {
      // For web, we can copy to clipboard as an alternative
      Clipboard.setData(ClipboardData(text: shareText)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Highlight copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } else {
      Share.share(shareText);
    }
  }

  void _showHighlightDetails(Highlight highlight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Title
                  Text(
                    highlight.pageTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (highlight.pageUrl.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      highlight.pageUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                  SizedBox(height: 16),

                  // Highlighted text
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getColorFromString(highlight.color).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getColorFromString(highlight.color),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      highlight.selectedText,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  // Note
                  if (highlight.note != null && highlight.note!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      highlight.note!,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Tags
                  if (highlight.tags.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Tags:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: highlight.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue[100],
                      )).toList(),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _speakText(highlight.selectedText),
                        icon: Icon(Icons.volume_up),
                        tooltip: 'Read aloud',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _shareHighlight(highlight);
                        },
                        icon: Icon(kIsWeb ? Icons.copy : Icons.share),
                        tooltip: kIsWeb ? 'Copy to clipboard' : 'Share',
                      ),
                      IconButton(
                        onPressed: () => _toggleFavorite(highlight.id),
                        icon: Icon(
                          _favoriteIds.contains(highlight.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        color: _favoriteIds.contains(highlight.id)
                            ? Colors.red
                            : null,
                        tooltip: 'Favorite',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editHighlight(highlight.id, highlight.note ?? '');
                        },
                        icon: Icon(Icons.edit),
                        tooltip: 'Edit note',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteHighlight(highlight.id);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Highlighter ${kIsWeb ? '(Web)' : ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(user: _currentUser!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please log in to view profile')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHighlightsFromApi,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'All'),
            Tab(icon: Icon(Icons.shuffle), text: 'Random'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search highlights...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                if (!kIsWeb) // Hide microphone button on web
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _isListening ? _stopListening : _startListening,
                    color: _isListening ? Colors.red : null,
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildHighlightsList(_getFilteredHighlights()),
                Builder(
                  builder: (context) {
                    _generateRandomHighlights();
                    return _buildHighlightsList(_randomHighlights);
                  },
                ),
                _buildHighlightsList(
                  _getFilteredHighlights()
                      .where((h) => _favoriteIds.contains(h.id))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsList(List<Highlight> highlights) {
    if (highlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.highlight_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _showOnlyUserHighlights
                  ? 'No highlights found for your account'
                  : 'No highlights found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final groupedHighlights = _getGroupedHighlights(highlights);

    return ListView.builder(
      itemCount: groupedHighlights.length,
      itemBuilder: (context, index) {
        final entry = groupedHighlights.entries.elementAt(index);
        final pageUrl = entry.key;
        final pageHighlights = entry.value;
        final isExpanded = _expandedGroups[pageUrl] ?? false;

        return Card(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  pageHighlights.first.pageTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${pageHighlights.length} highlight${pageHighlights.length > 1 ? 's' : ''}',
                ),
                trailing: IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expandedGroups[pageUrl] = !isExpanded;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _expandedGroups[pageUrl] = !isExpanded;
                  });
                },
              ),
              if (isExpanded)
                ...pageHighlights.map((highlight) => ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    color: _getColorFromString(highlight.color),
                  ),
                  title: Text(
                    highlight.selectedText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: highlight.note != null && highlight.note!.isNotEmpty
                      ? Text(
                    highlight.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_favoriteIds.contains(highlight.id))
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _showHighlightDetails(highlight),
                )),
            ],
          ),
        );
      },
    );
  }

  void _toggleUserHighlightsFilter() {
    setState(() {
      _showOnlyUserHighlights = !_showOnlyUserHighlights;
    });
    _loadHighlightsFromApi();
  }
}