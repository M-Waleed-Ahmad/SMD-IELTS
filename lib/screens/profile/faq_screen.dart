import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: FutureBuilder<List<dynamic>>(
        future: api.getFaqs(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final f = items[i];
              return Card(
                child: ExpansionTile(
                  title: Text(f['question'] ?? ''),
                  subtitle: Text(f['category'] ?? ''),
                  children: [
                    Padding(padding: const EdgeInsets.all(16), child: Text(f['answer'] ?? '')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

