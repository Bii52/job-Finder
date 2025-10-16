import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoriteJobs = authProvider.user?.favorites ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Jobs'),
        automaticallyImplyLeading: false,
      ),
      body: favoriteJobs.isEmpty
          ? const Center(
              child: Text('You have no favorite jobs yet.'),
            )
          : ListView.builder(
              itemCount: favoriteJobs.length,
              itemBuilder: (context, index) {
                final job = favoriteJobs[index];
                return ListTile(
                  title: Text(job.title),
                  subtitle: Text('${job.company} - ${job.location}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      authProvider.toggleFavorite(job.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
