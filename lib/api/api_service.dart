import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  // Mengambil seluruh data resep
  static Future<List<Recipe>> getRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List recipesJson = data['recipes'];
      return recipesJson.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat resep dari server');
    }
  }

  // Mengambil detail satu resep berdasarkan ID
  static Future<Recipe> getRecipeDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recipe.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail resep dari server');
    }
  }
}
