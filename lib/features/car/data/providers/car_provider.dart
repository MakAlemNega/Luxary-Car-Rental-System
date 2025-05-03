import 'package:flutter/foundation.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

class CarProvider with ChangeNotifier {
  final CarService _carService = CarService();
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = false;
  String? _error;

  List<Car> get cars => _cars;
  List<Car> get filteredCars => _filteredCars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCars() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cars = await _carService.getCars();
      _filteredCars = List.from(_cars);
    } catch (e) {
      _error = 'Failed to load cars: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCars({
    String? brand,
    double? maxPrice,
    int? minYear,
    bool? isAvailable,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredCars = await _carService.searchCars(
        brand: brand,
        maxPrice: maxPrice,
        minYear: minYear,
        isAvailable: isAvailable,
      );
    } catch (e) {
      _error = 'Failed to search cars: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Car?> getCarById(String id) async {
    try {
      return await _carService.getCarById(id);
    } catch (e) {
      _error = 'Failed to get car details: $e';
      notifyListeners();
      return null;
    }
  }

  void filterCars({
    String? searchQuery,
    String? brand,
    double? maxPrice,
    int? minYear,
    bool? isAvailable,
  }) {
    _filteredCars =
        _cars.where((car) {
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            if (!car.name.toLowerCase().contains(query) &&
                !car.brand.toLowerCase().contains(query) &&
                !car.model.toLowerCase().contains(query)) {
              return false;
            }
          }

          if (brand != null && brand.isNotEmpty && car.brand != brand) {
            return false;
          }

          if (maxPrice != null && car.price > maxPrice) {
            return false;
          }

          if (minYear != null && car.year < minYear) {
            return false;
          }

          if (isAvailable != null && car.isAvailable != isAvailable) {
            return false;
          }

          return true;
        }).toList();

    notifyListeners();
  }
}
