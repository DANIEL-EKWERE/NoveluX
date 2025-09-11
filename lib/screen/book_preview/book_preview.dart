import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:novelux/config/app_style.dart';

class BookPreview extends StatefulWidget {
  final int? index;
  final List? bookList;
  const BookPreview({super.key, this.index, this.bookList});

  @override
  State<BookPreview> createState() => _BookPreviewState();
}

class _BookPreviewState extends State<BookPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1a1a),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Implement more options functionality here
            },
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF1a1a1a),
      body: ListView(
        children: [
          // Display book previews here
          // You can use widget.index and widget.bookList to customize the content
          CarouselSlider(
            items: widget.bookList?.map((book) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Container(
              width: 90,
              margin: EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.book, color: Colors.grey, size: 40),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    book["title"]!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    book["subtitle"]!,
                    style: TextStyle(color: depperBlue, fontSize: 10),
                  ),
                ],
              ),
            ),
              );
            }).toList(),
            options: CarouselOptions(
              enlargeFactor: 0.2,
              disableCenter: true,
              aspectRatio: 2/5,
              viewportFraction: 0.5,
              initialPage: widget.index ?? 0,
              enableInfiniteScroll: false,
              reverse: false,
              height: 400,
              enlargeCenterPage: true,
              autoPlay: false
            ),
          )
        ],
      ),
    );
  }
}
