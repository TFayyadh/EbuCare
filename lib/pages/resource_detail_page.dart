import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_html/flutter_html.dart';

class ResourceDetailPage extends StatelessWidget {
  final Map<String, dynamic> resource;

  const ResourceDetailPage({super.key, required this.resource});

  String getPublicImageUrl(String path) {
    final supabase = Supabase.instance.client;
    return supabase.storage.from('images').getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = resource['image_path'] ?? "";
    final imageUrl = imagePath.startsWith('http')
        ? imagePath
        : (imagePath.isNotEmpty ? getPublicImageUrl(imagePath) : null);

    final String title = resource["title"] ?? "Detail";
    // description column stores your HTML from the admin
    final String htmlDescription = resource['description'] ?? "No description";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Calsans",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Image not found'),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Purple card with HTML content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 134, 61, 95),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Html(
                  data: htmlDescription,
                  style: {
                    "body": Style(
                      color: Colors.white,
                      fontSize: FontSize(14),
                      fontFamily: "Raleway",
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 8),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
