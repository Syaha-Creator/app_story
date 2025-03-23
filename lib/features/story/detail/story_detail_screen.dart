import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';

import '../../../providers/story_provider.dart';
import '../home/widgets/cached_network_image.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  String _address = '';
  LatLng? _location;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      final provider = Provider.of<StoryProvider>(context, listen: false);

      Future.microtask(() async {
        final story = await provider.fetchStoryDetail(widget.storyId);

        if (!mounted) return;

        if (story != null && story.lat != null && story.lon != null) {
          _location = LatLng(story.lat!, story.lon!);
          _resolveAddress(story.lat!, story.lon!);
        } else {
          _location = null;
          setState(() => _address = '');
        }
      });
    }
  }

  Future<void> _resolveAddress(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              '${p.street}, ${p.subLocality}, ${p.locality}, ${p.country}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _address = 'Unknown location');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storyDetail)),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, _) {
          if (storyProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loading),
                ],
              ),
            );
          }

          if (storyProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    l10n.error(storyProvider.errorMessage),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final story = storyProvider.selectedStory;
          if (story == null) {
            return const Center(child: Text('Story not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'story-image-${story.id}',
                  child: AppCachedNetworkImage(
                    imageUrl: story.photoUrl,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              story.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  DateTime.parse(
                                    story.createdAt,
                                  ).toLocal().toString().substring(0, 16),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        story.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_location != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Location:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(_address),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _location!,
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('story-location'),
                                position: _location!,
                                infoWindow: InfoWindow(title: story.name),
                              ),
                            },
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
