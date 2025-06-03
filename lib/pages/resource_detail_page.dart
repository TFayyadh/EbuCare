import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceDetailPage extends StatelessWidget {
  final Map resource;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(resource["title"] ?? "Detail",
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: "Raleway",
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                resource['description'] ?? "No description",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Calsans",
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 16,
              ),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Text('Image not found'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
