class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final List<String> images;
  final List<String> categories;
  final bool isFavorite;
  final String? badge;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    List<String>? images,
    required this.categories,
    this.isFavorite = false,
    this.badge,
  }) : images = images ?? _generateFallbackGallery(imageUrl, categories);

  static List<String> _generateFallbackGallery(String primaryUrl, List<String> categories) {
    final list = [primaryUrl];
    final isBike = categories.any((c) => c.toLowerCase().contains('sepeda') || c.toLowerCase().contains('mtb'));
    final isHelmet = categories.any((c) => c.toLowerCase().contains('helm'));

    if (isBike) {
      list.addAll([
        'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=600&auto=format&fit=crop&q=80',
      ]);
    } else if (isHelmet) {
      list.addAll([
        'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1558980664-3a031cf67ea8?w=600&auto=format&fit=crop&q=80',
      ]);
    } else {
      list.addAll([
        'https://images.unsplash.com/photo-1517649763962-0c623266010b?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1502744688674-c619d1586c9e?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=600&auto=format&fit=crop&q=80',
      ]);
    }
    return list;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is int
          ? json['price']
          : (json['price'] != null ? int.tryParse(json['price'].toString()) ?? 0 : 0),
      imageUrl: json['imageUrl']?.toString() ??
          'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
      images: json['images'] != null
          ? List<String>.from(json['images'].map((x) => x.toString()))
          : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'].map((x) => x.toString()))
          : [],
      isFavorite: json['isFavorite'] == true,
      badge: json['badge']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'categories': categories,
      'isFavorite': isFavorite,
      'badge': badge,
    };
  }
}

