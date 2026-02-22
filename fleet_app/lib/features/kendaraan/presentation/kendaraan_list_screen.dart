import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/auth_cubit.dart';
import 'kendaraan_cubit.dart';
import 'kendaraan_form_screen.dart';
import 'kendaraan_detail_screen.dart';

class KendaraanListScreen extends StatelessWidget {
  const KendaraanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KendaraanCubit>();
    cubit.loadInitial();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan'),
        actions: [
          IconButton(onPressed: () => context.read<AuthCubit>().logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: BlocBuilder<KendaraanCubit, KendaraanState>(builder: (context, state) {
        if (state is KendaraanLoading) return const Center(child: CircularProgressIndicator());
        if (state is KendaraanLoaded) {
          return RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            child: ListView.builder(
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= state.items.length) {
                  cubit.loadMore();
                  return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
                }
                final k = state.items[i];
                return ListTile(
                  leading: k.photos.isNotEmpty ? Image.network(k.photos.first, width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.directions_car),
                  title: Text('${k.merk} ${k.model}'),
                  subtitle: Text(k.nomorPolisi),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => KendaraanDetailScreen(id: k.id))),
                );
              },
            ),
          );
        }
        if (state is KendaraanError) return Center(child: Text('Error: ${state.message}'));
        return const SizedBox.shrink();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KendaraanFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
