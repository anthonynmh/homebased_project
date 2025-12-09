import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_page.dart';
import 'package:homebased_project/mvp2/main/main_components/main_snackbar_widget.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_service.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';
import 'package:homebased_project/mvp2/app_components/app_text_field.dart';
import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/storefront/storefront_data/storefront_model.dart';

class SearchPage extends StatefulWidget {
  final void Function(String message)? onBroadcast;

  const SearchPage({super.key, this.onBroadcast});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Storefront> _stores = [];
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

      // Convert maps → Storefront objects
      final parsed = results.map((m) => Storefront.fromMap(m)).toList();

      if (!mounted) return;
      setState(() => _stores = parsed);
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
          AppTextField(
            label: 'Search Stores',
            controller: _searchController,
            icon: Icons.search,
            onComplete: _searchStores,
          ),

          AppFormButton(
            label: 'Search',
            onPressed: _isLoading ? null : _searchStores,
            isLoading: _isLoading,
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _stores[index];

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name
                      Text(
                        s.businessName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Description
                      if ((s.description ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            s.description!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                      // Postal Code
                      if (s.postalCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Postal Code: ${s.postalCode}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      // Logo preview if exists
                      if (s.logoUrl != null && s.logoUrl!.isNotEmpty)
                        FutureBuilder<String?>(
                          future: storefrontService.getStorefrontLogoSignedUrl(
                            s.id,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  snapshot.data!,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
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
