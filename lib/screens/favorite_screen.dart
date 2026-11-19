import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),
      appBar: AppBar(
        title: const Text(
          'Favorite',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B050),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ValueListenableBuilder mendengarkan langsung Box 'favorites' dari Hive.
      // Jika terjadi penambahan/penghapusan baik dari halaman ini maupun halaman detail,
      // tampilan list akan otomatis ter-update seketika.
      body: ValueListenableBuilder(
        valueListenable: Hive.box('favorites').listenable(),
        builder: (context, Box box, child) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada resep favorit',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final keys = box.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final raw = box.get(key);

              if (raw == null) return const SizedBox.shrink();

              final recipe = Recipe.fromMap(
                raw is Map ? raw : Map<dynamic, dynamic>.from(raw),
              );

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe.image,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 65,
                          height: 65,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${recipe.cuisine} • ${recipe.difficulty}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Tombol hapus dari favorite di sisi kanan (trailing)
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Hapus Favorite',
                    onPressed: () {
                      box.delete(key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dihapus dari favorite'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(recipeId: recipe.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
