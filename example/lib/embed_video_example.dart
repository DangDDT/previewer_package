import 'package:flutter/material.dart';
import 'package:vif_previewer/previewer.dart';

class EmbedVideoExample extends StatefulWidget {
  const EmbedVideoExample({super.key});

  @override
  State<EmbedVideoExample> createState() => _EmbedVideoExampleState();
}

class _EmbedVideoExampleState extends State<EmbedVideoExample> {
  late final EmbedVideoPlayerController _controller;

  @override
  void initState() {
    _controller = EmbedVideoPlayerController(
      video: MediaPreviewData.fromNetwork(
        url:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        type: MediaType.video,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Embed Video Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Embed Video Example - Video from network'),
              const SizedBox(height: 20),
              Container(
                color: Colors.amber,
                height: 300,
                child: EmbedVideoPlayer(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
