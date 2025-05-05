import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<Booking> _userBookings = [];
  Booking? _currentBooking;
  bool _isLoading = false;
  String? _error;

  List<Booking> get userBookings => _userBookings;
  Booking? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createBooking({
    required String carId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final booking = await _bookingService.createBooking(
        carId: carId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
      );

      _currentBooking = booking;
      _userBookings.add(booking);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadUserBookings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userBookings = await _bookingService.getUserBookings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedBooking = await _bookingService.updateBookingStatus(
        bookingId,
        status,
      );
      if (updatedBooking != null) {
        final index = _userBookings.indexWhere(
          (booking) => booking.id == bookingId,
        );
        if (index != -1) {
          _userBookings[index] = updatedBooking;
        }
        if (_currentBooking?.id == bookingId) {
          _currentBooking = updatedBooking;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> checkCarAvailability(
    String carId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _bookingService.isCarAvailable(carId, startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  double calculateBookingPrice(
    double pricePerDay,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _bookingService.calculateTotalPrice(pricePerDay, startDate, endDate);
  }
}
