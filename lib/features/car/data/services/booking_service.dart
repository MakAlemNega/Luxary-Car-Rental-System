import '../models/booking_model.dart';
import 'package:logging/logging.dart';

class BookingService {
  // Simulated database for bookings
  final List<Booking> _bookings = [];
  final _logger = Logger('BookingService');

  // Create a new booking
  Future<Booking> createBooking({
    required String carId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        carId: carId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      _bookings.add(booking);
      _logger.info('Created new booking with ID: ${booking.id}');
      return booking;
    } catch (e) {
      _logger.severe('Error creating booking', e);
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get all bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final bookings =
          _bookings.where((booking) => booking.userId == userId).toList();
      _logger.info('Retrieved ${bookings.length} bookings for user: $userId');
      return bookings;
    } catch (e) {
      _logger.severe('Error fetching user bookings for userId: $userId', e);
      return [];
    }
  }

  // Get all bookings for a car
  Future<List<Booking>> getCarBookings(String carId) async {
    try {
      final bookings =
          _bookings.where((booking) => booking.carId == carId).toList();
      _logger.info('Retrieved ${bookings.length} bookings for car: $carId');
      return bookings;
    } catch (e) {
      _logger.severe('Error fetching car bookings for carId: $carId', e);
      return [];
    }
  }

  // Update booking status
  Future<Booking?> updateBookingStatus(String bookingId, String status) async {
    try {
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        final updatedBooking = _bookings[index].copyWith(status: status);
        _bookings[index] = updatedBooking;
        _logger.info('Updated booking status: $bookingId to $status');
        return updatedBooking;
      }
      _logger.warning('Booking not found with ID: $bookingId');
      return null;
    } catch (e) {
      _logger.severe(
        'Error updating booking status for bookingId: $bookingId',
        e,
      );
      return null;
    }
  }

  // Check if a car is available for the given dates
  Future<bool> isCarAvailable(
    String carId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final carBookings = await getCarBookings(carId);
    return !carBookings.any(
      (booking) =>
          booking.status != 'cancelled' &&
          !(endDate.isBefore(booking.startDate) ||
              startDate.isAfter(booking.endDate)),
    );
  }

  // Calculate total price for booking period
  double calculateTotalPrice(
    double pricePerDay,
    DateTime startDate,
    DateTime endDate,
  ) {
    final days = endDate.difference(startDate).inDays + 1;
    return pricePerDay * days;
  }
}
