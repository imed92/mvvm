import 'dart:convert';  // Pour json.decode() et json.encode()
import 'package:http/http.dart' as http;  // Client HTTP pour les requêtes
import '../models/product.dart';  // Import de notre modèle

// 🌐 SERVICE API - Interface avec Fake Store API
class ApiService {
  // 🔗 CONSTANTES DE CONFIGURATION
  static const String baseUrl = 'https://fakestoreapi.com';  // URL de base de l'API
  static const Duration timeout = Duration(seconds: 10);     // Timeout pour éviter l'attente infinie

  // 🛍️ RÉCUPÉRER TOUS LES PRODUITS
  Future<List<Product>> fetchProducts() async {
    try {
      // 📝 LOG pour debugger (voir dans la console)
      print('🌐 Chargement des produits depuis Fake Store API...');

      // 📡 APPEL HTTP GET vers l'API
      final response = await http.get(
        Uri.parse('$baseUrl/products'),  // URL complète : https://fakestoreapi.com/products
        headers: {
          'Content-Type': 'application/json',  // Indique qu'on attend du JSON
        },
      ).timeout(timeout);  // Applique le timeout de 10 secondes

      // 📊 LOG de la réponse
      print('📡 Réponse reçue : ${response.statusCode}');

      // ✅ VÉRIFICATION DU STATUT HTTP
      if (response.statusCode == 200) {  // 200 = succès
        // 🔄 DÉCODAGE JSON - Transforme la string JSON en List<dynamic>
        final List<dynamic> jsonData = json.decode(response.body);

        print('📦 ${jsonData.length} produits trouvés');

        // 🏭 TRANSFORMATION - Chaque élément JSON devient un objet Product
        final products = jsonData.map((json) => Product.fromJson(json)).toList();

        print('✅ Produits chargés avec succès');
        return products;
      } else {
        // ❌ ERREUR HTTP (404, 500, etc.)
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      // 🚨 GESTION DES ERREURS (réseau, parsing, timeout, etc.)
      print('❌ Erreur lors du chargement des produits : $e');
      throw Exception('Impossible de charger les produits : $e');
    }
  }

  // 🔍 RÉCUPÉRER UN PRODUIT PAR ID
  Future<Product> fetchProduct(int id) async {
    try {
      print('🌐 Chargement du produit $id...');

      // 📡 APPEL API pour un produit spécifique
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),  // URL : https://fakestoreapi.com/products/1
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // 🔄 DÉCODAGE pour un seul produit (Map au lieu de List)
        final json = jsonDecode(response.body);
        final product = Product.fromJson(json);

        print('✅ Produit $id chargé : ${product.title}');
        return product;
      } else {
        throw Exception('Produit $id non trouvé');
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du produit $id : $e');
      throw Exception('Impossible de charger le produit : $e');
    }
  }

  // 📋 RÉCUPÉRER TOUTES LES CATÉGORIES
  Future<List<String>> fetchCategories() async {
    try {
      print('🌐 Chargement des catégories...');

      // 📡 APPEL API pour les catégories
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),  // Endpoint spécial pour catégories
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // 🔄 DÉCODAGE - L'API renvoie une simple List<String>
        final List<dynamic> categories = json.decode(response.body);
        final categoryList = categories.map((cat) => cat.toString()).toList();

        print('✅ ${categoryList.length} catégories chargées : $categoryList');
        return categoryList;
      } else {
        throw Exception('Erreur lors du chargement des catégories');
      }
    } catch (e) {
      print('❌ Erreur catégories : $e');
      throw Exception('Impossible de charger les catégories : $e');
    }
  }

  // 🏷️ RÉCUPÉRER PRODUITS PAR CATÉGORIE
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      print('🌐 Chargement des produits de la catégorie "$category"...');

      // 📡 APPEL API filtré par catégorie
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$category'),  // Ex: /products/category/electronics
      ).timeout(timeout);

      if (response.statusCode == 200) {
        // 🔄 DÉCODAGE similaire à fetchProducts()
        final List<dynamic> jsonData = json.decode(response.body);
        final products = jsonData.map((json) => Product.fromJson(json)).toList();

        print('✅ ${products.length} produits trouvés dans "$category"');
        return products;
      } else {
        throw Exception('Catégorie "$category" non trouvée');
      }
    } catch (e) {
      print('❌ Erreur catégorie "$category" : $e');
      throw Exception('Impossible de charger la catégorie : $e');
    }
  }
}