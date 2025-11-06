import 'package:flutter/material.dart';
import 'package:homebased_project/backend/business_profile_api/business_profile_model.dart';
import 'package:homebased_project/backend/map_api/map_variants_model.dart';
import 'package:latlong2/latlong.dart';

class BusinessCustomerPage extends StatelessWidget {
  final BusinessProfile businessProfile;

  const BusinessCustomerPage({super.key, required this.businessProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250, // adjust height for the logo
            pinned: true, // keeps app bar visible when scrolling
            automaticallyImplyLeading: true, // back button appears
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            (businessProfile.logoUrl != null &&
                                businessProfile.logoUrl!.isNotEmpty)
                            ? NetworkImage(businessProfile.logoUrl!)
                            : const AssetImage('assets/defaultUser.png')
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              //name section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      businessProfile.businessName ?? 'Unnamed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              //Location Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (businessProfile.latitude != null &&
                        businessProfile.longitude != null)
                      SizedBox(
                        height: 200,
                        child: SingleMarkerMap(
                          initialCenter: LatLng(
                            businessProfile.latitude!,
                            businessProfile.longitude!,
                          ),
                          zoom: 15,
                          readOnly: true,
                          logoUrl:
                              businessProfile.logoUrl ??
                              'assets/defaultUser.png',
                        ),
                      )
                    else
                      const Text('Location not available'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              //Gallery Section (if any images available)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // TODO: Implement gallery view if images are available
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
