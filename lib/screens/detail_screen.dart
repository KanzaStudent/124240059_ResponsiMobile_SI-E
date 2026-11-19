import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_service.dart';
import '../models/recipe.dart';

class DetailScreen extends StatefulWidget {
  final int recipeId;

  const DetailScreen({super.key, required this.recipeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  // Mengambil detail resep dari API atau fallback dari Hive jika offline
  Future<void> _fetchDetail() async {
    try {
      final recipe = await ApiService.getRecipeDetail(widget.recipeId);
      if (mounted) {
        setState(() {
          _recipe = recipe;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback: Jika koneksi gagal, periksa apakah data tersimpan di Box Favorite Hive
      final box = Hive.box('favorites');
      if (box.containsKey(widget.recipeId.toString())) {
        final raw = box.get(widget.recipeId.toString());
        if (mounted) {
          setState(() {
            _recipe = Recipe.fromMap(
              raw is Map ? raw : Map<dynamic, dynamic>.from(raw),
            );
            _isLoading = false;
          });
          return;
        }
      }

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Helper widget untuk badge info resep
  Widget _infoBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF00B050)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Resep',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B050),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ValueListenableBuilder agar ikon favorit selalu reaktif terhadap perubahan database Hive
          ValueListenableBuilder(
            valueListenable: Hive.box('favorites').listenable(),
            builder: (context, Box box, child) {
              final isFav = box.containsKey(widget.recipeId.toString());

              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.yellowAccent : Colors.white,
                ),
                tooltip: isFav ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
                onPressed: () {
                  if (_recipe == null) return;

                  if (isFav) {
                    box.delete(widget.recipeId.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dihapus dari favorite'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    box.put(widget.recipeId.toString(), _recipe!.toMap());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ditambahkan ke favorite'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gagal memuat: $_errorMessage'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });
                            _fetchDetail();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _recipe == null
                  ? const Center(child: Text('Data resep tidak ditemukan'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Wajib menampilkan gambar dengan exception handling
                          Image.network(
                            _recipe!.image,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 250,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 2. Wajib menampilkan judul data
                                Text(
                                  _recipe!.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_recipe!.cuisine} • ${_recipe!.mealType.join(", ")}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Deretan info ringkas (Rating, difficulty, waktu, kalori)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _infoBadge(
                                      icon: Icons.star,
                                      text:
                                          '${_recipe!.rating} (${_recipe!.reviewCount})',
                                    ),
                                    _infoBadge(
                                      icon: Icons.speed,
                                      text: _recipe!.difficulty,
                                    ),
                                    _infoBadge(
                                      icon: Icons.timer_outlined,
                                      text:
                                          'Persiapan ${_recipe!.prepTimeMinutes} mnt',
                                    ),
                                    _infoBadge(
                                      icon: Icons.restaurant,
                                      text:
                                          'Masak ${_recipe!.cookTimeMinutes} mnt',
                                    ),
                                    _infoBadge(
                                      icon: Icons.people_outline,
                                      text: '${_recipe!.servings} porsi',
                                    ),
                                    _infoBadge(
                                      icon: Icons.local_fire_department,
                                      text:
                                          '${_recipe!.caloriesPerServing} kal/porsi',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 10),

                                // 3. Wajib menampilkan bahan-bahan data
                                const Text(
                                  'Bahan-bahan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ..._recipe!.ingredients.map(
                                  (ingredient) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00B050),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ingredient,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 10),

                                // 4. Wajib menampilkan intruksi data (langkah-langkah memasak)
                                const Text(
                                  'Langkah Memasak',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._recipe!.instructions
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final stepIndex = entry.key + 1;
                                  final instruction = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              const Color(0xFF00B050),
                                          child: Text(
                                            '$stepIndex',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            instruction,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
