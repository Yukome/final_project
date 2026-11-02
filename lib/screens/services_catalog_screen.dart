import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/service_list_notifier.dart';
import '../core/load_status.dart';
import '../models/service.dart';

class ServicesCatalogScreen extends StatefulWidget {
  const ServicesCatalogScreen({super.key});

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceListNotifier>().setSearch('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ServiceListNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: const Text('Услуги клиники'),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Поиск по названию услуги',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
            ),
          ),
          
          Expanded(
            child: switch (notifier.status) {
              LoadStatus.idle || LoadStatus.loading => const Center(child: CircularProgressIndicator()),
              LoadStatus.error => Center(child: Text(notifier.error ?? 'Ошибка')),
              LoadStatus.success => _buildGrid(notifier.result.items),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Service> allItems) {
    final items = allItems.where((s) => s.name.toLowerCase().contains(_searchQuery)).toList();

    if (items.isEmpty) {
      return const Center(child: Text('Услуг не найдено'));
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;

    double cardWidth;
    double cardHeight;
    double maxContainerWidth;

    if (screenWidth < 768) {
      cardWidth = 260;
      cardHeight = 340;
      maxContainerWidth = cardWidth;
    } else if (screenWidth < 1280) {
      cardWidth = 280;
      cardHeight = 360;
      maxContainerWidth = (cardWidth * 3) + 32;
    } else if (screenWidth < 1600) {
      cardWidth = 300;
      cardHeight = 380;
      maxContainerWidth = (cardWidth * 4) + 48;
    } else {
      cardWidth = 300;
      cardHeight = 380;
      maxContainerWidth = (cardWidth * 4) + 48;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 768 ? 16 : 24,
        screenWidth < 768 ? 16 : 24,
        screenWidth < 768 ? 16 : 24,
        screenWidth < 768 ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContainerWidth),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: items.map((service) {
              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.medical_services,
                              size: screenWidth < 768 ? 64 : 48,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${service.price} руб.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}