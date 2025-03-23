import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../flavors.dart';
import '../../../providers/story_provider.dart';
import '../location/choose_location.dart';

class AddStoryScreen extends StatefulWidget {
  final VoidCallback onStoryAdded;

  const AddStoryScreen({super.key, required this.onStoryAdded});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _uploadStory() async {
    if (_formKey.currentState!.validate() && _image != null) {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      final isPaid = F.appFlavor.isPaid;

      final success = await storyProvider.addStory(
        _image!,
        _descriptionController.text.trim(),
        location: isPaid ? _selectedLocation : null,
        address: isPaid ? _selectedAddress : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story uploaded successfully')),
        );
        widget.onStoryAdded();
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = result['location'] as LatLng;
        _selectedAddress = result['address'] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPaid = F.appFlavor.isPaid;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addStory)),
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_image != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select an image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _getImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(l10n.takePhoto),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _getImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: Text(l10n.chooseFromGallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (isPaid)
                    ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        _selectedAddress ?? 'Select Location',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  else
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.locationPaidOnly,
                        style: TextStyle(color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: storyProvider.isLoading ? null : _uploadStory,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        storyProvider.isLoading
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(l10n.loading),
                              ],
                            )
                            : Text(l10n.upload),
                  ),
                  const SizedBox(height: 16),
                  if (storyProvider.errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Theme.of(context).colorScheme.error.withAlpha(50),
                      child: Text(
                        storyProvider.errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
