import 'package:flutter/material.dart';
import 'package:provider/provider.dart';              // Pour Consumer et context.read
import 'package:cached_network_image/cached_network_image.dart';  // Images optimisées
import '../viewmodels/products_viewmodel.dart';       // Notre ViewModel
import '../models/product.dart';                      // Notre Model
import '../widgets/drawer.dart';                      // Drawer existant

// 📱 PAGE PRODUITS - Interface utilisateur (VIEW dans MVVM)
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // 🔍 CONTROLLER pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // 🧹 NETTOYAGE - Libère la mémoire du controller
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📋 BARRE D'APPLICATION
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // 🛒 ICÔNE PANIER (pour plus tard)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Naviguer vers le panier
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Panier bientôt disponible !')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),  // Drawer existant

      // 📐 LAYOUT PRINCIPAL - Colonne avec recherche + filtres + liste
      body: Column(
        children: [
          // 🔍 SECTION RECHERCHE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),  // Icône de recherche
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // 🧹 EFFACER LA RECHERCHE
                    _searchController.clear();
                    // 🧠 NOTIFIER LE VIEWMODEL que la recherche est vide
                    context.read<ProductsViewModel>().searchProducts('');
                  },
                ),
              ),
              // 🔄 RÉACTIVITÉ - À chaque caractère tapé
              onChanged: (query) {
                // 🧠 NOTIFIER LE VIEWMODEL de la nouvelle recherche
                context.read<ProductsViewModel>().searchProducts(query);
              },
            ),
          ),

          // 📋 SECTION FILTRES
          _buildCategoryFilters(),

          // 🛍️ SECTION PRINCIPALE - Liste des produits
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
    );
  }

  // 📋 WIDGET DES FILTRES CATÉGORIES
  Widget _buildCategoryFilters() {
    // 🎧 CONSUMER - Écoute les changements du ViewModel
    return Consumer<ProductsViewModel>(
      builder: (context, viewModel, child) {
        // 🚫 MASQUER si pas de catégories
        if (viewModel.categories.isEmpty) {
          return const SizedBox.shrink(); // Widget vide
        }

        // 📜 LISTE HORIZONTALE des filtres
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,    // Scroll horizontal
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.categories.length + 1,  // +1 pour le bouton "Tous"
            itemBuilder: (context, index) {
              if (index == 0) {
                // 🏷️ PREMIER ÉLÉMENT - Bouton "Tous"
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('Tous'),
                    selected: viewModel.selectedCategory.isEmpty,  // Sélectionné si pas de filtre
                    onSelected: (_) => viewModel.filterByCategory(''),  // Réinitialise le filtre
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue[100],
                  ),
                );
              }

              // 🏷️ AUTRES ÉLÉMENTS - Boutons des catégories
              final category = viewModel.categories[index - 1];  // -1 car index 0 = "Tous"
              final isSelected = viewModel.selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(_formatCategoryName(category)),
                  selected: isSelected,
                  onSelected: (_) => viewModel.filterByCategory(category),  // Applique le filtre
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[100],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 🛍️ WIDGET PRINCIPAL - Liste des produits avec tous les états possibles
  Widget _buildProductsList() {
    // 🎧 CONSUMER - Réagit aux changements du ViewModel
    return Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {