import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DownloadedContent {
  final String title;
  final String description;
  final String thumbnailLink;
  final String videoLink;
  final DateTime dateDownloaded;

  DownloadedContent({
    required this.title,
    required this.description,
    required this.thumbnailLink,
    required this.videoLink,
    required this.dateDownloaded,
  });

  factory DownloadedContent.fromJson(Map<String, dynamic> json) {
    return DownloadedContent(
      title: json['title'],
      description: json['description'],
      thumbnailLink: json['thumbnailLink'],
      videoLink: json['videoLink'],
      dateDownloaded: DateTime.parse(json['dateDownloaded']),
    );
  }
}

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final String jsonData = '''
  [
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "dateDownloaded": "2024-06-12"
    },
    {
      "title": "Fight Club",
      "description": "An insomniac office worker and a devil-may-care soapmaker...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BMmEzNTkxYjQtZTc0MC00YTVjLTg5ZTEtZWMwOWVlYzY0NWIwXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=qtRKdVHc-cE",
      "dateDownloaded": "2024-06-11"
    },
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "dateDownloaded": "2024-06-12"
    },
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "dateDownloaded": "2024-06-12"
    },
    {
      "title": "Fight Club",
      "description": "An insomniac office worker and a devil-may-care soapmaker...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BMmEzNTkxYjQtZTc0MC00YTVjLTg5ZTEtZWMwOWVlYzY0NWIwXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=qtRKdVHc-cE",
      "dateDownloaded": "2024-06-11"
    },
    {
      "title": "Fight Club",
      "description": "An insomniac office worker and a devil-may-care soapmaker...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BMmEzNTkxYjQtZTc0MC00YTVjLTg5ZTEtZWMwOWVlYzY0NWIwXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=qtRKdVHc-cE",
      "dateDownloaded": "2024-06-11"
    }
  ]
  ''';

  late List<DownloadedContent> downloadedContent;

  @override
  void initState() {
    super.initState();
    downloadedContent = _loadDownloadedContent();
  }

  List<DownloadedContent> _loadDownloadedContent() {
    final List<dynamic> contentDataList = jsonDecode(jsonData);
    return contentDataList.map<DownloadedContent>((contentData) => DownloadedContent.fromJson(contentData)).toList();
  }

  Map<String, List<DownloadedContent>> _groupContentByDate(List<DownloadedContent> content) {
    final Map<String, List<DownloadedContent>> groupedContent = {};

    for (var item in content) {
      String formattedDate = _formatDate(item.dateDownloaded);
      if (groupedContent.containsKey(formattedDate)) {
        groupedContent[formattedDate]!.add(item);
      } else {
        groupedContent[formattedDate] = [item];
      }
    }

    return groupedContent;
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<DownloadedContent>> groupedContent = _groupContentByDate(downloadedContent);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;

    if (screenWidth >= 600 && screenWidth < 1200) {
      crossAxisCount = 2;
    } else if (screenWidth >= 1200) {
      crossAxisCount = 3;
    }

    return Scaffold(
      body: downloadedContent.isEmpty
          ? const Center(
        child: Text('No content downloaded!'),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: groupedContent.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                DownloadGridView(
                  content: entry.value,
                  crossAxisCount: crossAxisCount,
                ),
                const SizedBox(height: 16.0),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DownloadGridView extends StatelessWidget {
  final List<DownloadedContent> content;
  final int crossAxisCount;

  const DownloadGridView({
    super.key,
    required this.content,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 16 / 9,
      ),
      itemCount: content.length,
      itemBuilder: (BuildContext context, int index) {
        final DownloadedContent item = content[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.thumbnailLink,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}