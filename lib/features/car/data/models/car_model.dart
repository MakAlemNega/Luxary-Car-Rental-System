import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String imageUrl;
  final String description;
  final List<String> features;
  final bool isAvailable;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.features,
    required this.isAvailable,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'features': features,
      'isAvailable': isAvailable,
    };
  }
}
