import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/story_provider.dart';
import 'widgets/language_dropdown.dart';
import 'widgets/story_item.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onAddStoryNavigate;
  final Function(String id) onStoryTap;

  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onAddStoryNavigate,
    required this.onStoryTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Future.microtask(() {
        _refreshStories();
      });
    }
  }

  Future<void> _refreshStories() async {
    await Provider.of<StoryProvider>(context, listen: false).fetchStories();
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const LanguageDropdown(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStories,
        child: Consumer<StoryProvider>(
          builder: (context, storyProvider, _) {
            if (storyProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (storyProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.error(storyProvider.errorMessage),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshStories,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (storyProvider.stories.isEmpty) {
              return Center(child: Text(l10n.emptyStories));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: storyProvider.stories.length,
              itemBuilder: (context, index) {
                final story = storyProvider.stories[index];
                return StoryItem(
                  story: story,
                  onTap: () => widget.onStoryTap(story.id),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddStoryNavigate,
        tooltip: l10n.addStory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
