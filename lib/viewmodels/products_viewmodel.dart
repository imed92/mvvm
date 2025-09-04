import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Ici on définit nos états des données

  // Une variable devient un état quand :
  // Sa valeur peut évoluer dans le temps.
  // Ce changement a un impact direct sur ce que l’UI doit afficher.
  // États des données
  List<Product> _products = [];                       // Liste de produits (underscore = privé au fichier/bibliothèque)
  bool _isLoading = false;                            // Indique si un chargement est en cours
  String _errorMessage = '';                          // Message d’erreur lisible par l’UI (chaîne vide = pas d’erreur)

  // Getters publics
  List<Product> get products => _products;            // Expose la liste en lecture seule (pas de setter public)
  bool get isLoading => _isLoading;                   // Expose l’état de chargement à l’UI
  String get errorMessage => _errorMessage;           // Expose le dernier message d’erreur
  bool get hasError => _errorMessage.isNotEmpty;      // Pratique : vrai s’il y a un message d’erreur non vide

  // Constructeur - chargement automatique
  ProductsViewModel() {                               // Constructeur du ViewModel
    loadProducts();                                   // Déclenche un premier chargement (attention au double fetch, voir note)
  }

  // Chargement des produits
  Future<void> loadProducts() async {                 // Méthode asynchrone : charge et met à jour l’état
    if (_isLoading) return;                           // Garde-fou : si un fetch est déjà en cours, on sort

    _isLoading = true;                                // Passe en mode "chargement…"
    _errorMessage = '';                               // Réinitialise l’erreur précédente
    notifyListeners();                                // Notifie l’UI (pour afficher le spinner par ex.)

    try {
      _products = await _apiService.fetchProducts();  // Appel réseau (await) : récupère les produits via le service
    } catch (error) {
      _errorMessage = 'Impossible de charger les produits'; // En cas d’échec : fixe un message d’erreur pour l’UI
    }

    _isLoading = false;                               // Fin du chargement (réussi ou non)
    notifyListeners();                                // Notifie l’UI (masquer le spinner, afficher liste ou erreur)
  }
}