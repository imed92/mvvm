// 🛍️ MODÈLE PRODUIT - Représente un produit de Fake Store API
class Product {
  // 📊 PROPRIÉTÉS DU PRODUIT
  final int id;              // ID unique du produit
  final String title;        // Nom du produit
  final double price;        // Prix en dollars
  final String description;  // Description détaillée
  final String category;     // Catégorie (electronics, clothes, etc.)
  final String image;        // URL de l'image
  final Rating rating;       // Note et nombre d'avis

  // 🏗️ CONSTRUCTEUR - Obligatoire pour créer un Product
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // 🔄 FACTORY CONSTRUCTOR - Crée un Product à partir de JSON (API)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,                           // Récupère l'ID depuis le JSON
      title: json['title'] as String,                 // Récupère le titre
      price: (json['price'] as num).toDouble(),       // Convertit price en double
      description: json['description'] as String,      // Récupère la description
      category: json['category'] as String,           // Récupère la catégorie
      image: json['image'] as String,                 // Récupère l'URL image
      rating: Rating.fromJson(json['rating']),        // Crée Rating depuis sous-objet JSON
    );
  }

  // 📄 CONVERSION EN JSON - Pour sauvegarder en cache local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),  // Convertit Rating en JSON aussi
    };
  }

  // 💰 GETTER CALCULÉ - Prix formaté pour l'affichage
  String get formattedPrice => '${price.toStringAsFixed(2)} €';

  // ⭐ GETTER CALCULÉ - Affichage des étoiles avec note
  String get starsDisplay => '⭐ ${rating.rate.toStringAsFixed(1)} (${rating.count})';
}

// ⭐ MODÈLE RATING - Représente la note d'un produit
class Rating {
  final double rate;  // Note moyenne (ex: 4.2)
  final int count;    // Nombre d'avis (ex: 150)

  // 🏗️ CONSTRUCTEUR
  Rating({
    required this.rate,
    required this.count,
  });

  // 🔄 FACTORY depuis JSON - Fake Store API renvoie ça : {"rate": 4.2, "count": 150}
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num).toDouble(),  // Assure que c'est un double
      count: json['count'] as int,             // Assure que c'est un int
    );
  }

  // 📄 CONVERSION en JSON pour le cache
  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}