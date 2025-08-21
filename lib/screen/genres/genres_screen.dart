import 'package:flutter/material.dart';

class GenresScreen extends StatefulWidget {

  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  final List<String> genres = [
    'Romance',
    'Werewolf',
    'CEO',
    'Billionaire',
    'Mafia',
    'Reborn/Revenge',
    'Marriage Before Love',
    'Strong Female Lead',
    'Wealthy Families',
    'Teen Fiction',
    'Male Lead',
    'Princess',
    'Doctor',
    'Contract Marriage',
  ];

  final List<Map<String, dynamic>> books = [
    {
      'title': 'The Revenge Marriage...',
      'subtitle': 'Original title:My Ex-Wife is Pregnant Again Callum Blackwell married the wido...',
      'rating': 4.2,
      'views': '20.8K Views',
      'tag': 'pregnant',
      'image': 'assets/book1.jpg',
    },
    {
      'title': 'Sweet Desire',
      'subtitle': 'She looked at the man sitting next to her dad in disgust, she couldn\'t believe she ha...',
      'rating': 4.8,
      'views': '10.8K Views',
      'tag': 'Love Triangle',
      'image': 'assets/book2.jpg',
    },
    {
      'title': 'You are the most pre...',
      'subtitle': 'Since five years ago, Melissa had been suffering from a painful incident due to whic...',
      'rating': 5.0,
      'views': '2.6K Views',
      'tag': 'Boss-Employee',
      'image': 'assets/book3.jpg',
    },
    {
      'title': 'The Mistaken Identity',
      'subtitle': 'Kalliyah\'s twin sister, Alliyah decides to have an affair with an older man. The affa...',
      'rating': 4.7,
      'views': '3.4K Views',
      'tag': 'Mistaken Identity',
      'image': 'assets/book4.jpg',
    },
    {
      'title': 'The Debt of kiss lasts...',
      'subtitle': 'This story is about a rich CEO of the country, whose life is a mystery for everyon...',
      'rating': 4.4,
      'views': '8.0K Views',
      'tag': 'CEO',
      'image': 'assets/book5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1a1a),
        elevation: 0,
        title: Text(
          'Genres',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar with genres
          Container(
            width: 140,
            color: Color(0xFF1a1a1a),
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                bool isSelected = index == 0; // Romance is selected
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.transparent : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? Color(0xFFFFD700) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    genres[index],
                    style: TextStyle(
                      color: isSelected ? Color(0xFFFFD700) : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          // Right content area
          Expanded(
            child: Container(
              color: Color(0xFF2a2a2a),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book cover placeholder
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: _getGradientColors(index),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Placeholder for book cover image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black26,
                                ),
                              ),
                              // Book title overlay
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Text(
                                  _getBookTitleOverlay(index),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        // Book details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                book['subtitle'],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    book['rating'].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: Color(0xFFFFD700),
                                    size: 14,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    book['views'],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFB8860B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  book['tag'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
     // bottomNavigationBar: _buildBottomNavigationBar(0),
    );
  }

  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0:
        return [Colors.pink[300]!, Colors.purple[300]!];
      case 1:
        return [Colors.green[300]!, Colors.teal[300]!];
      case 2:
        return [Colors.blue[300]!, Colors.cyan[300]!];
      case 3:
        return [Colors.grey[800]!, Colors.grey[600]!];
      case 4:
        return [Colors.green[400]!, Colors.green[600]!];
      default:
        return [Colors.blue[300]!, Colors.purple[300]!];
    }
  }

  String _getBookTitleOverlay(int index) {
    switch (index) {
      case 0:
        return 'Hidden Heir';
      case 1:
        return 'Sweet Desire';
      case 2:
        return 'Me First Precious Me';
      case 3:
        return 'Mistaken Identity';
      case 4:
        return 'The Debt of Kiss Lasts Forever';
      default:
        return '';
    }
  }
}