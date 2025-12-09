import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/main/main_components/main_snackbar_widget.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';

class SearchPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const SearchPage({super.key, this.onBroadcast});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _stores = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStores() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.showSnackBar("Enter a store name.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await storefrontService.searchStorefrontsByName(query);
      if (!mounted) return;

      setState(() => _stores = results);
    } catch (_) {
      if (mounted) {
        context.showSnackBar("Search failed.", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Store Search',
      subtitle: 'Find stores by name',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Stores',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _searchStores(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _searchStores,
            child: const Text('Search'),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_stores.isEmpty)
            const Text('No results found.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stores.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = _stores[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['business_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (store['description'] != null &&
                          store['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            store['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      if (store['postal_code'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Postal Code: ${store['postal_code']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
