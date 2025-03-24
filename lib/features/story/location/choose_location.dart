import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;
  String? _address;
  bool _showBottomInfo = false;

  void _onTap(LatLng pos) async {
    setState(() {
      _pickedLocation = pos;
      _address = null;
      _showBottomInfo = false;
    });

    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      setState(() {
        _address = "${place.name}, ${place.locality}, ${place.country}";
        _showBottomInfo = true;
      });
    }
  }

  void _confirmSelection() {
    if (_pickedLocation != null && _address != null) {
      Navigator.pop(context, {
        'location': _pickedLocation!,
        'address': _address!,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.200000, 106.816666),
              zoom: 12,
            ),
            onTap: _onTap,
            markers:
                _pickedLocation != null
                    ? {
                      Marker(
                        markerId: const MarkerId('picked'),
                        position: _pickedLocation!,
                        infoWindow: InfoWindow(
                          title: _address ?? 'Loading address...',
                        ),
                      ),
                    }
                    : {},
          ),
          if (_pickedLocation != null && _address != null && _showBottomInfo)
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_address!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _confirmSelection,
                      icon: const Icon(Icons.check),
                      label: const Text("Confirm Location"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
