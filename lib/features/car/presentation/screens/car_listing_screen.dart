import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/car_model.dart';
import '../../data/providers/car_provider.dart';
import 'car_detail_screen.dart';

class CarListingScreen extends StatefulWidget {
  const CarListingScreen({super.key});

  @override
  State<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBrand;
  double _maxPrice = 1000;
  int _minYear = 2020;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarProvider>().loadCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cars...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                context.read<CarProvider>().filterCars(
                  searchQuery: value,
                  brand: _selectedBrand,
                  maxPrice: _maxPrice,
                  minYear: _minYear,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<CarProvider>(
              builder: (context, carProvider, child) {
                if (carProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (carProvider.error != null) {
                  return Center(child: Text(carProvider.error!));
                }

                final cars = carProvider.filteredCars;
                if (cars.isEmpty) {
                  return const Center(child: Text('No cars found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return CarListItem(
                      car: car,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CarDetailScreen(carId: car.id),
                            ),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Cars'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  hint: const Text('Select Brand'),
                  items: const [
                    DropdownMenuItem(value: 'BMW', child: Text('BMW')),
                    DropdownMenuItem(
                      value: 'Mercedes',
                      child: Text('Mercedes'),
                    ),
                    DropdownMenuItem(value: 'Audi', child: Text('Audi')),
                    DropdownMenuItem(value: 'Porsche', child: Text('Porsche')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedBrand = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Max Price: '),
                    Expanded(
                      child: Slider(
                        value: _maxPrice,
                        min: 100,
                        max: 1000,
                        divisions: 18,
                        label: '${_maxPrice.round()}',
                        onChanged: (value) {
                          setState(() => _maxPrice = value);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Min Year: '),
                    Expanded(
                      child: Slider(
                        value: _minYear.toDouble(),
                        min: 2015,
                        max: 2024,
                        divisions: 9,
                        label: _minYear.toString(),
                        onChanged: (value) {
                          setState(() => _minYear = value.round());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<CarProvider>().filterCars(
                    brand: _selectedBrand,
                    maxPrice: _maxPrice,
                    minYear: _minYear,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }
}

class CarListItem extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarListItem({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                car.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.directions_car,
                      size: 64,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${car.brand} ${car.model} ${car.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${car.price.toStringAsFixed(2)} per day',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!car.isAvailable)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Not Available',
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
