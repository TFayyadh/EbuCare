import 'package:ebucare_app/pages/resource_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_html/flutter_html.dart';

class TraditionalPage extends StatefulWidget {
  const TraditionalPage({super.key});

  @override
  State<TraditionalPage> createState() => _TraditionalPageState();
}

class _TraditionalPageState extends State<TraditionalPage> {
  Future<List<dynamic>> fetchResources() async {
    final data = await Supabase.instance.client
        .from('resources')
        .select()
        .eq('resource_type', 'Traditional');

    return data;
  }

  Future<Set<String>> fetchUserFavourites(String userId) async {
    final data = await Supabase.instance.client
        .from('favourites')
        .select('resource_id')
        .eq('user_id', userId);

    // Convert to a set of article IDs for fast lookup
    return data.map<String>((fav) => fav['resource_id'].toString()).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 247, 226, 226),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Text(
          "Traditional Tips",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Calsans",
            color: Color.fromARGB(255, 106, 63, 114),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchResources(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final resources = snapshot.data!;

                      return FutureBuilder<Set<String>>(
                        future: fetchUserFavourites(userId),
                        builder: (context, favSnapshot) {
                          if (favSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (favSnapshot.hasError) {
                            return Center(
                                child: Text("Error: ${favSnapshot.error}"));
                          }
                          final favourites = favSnapshot.data ?? {};

                          resources.sort((a, b) {
                            final aFav =
                                favourites.contains(a['id'].toString()) ? 1 : 0;
                            final bFav =
                                favourites.contains(b['id'].toString()) ? 1 : 0;
                            return bFav.compareTo(
                                aFav); // Descending: favourites first
                          });

                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {});
                            },
                            child: ListView.builder(
                              itemCount: resources.length,
                              itemBuilder: (context, index) {
                                final resource = resources[index];

                                final String articleId =
                                    resource['id'].toString();
                                final bool isFavourited =
                                    favourites.contains(articleId);

                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResourceDetailPage(
                                        resource:
                                            resource as Map<String, dynamic>,
                                      ),
                                    ),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 0),
                                    child: ListTile(
                                      trailing: IconButton(
                                        icon: Icon(
                                          isFavourited
                                              ? Icons.favorite
                                              : Icons.favorite_border_outlined,
                                          color: const Color.fromARGB(
                                              255, 173, 131, 152),
                                        ),
                                        onPressed: () async {
                                          if (isFavourited) {
                                            // Remove from favourites
                                            await Supabase.instance.client
                                                .from('favourites')
                                                .delete()
                                                .eq('user_id', userId)
                                                .eq('resource_id', articleId);
                                          } else {
                                            // Add to favourites
                                            await Supabase.instance.client
                                                .from('favourites')
                                                .insert({
                                              'user_id': userId,
                                              'resource_id': articleId,
                                            });
                                          }
                                          setState(() {});
                                        },
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  resource["title"] ?? "",
                                                  style: const TextStyle(
                                                    fontFamily: "Calsans",
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          // HTML preview for description
                                          Html(
                                            data: resource['description'] ?? "",
                                            style: {
                                              "body": Style(
                                                margin: Margins.zero,
                                                padding: HtmlPaddings.zero,
                                                maxLines: 3,
                                                fontSize: FontSize(14),
                                                fontFamily: "Raleway",
                                              ),
                                              "p": Style(
                                                margin: Margins.only(bottom: 4),
                                              ),
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
