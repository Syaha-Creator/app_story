import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/story_provider.dart';
import 'widgets/animate_story_item.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showSuccessAnim = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialStories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitialStories() {
    final provider = Provider.of<StoryProvider>(context, listen: false);
    if (provider.stories.isEmpty) {
      provider.fetchStories(refresh: true);
    }
  }

  void _onScroll() {
    final provider = Provider.of<StoryProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isFetchingMore &&
        provider.hasMore) {
      provider.fetchMoreStories();
    }
  }

  Future<void> _refreshStories() async {
    await Provider.of<StoryProvider>(
      context,
      listen: false,
    ).fetchStories(refresh: true);

    setState(() {
      _showSuccessAnim = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccessAnim = false;
        });
      }
    });
  }

  Future<void> _logout() async {
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
            if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (storyProvider.errorMessage.isNotEmpty &&
                storyProvider.stories.isEmpty) {
              return _buildErrorState(l10n);
            }

            if (storyProvider.stories.isEmpty) {
              return Center(child: Text(l10n.emptyStories));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount:
                  storyProvider.hasMore
                      ? storyProvider.stories.length + 1
                      : storyProvider.stories.length,
              itemBuilder: (context, index) {
                if (index == 0 && _showSuccessAnim) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.refreshSuccess,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (index < storyProvider.stories.length) {
                  final story = storyProvider.stories[index];
                  return AnimatedStoryItem(
                    index: index,
                    child: StoryItem(
                      story: story,
                      onTap: () => widget.onStoryTap(story.id),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
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

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            l10n.error(Provider.of<StoryProvider>(context).errorMessage),
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
}
