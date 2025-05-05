import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import '../models/car_model.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger('CarService');

  Future<List<Car>> getCars() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('cars').get();
      return snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
    } catch (e) {
      _logger.severe('Error fetching cars', e);
      return [];
    }
  }

  Future<List<Car>> searchCars({
    String? brand,
    double? maxPrice,
    int? minYear,
    bool? isAvailable,
  }) async {
    try {
      Query query = _firestore.collection('cars');

      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      if (minYear != null) {
        query = query.where('year', isGreaterThanOrEqualTo: minYear);
      }
      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
    } catch (e) {
      _logger.severe('Error searching cars', e);
      return [];
    }
  }

  Future<Car?> getCarById(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('cars').doc(id).get();
      if (doc.exists) {
        return Car.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.severe('Error fetching car by id: $id', e);
      return null;
    }
  }
}
