import 'package:example/custom_preview_page.dart';
import 'package:example/embed_video_example.dart';
import 'package:example/paging_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:vif_previewer/previewer.dart';

const images = [
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg"
];
const videos = [
  "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.jpg",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
  "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
];

//Random add two list together
final testMedias = List<MediaPreviewData>.generate(
  images.length + videos.length,
  (index) {
    final isVideo = index % 2 == 0;
    final data = isVideo ? videos[index ~/ 2] : images[index ~/ 2];
    return MediaPreviewData.fromNetwork(
      url: data,
      type: isVideo ? MediaType.video : MediaType.image,
      heroTag: 'media_$data',
    );
  },
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PreviewerCatalog(),
    );
  }
}

class CatalogItem {
  const CatalogItem({
    required this.title,
    required this.description,
    required this.route,
  });

  final String title;
  final String description;
  final Widget route;
}

class PreviewerCatalog extends StatelessWidget {
  const PreviewerCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogs = [
      CatalogItem(
        title: 'Media Paging Preview',
        description: 'vif_previewer with media preview page and paging',
        route: PagingPreviewPage(testMedias: testMedias),
      ),
      const CatalogItem(
        title: 'Embed Video Player',
        description:
            'vif_previewer with embed video player for video preview in page',
        route: EmbedVideoExample(),
      ),
      const CatalogItem(
        title: 'Custom Preview Page',
        description:
            'vif_previewer with custom preview page and custom media preview controller',
        route: CustomPreviewPage(),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('vif_previewer Catalog'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: catalogs.length,
        itemBuilder: (context, index) {
          final catalog = catalogs[index];
          return Card(
            child: ListTile(
              title: Text(catalog.title),
              subtitle: Text(catalog.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => catalog.route),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
