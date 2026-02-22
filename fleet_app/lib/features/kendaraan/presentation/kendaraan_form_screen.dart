import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'kendaraan_cubit.dart';

class FormState {
  final String merk;
  final String model;
  final String nomor;
  final List<File> photos;
  FormState({this.merk = '', this.model = '', this.nomor = '', List<File>? photos}) : photos = photos ?? [];

  FormState copyWith({String? merk, String? model, String? nomor, List<File>? photos}) => FormState(
    merk: merk ?? this.merk,
    model: model ?? this.model,
    nomor: nomor ?? this.nomor,
    photos: photos ?? List.from(this.photos),
  );
}

class FormCubit extends Cubit<FormState> {
  final ImagePicker _picker = ImagePicker();
  FormCubit(): super(FormState());

  void setMerk(String v) => emit(state.copyWith(merk: v));
  void setModel(String v) => emit(state.copyWith(model: v));
  void setNomor(String v) => emit(state.copyWith(nomor: v));

  Future<void> pickGallery() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      final files = images.map((e) => File(e.path)).toList();
      emit(state.copyWith(photos: [...state.photos, ...files]));
    }
  }

  Future<void> takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x != null) {
      emit(state.copyWith(photos: [...state.photos, File(x.path)]));
    }
  }
}

class KendaraanFormScreen extends StatelessWidget {
  final int? id;
  const KendaraanFormScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    final kendaraanCubit = context.read<KendaraanCubit>();
    return BlocProvider(
      create: (_) => FormCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(id == null ? 'Tambah Kendaraan' : 'Edit Kendaraan')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                BlocBuilder<FormCubit, FormState>(builder: (context, form) {
                  return Column(children: [
                    TextField(onChanged: context.read<FormCubit>().setMerk, decoration: InputDecoration(labelText: 'Merk'), controller: TextEditingController(text: form.merk)),
                    const SizedBox(height: 8),
                    TextField(onChanged: context.read<FormCubit>().setModel, decoration: InputDecoration(labelText: 'Model'), controller: TextEditingController(text: form.model)),
                    const SizedBox(height: 8),
                    TextField(onChanged: context.read<FormCubit>().setNomor, decoration: InputDecoration(labelText: 'Nomor Polisi'), controller: TextEditingController(text: form.nomor)),
                    const SizedBox(height: 12),
                    Row(children: [
                      ElevatedButton.icon(onPressed: () => context.read<FormCubit>().pickGallery(), icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(onPressed: () => context.read<FormCubit>().takePhoto(), icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                    ]),
                    const SizedBox(height: 12),
                    if (form.photos.isNotEmpty) SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: form.photos.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right:8.0), child: Image.file(form.photos[i])))),
                    const SizedBox(height: 16),
                    BlocConsumer<KendaraanCubit, KendaraanState>(
                      listener: (context, state) {
                        if (state is KendaraanSaving) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyimpan...')));
                        }
                        if (state is KendaraanLoaded) {
                          Navigator.of(context).pop();
                        }
                      },
                      builder: (context, state) {
                        return Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final formState = context.read<FormCubit>().state;
                                final payload = {
                                  'merk': formState.merk.trim(),
                                  'model': formState.model.trim(),
                                  'nomor_polisi': formState.nomor.trim(),
                                };
                                if (id == null) {
                                  await kendaraanCubit.create(payload, photos: formState.photos);
                                } else {
                                  await kendaraanCubit.update(id!, payload, photos: formState.photos);
                                }
                              },
                              child: const Text('Simpan'),
                            ),
                          ),
                        ]);
                      },
                    )
                  ]);
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
