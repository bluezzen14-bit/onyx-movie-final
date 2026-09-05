import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import '../widgets/liquid_glass.dart';
import '../services/download_service.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const PlayerScreen({super.key, required this.videoUrl, required this.title});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late BetterPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(autoPlay: true, aspectRatio: 16/9),
      betterPlayerDataSource: BetterPlayerDataSource.network(widget.videoUrl),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          BetterPlayer(controller: _controller),
          Positioned(
            top: 40, left: 16, right: 16,
            child: LiquidGlass(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
                  Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white))),
                  IconButton(icon: const Icon(Icons.cast, color: Colors.white), onPressed: (){}),
                  IconButton(icon: const Icon(Icons.download, color: Colors.white), onPressed: () async {
                    await DownloadService.downloadToGallery(widget.videoUrl, "${widget.title}.mp4");
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Gallery/Onyx Movies/Movies & Series")));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
