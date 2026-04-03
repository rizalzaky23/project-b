import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kejadian_entity.dart';
import '../../domain/repositories/kejadian_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class KejadianEvent extends Equatable { @override List<Object?> get props => []; }
class KejadianLoadRequested extends KejadianEvent { final int? kendaraanId; final String? search; KejadianLoadRequested({this.kendaraanId, this.search}); @override List<Object?> get props => [kendaraanId, search]; }
class KejadianLoadMoreRequested extends KejadianEvent {}
class KejadianCreateRequested extends KejadianEvent { final int kendaraanId; final String tanggal; final String? jenisKejadian; final String? kontakPihakKetiga; final String? lokasi; final String? deskripsi; final String? status; final XFile? fotoKm, foto1, foto2; KejadianCreateRequested({required this.kendaraanId, required this.tanggal, this.jenisKejadian, this.kontakPihakKetiga, this.lokasi, this.deskripsi, this.status, this.fotoKm, this.foto1, this.foto2}); @override List<Object?> get props => [kendaraanId, tanggal]; }

class KejadianUpdateRequested extends KejadianEvent {
  final int id;
  final String? tanggal, jenisKejadian, kontakPihakKetiga, lokasi, deskripsi, status;
  final XFile? fotoKm, foto1, foto2;
  final bool fotoKmDeleted, foto1Deleted, foto2Deleted;

  KejadianUpdateRequested({
    required this.id,
    this.tanggal,
    this.jenisKejadian,
    this.kontakPihakKetiga,
    this.lokasi,
    this.deskripsi,
    this.status,
    this.fotoKm,
    this.foto1,
    this.foto2,
    this.fotoKmDeleted = false,
    this.foto1Deleted = false,
    this.foto2Deleted = false,
  });
  @override List<Object?> get props => [id];
}

class KejadianDeleteRequested extends KejadianEvent { final int id; KejadianDeleteRequested(this.id); @override List<Object?> get props => [id]; }

abstract class KejadianState extends Equatable { @override List<Object?> get props => []; }
class KejadianInitial extends KejadianState {}
class KejadianLoading extends KejadianState {}
class KejadianLoaded extends KejadianState {
  final List<KejadianEntity> items; final PaginationMeta meta; final bool isLoadingMore;
  KejadianLoaded({required this.items, required this.meta, this.isLoadingMore = false});
  @override List<Object?> get props => [items, meta, isLoadingMore];
}
class KejadianError extends KejadianState { final Failure failure; KejadianError(this.failure); @override List<Object?> get props => [failure]; }
class KejadianActionSuccess extends KejadianState { final String message; KejadianActionSuccess(this.message); @override List<Object?> get props => [message]; }
class KejadianActionLoading extends KejadianState {}
class KejadianActionError extends KejadianState { final Failure failure; KejadianActionError(this.failure); @override List<Object?> get props => [failure]; }

class KejadianBloc extends Bloc<KejadianEvent, KejadianState> {
  final KejadianRepository _repo;
  int? _lastKendaraanId; String? _lastSearch;
  List<KejadianEntity> _items = []; PaginationMeta? _meta;

  KejadianBloc(this._repo) : super(KejadianInitial()) {
    on<KejadianLoadRequested>(_onLoad);
    on<KejadianLoadMoreRequested>(_onLoadMore);
    on<KejadianCreateRequested>(_onCreate);
    on<KejadianUpdateRequested>(_onUpdate);
    on<KejadianDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(KejadianLoadRequested e, Emitter<KejadianState> emit) async {
    emit(KejadianLoading()); _lastKendaraanId = e.kendaraanId; _lastSearch = e.search;
    try { final r = await _repo.getAll(kendaraanId: e.kendaraanId, search: e.search); _items = r.items; _meta = r.meta; emit(KejadianLoaded(items: _items, meta: _meta!)); }
    catch (err) { emit(KejadianError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onLoadMore(KejadianLoadMoreRequested e, Emitter<KejadianState> emit) async {
    if (_meta == null || !_meta!.hasNextPage) return;
    emit(KejadianLoaded(items: _items, meta: _meta!, isLoadingMore: true));
    try { final r = await _repo.getAll(page: _meta!.currentPage + 1, kendaraanId: _lastKendaraanId, search: _lastSearch); _items = [..._items, ...r.items]; _meta = r.meta; emit(KejadianLoaded(items: _items, meta: _meta!)); }
    catch (_) { emit(KejadianLoaded(items: _items, meta: _meta!)); }
  }

  Future<void> _onCreate(KejadianCreateRequested e, Emitter<KejadianState> emit) async {
    emit(KejadianActionLoading());
    try { await _repo.create(kendaraanId: e.kendaraanId, tanggal: e.tanggal, jenisKejadian: e.jenisKejadian, kontakPihakKetiga: e.kontakPihakKetiga, lokasi: e.lokasi, deskripsi: e.deskripsi, status: e.status, fotoKm: e.fotoKm, foto1: e.foto1, foto2: e.foto2); emit(KejadianActionSuccess('Kejadian berhasil ditambahkan')); }
    catch (err) { emit(KejadianActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onUpdate(KejadianUpdateRequested e, Emitter<KejadianState> emit) async {
    emit(KejadianActionLoading());
    try {
      await _repo.update(
        id: e.id,
        tanggal: e.tanggal,
        jenisKejadian: e.jenisKejadian,
        kontakPihakKetiga: e.kontakPihakKetiga,
        lokasi: e.lokasi,
        deskripsi: e.deskripsi,
        status: e.status,
        fotoKm: e.fotoKm,
        foto1: e.foto1,
        foto2: e.foto2,
        fotoKmDeleted: e.fotoKmDeleted,
        foto1Deleted: e.foto1Deleted,
        foto2Deleted: e.foto2Deleted,
      );
      emit(KejadianActionSuccess('Kejadian berhasil diperbarui'));
    }
    catch (err) { emit(KejadianActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onDelete(KejadianDeleteRequested e, Emitter<KejadianState> emit) async {
    emit(KejadianActionLoading());
    try { await _repo.delete(e.id); emit(KejadianActionSuccess('Kejadian berhasil dihapus')); }
    catch (err) { emit(KejadianActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }
}
