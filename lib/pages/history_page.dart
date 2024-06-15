import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Video {
  final String title;
  final String description;
  final String thumbnailLink;
  final String videoLink;
  final String watchedTime;
  final DateTime dateWatched;

  Video({
    required this.title,
    required this.description,
    required this.thumbnailLink,
    required this.videoLink,
    required this.watchedTime,
    required this.dateWatched,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'],
      description: json['description'],
      thumbnailLink: json['thumbnailLink'],
      videoLink: json['videoLink'],
      watchedTime: json['watchedTime'],
      dateWatched: DateTime.parse(json['dateWatched']),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String jsonData = '''
  [
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "watchedTime": "01:32:45",
      "dateWatched": "2024-06-12"
    },
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "watchedTime": "01:32:45",
      "dateWatched": "2024-06-12"
    },
    {
      "title": "The Shawshank Redemption",
      "description": "Two imprisoned men bond over a number of years...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=9gnbUKk621A",
      "watchedTime": "01:32:45",
      "dateWatched": "2024-06-12"
    },
    {
      "title": "Fight Club",
      "description": "An insomniac office worker and a devil-may-care soapmaker...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BMmEzNTkxYjQtZTc0MC00YTVjLTg5ZTEtZWMwOWVlYzY0NWIwXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=qtRKdVHc-cE",
      "watchedTime": "00:45:23",
      "dateWatched": "2024-06-11"
    },
    {
      "title": "Fight Club",
      "description": "An insomniac office worker and a devil-may-care soapmaker...",
      "thumbnailLink": "https://m.media-amazon.com/images/M/MV5BMmEzNTkxYjQtZTc0MC00YTVjLTg5ZTEtZWMwOWVlYzY0NWIwXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",
      "videoLink": "https://www.youtube.com/watch?v=qtRKdVHc-cE",
      "watchedTime": "00:45:23",
      "dateWatched": "2024-06-11"
    }
  ]
  ''';

  late List<Video> videos;

  @override
  void initState() {
    super.initState();
    videos = _loadVideos();
  }

  List<Video> _loadVideos() {
    final List<dynamic> videoDataList = jsonDecode(jsonData);
    return videoDataList.map<Video>((videoData) => Video.fromJson(videoData)).toList();
  }

  Map<String, List<Video>> _groupVideosByDate(List<Video> videos) {
    final Map<String, List<Video>> groupedVideos = {};

    for (var video in videos) {
      String formattedDate = _formatDate(video.dateWatched);
      if (groupedVideos.containsKey(formattedDate)) {
        groupedVideos[formattedDate]!.add(video);
      } else {
        groupedVideos[formattedDate] = [video];
      }
    }

    return groupedVideos;
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
    final Map<String, List<Video>> groupedVideos = _groupVideosByDate(videos);
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;

    if (screenWidth >= 600 && screenWidth < 1200) {
      crossAxisCount = 2;
    } else if (screenWidth >= 1200) {
      crossAxisCount = 3;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: groupedVideos.entries.map((entry) {
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
                VideoGridView(
                  videos: entry.value,
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

class VideoGridView extends StatelessWidget {
  final List<Video> videos;
  final int crossAxisCount;

  const VideoGridView({
    super.key,
    required this.videos,
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
      itemCount: videos.length,
      itemBuilder: (BuildContext context, int index) {
        final Video video = videos[index];

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
                  video.thumbnailLink,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          video.watchedTime,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
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