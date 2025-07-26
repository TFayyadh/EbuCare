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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(resource["title"] ?? "Detail",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontFamily: "Calsans",
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 195, 195),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  resource['description'] ?? "No description",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Calsans",
                      fontWeight: FontWeight.normal),
                ),
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
