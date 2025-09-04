import 'package:flutter/foundation.dart';  // Pour ChangeNotifier
import '../models/product.dart';           // Notre modèle
import '../services/api_service.dart';     // Notre service API

// 🧠 VIEWMODEL PRODUITS - Logique métier pour la liste des produits (MVVM)
class ProductsViewModel extends ChangeNotifier {
  // 🔌 INJECTION DE DÉPENDANCE - Service pour les appels API
  final ApiService _apiService = ApiService();

  // 📊 ÉTATS DES DONNÉES PRIVÉS (encapsulation)
  List<Product> _allProducts = [];        // Tous les produits chargés depuis l'API
  List<Product> _filteredProducts = [];   // Produits après application des filtres
  List<String> _categories = [];          // Liste des catégories disponibles

  // 📊 ÉTATS DE L'UI PRIVÉS
  bool _isLoading = false;                // Indique si un chargement est en cours
  String _errorMessage = '';              // Message d'erreur à afficher
  String _selectedCategory = '';          // Catégorie actuellement sélectionnée
  String _searchQuery = '';               // Terme de recherche de l'utilisateur

  // 🔍 GETTERS PUBLICS - Interface publique du ViewModel (read-only)
  List<Product> get products => _filteredProducts.isEmpty ? _allProducts : _filteredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  int get productsCount => products.length;

  // 🚀 CONSTRUCTEUR - Appelé automatiquement à la création du ViewModel
  ProductsViewModel() {
    print('🧠 ProductsViewModel créé - Chargement initial...');
    // Chargement automatique des données au démarrage
    loadProducts();
    loadCategories();
  }

  // 🔄 FONCTION PRINCIPALE - Chargement des produits depuis l'API
  Future<void> loadProducts() async {
    // 🛡️ GARDE - Éviter les appels multiples simultanés
    if (_isLoading) {
      print('⚠️ Chargement déjà en cours, ignore...');
      return;  // Sort de la fonction si déjà en cours
    }

    print('📦 Début chargement des produits...');

    // 🔄 MISE À JOUR DE L'ÉTAT UI
    _setLoading(true);    // Active le loading spinner
    _clearError();        // Efface les erreurs précédentes

    try {
      // 📡 APPEL API via le service
      _allProducts = await _apiService.fetchProducts();
      print('✅ ${_allProducts.length} produits chargés dans le ViewModel');

      // 🎯 RÉAPPLICATION DES FILTRES existants (si l'utilisateur avait filtré)
      _applyFilters();

    } catch (error) {
      // 🚨 GESTION D'ERREUR - Capture toutes les exceptions
      print('❌ Erreur dans ProductsViewModel : $error');
      _setError('Impossible de charger les produits.\nVérifiez votre connexion internet.');
    } finally {
      // 🏁 NETTOYAGE - Exécuté même en cas d'erreur
      _setLoading(false);  // Désactive le loading spinner
    }
  }

  // 📋 CHARGEMENT DES CATÉGORIES (optionnel, non bloquant)
  Future<void> loadCategories() async {
    try {
      print('📋 Chargement des catégories...');
      _categories = await _apiService.fetchCategories();
      print('✅ ${_categories.length} catégories chargées');
      notifyListeners(); // Met à jour l'UI pour afficher les filtres
    } catch (error) {
      print('⚠️ Erreur chargement catégories (non bloquant) : $error');
      // On n'affiche pas d'erreur car les catégories sont optionnelles
    }
  }

  // 🔄 RAFRAÎCHISSEMENT - Pour le pull-to-refresh
  Future<void> refreshProducts() async {
    print('🔄 Rafraîchissement demandé par l'utilisateur');

        _clearError(); // Effacer les erreurs précédentes

    try {
      _setLoading(true);
      // Rechargement complet depuis l'API
      _allProducts = await _apiService.fetchProducts();
      _applyFilters(); // Réappliquer les filtres actuels

      print('✅ Rafraîchissement réussi');
    } catch (error) {
      print('❌ Erreur rafraîchissement : $error');
      _setError('Impossible de rafraîchir.\nTirez vers le bas pour réessayer.');
    } finally {
      _setLoading(false);
    }
  }

  // 🔍 RECHERCHE - Filtrer par nom/description
  void searchProducts(String query) {
    print('🔍 Recherche : "$query"');
    _searchQuery = query.toLowerCase().trim();  // Normalisation de la recherche
    _applyFilters();  // Applique immédiatement les filtres
  }

  // 🏷️ FILTRE PAR CATÉGORIE
  void filterByCategory(String category) {
    print('🏷️ Filtrage par catégorie : "$category"');
    _selectedCategory = category;
    _applyFilters();  // Applique immédiatement les filtres
  }

  // 🎯 LOGIQUE DE FILTRAGE - Fonction privée centrale
  void _applyFilters() {
    print('🎯 Application des filtres...');

    // 🔍 FILTRAGE avec méthode where() (programmation fonctionnelle)
    _filteredProducts = _allProducts.where((product) {
      // 🏷️ FILTRE CATÉGORIE - Vérifie si le produit correspond à la catégorie
      bool matchesCategory = _selectedCategory.isEmpty ||           // Pas de filtre
          _selectedCategory.toLowerCase() == 'all' ||               // "Tous" sélectionné
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 🔍 FILTRE RECHERCHE - Cherche dans le titre ET la description
      bool matchesSearch = _searchQuery.isEmpty ||                  // Pas de recherche
          product.title.toLowerCase().contains(_searchQuery) ||     // Trouve dans le titre
          product.description.toLowerCase().contains(_searchQuery); // Trouve dans la description

      // ✅ RETOURNE TRUE si les deux conditions sont remplies
      return matchesCategory && matchesSearch;
    }).toList();

    print('✅ Filtres appliqués : ${_filteredProducts.length} produits affichés');
    notifyListeners(); // Met à jour l'UI avec les nouveaux résultats
  }

  // 🗑️ RÉINITIALISATION - Efface tous les filtres
  void clearFilters() {
    print('🗑️ Réinitialisation des filtres');
    _selectedCategory = '';
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners(); // Met à jour l'UI
  }

  // 🔍 UTILITAIRE - Trouver un produit par son ID
  Product? findProductById(int id) {
    try {
      // Utilise firstWhere pour trouver le premier produit correspondant
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      print('⚠️ Produit $id non trouvé');
      return null;  // Retourne null si pas trouvé
    }
  }

  // 🛠️ MÉTHODES PRIVÉES - Gestion interne de l'état

  // 🔄 Met à jour l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Met à jour l'UI (affiche/cache le loading spinner)
  }

  // 🚨 Met à jour l'état d'erreur
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;     // Désactive le loading en cas d'erreur
    notifyListeners();      // Met à jour l'UI (affiche le message d'erreur)
  }

  // 🧹 Efface les erreurs
  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // 🧹 NETTOYAGE MÉMOIRE - Appelé quand le ViewModel est détruit
  @override
  void dispose() {
    print('🧹 ProductsViewModel détruit - Nettoyage mémoire');
    super.dispose();  // Appel au dispose parent
  }
}