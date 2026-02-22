import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/kendaraan_repository.dart';
import '../data/kendaraan_model.dart';

class KendaraanDetailScreen extends StatelessWidget {
  final int id;
  const KendaraanDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kendaraan')),
      body: FutureBuilder<Kendaraan>(
        future: RepositoryProvider.of<KendaraanRepository>(context).getDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final k = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (k.photos.isNotEmpty) SizedBox(height: 180, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: k.photos.length, itemBuilder: (c, i) => Padding(padding: const EdgeInsets.only(right:8.0), child: Image.network(k.photos[i])))),
                const SizedBox(height: 12),
                Text('Merk: ${k.merk}'),
                Text('Model: ${k.model}'),
                Text('Nomor Polisi: ${k.nomorPolisi}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
