import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/kendaraan_model.dart';
import '../data/kendaraan_repository.dart';

part 'kendaraan_state.dart';

class KendaraanCubit extends Cubit<KendaraanState> {
  final KendaraanRepository _repo;
  int _page = 1;
  bool _hasMore = true;

  KendaraanCubit(this._repo) : super(KendaraanInitial());

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('Exception: ')) {
        return msg.replaceFirst('Exception: ', '');
      }
      return msg;
    }
    return 'Gagal memuat data';
  }

  Future<void> loadInitial() async {
    emit(KendaraanLoading());
    try {
      _page = 1;
      final items = await _repo.fetchPage(_page);
      _hasMore = items.length >= 15;
      emit(KendaraanLoaded(items: items, hasMore: _hasMore));
    } catch (e) {
      emit(KendaraanError(_extractErrorMessage(e)));
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is KendaraanLoadingMore) return;
    final current = state;
    if (current is KendaraanLoaded) {
      emit(KendaraanLoadingMore(items: current.items));
      try {
        _page++;
        final items = await _repo.fetchPage(_page);
        _hasMore = items.length >= 15;
        emit(KendaraanLoaded(items: [...current.items, ...items], hasMore: _hasMore));
      } catch (e) {
        emit(KendaraanError(_extractErrorMessage(e)));
      }
    }
  }

  Future<void> refresh() async => loadInitial();

  Future<void> create(Map<String, dynamic> payload, {List<File>? photos}) async {
    emit(KendaraanSaving());
    try {
      await _repo.create(payload, photos: photos);
      await loadInitial();
    } catch (e) {
      emit(KendaraanError(_extractErrorMessage(e)));
    }
  }

  Future<void> update(int id, Map<String, dynamic> payload, {List<File>? photos}) async {
    emit(KendaraanSaving());
    try {
      await _repo.update(id, payload, photos: photos);
      await loadInitial();
    } catch (e) {
      emit(KendaraanError(_extractErrorMessage(e)));
    }
  }

  Future<void> delete(int id) async {
    emit(KendaraanLoading());
    try {
      await _repo.delete(id);
      await loadInitial();
    } catch (e) {
      emit(KendaraanError(_extractErrorMessage(e)));
    }
  }
}
