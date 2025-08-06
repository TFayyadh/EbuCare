import 'package:ebucare_app/pages/resource_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EduPage extends StatefulWidget {
  const EduPage({super.key});

  @override
  State<EduPage> createState() => _EduPageState();
}

class _EduPageState extends State<EduPage> {
  Future<List<dynamic>> fetchResources() async {
    final data = await Supabase.instance.client
        .from('resources') // e.g., 'resources'
        .select()
        .eq('resource_type', 'Educational');

    return data;
  }

  Future<Set<String>> fetchUserFavourites(String userId) async {
    final data = await Supabase.instance.client
        .from('favourites')
        .select('article_id')
        .eq('user_id', userId);

    // Convert to a set of article IDs for fast lookup
    return data.map<String>((fav) => fav['article_id'].toString()).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 241, 238),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined)),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  "Educational Resources",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Calsans",
                      color: const Color.fromARGB(255, 106, 63, 114)),
                ),
              ),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
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
                                        builder: (context) =>
                                            ResourceDetailPage(
                                          resource: resource,
                                        ),
                                      ),
                                    ),
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 0),
                                      child: ListTile(
                                        trailing: IconButton(
                                          icon: Icon(
                                            isFavourited
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border_outlined,
                                            color: Color.fromARGB(
                                                255, 173, 131, 152),
                                          ),
                                          onPressed: () async {
                                            if (isFavourited) {
                                              // Remove from favourites
                                              await Supabase.instance.client
                                                  .from('favourites')
                                                  .delete()
                                                  .eq('user_id', userId)
                                                  .eq('article_id', articleId);
                                            } else {
                                              // Add to favourites
                                              await Supabase.instance.client
                                                  .from('favourites')
                                                  .insert({
                                                'user_id': userId,
                                                'article_id': articleId,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    resource["title"],
                                                    style: TextStyle(
                                                      fontFamily: "Calsans",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              resource['description'] ?? "",
                                              style: TextStyle(
                                                  fontFamily: "Raleway",
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14),
                                              maxLines: 4,
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
      ),
    );
  }
}
