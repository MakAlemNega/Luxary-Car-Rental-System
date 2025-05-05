import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/car_model.dart';
import '../../data/providers/booking_provider.dart';
import '../../data/providers/car_provider.dart';

class CarBookingScreen extends StatefulWidget {
  final String carId;

  const CarBookingScreen({super.key, required this.carId});

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Car')),
      body: FutureBuilder<Car?>(
        future: context.read<CarProvider>().getCarById(widget.carId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final car = snapshot.data;
          if (car == null) {
            return const Center(child: Text('Car not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${car.price.toStringAsFixed(2)} per day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Dates',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: 'Start Date',
                  value: _startDate,
                  onSelect: (date) {
                    setState(() {
                      _startDate = date;
                      _updateTotalPrice(car.price);
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  label: 'End Date',
                  value: _endDate,
                  onSelect: (date) {
                    setState(() {
                      _endDate = date;
                      _updateTotalPrice(car.price);
                    });
                  },
                ),
                if (_totalPrice != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${_totalPrice!.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canBook() ? () => _handleBooking(car) : null,
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? value,
    required Function(DateTime) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onSelect(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  value != null
                      ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _canBook() {
    return _startDate != null && _endDate != null && _totalPrice != null;
  }

  void _updateTotalPrice(double pricePerDay) {
    if (_startDate != null && _endDate != null) {
      final provider = context.read<BookingProvider>();
      _totalPrice = provider.calculateBookingPrice(
        pricePerDay,
        _startDate!,
        _endDate!,
      );
    }
  }

  Future<void> _handleBooking(Car car) async {
    if (!_canBook()) return;

    try {
      final bookingProvider = context.read<BookingProvider>();
      final isAvailable = await bookingProvider.checkCarAvailability(
        car.id,
        _startDate!,
        _endDate!,
      );

      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car is not available for selected dates'),
          ),
        );
        return;
      }

      await bookingProvider.createBooking(
        carId: car.id,
        userId: 'user123', // TODO: Get actual user ID
        startDate: _startDate!,
        endDate: _endDate!,
        totalPrice: _totalPrice!,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating booking: $e')));
    }
  }
}
