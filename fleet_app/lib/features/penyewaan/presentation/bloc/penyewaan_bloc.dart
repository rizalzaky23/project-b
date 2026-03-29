import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/penyewaan_entity.dart';
import '../../domain/repositories/penyewaan_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class PenyewaanEvent extends Equatable { @override List<Object?> get props => []; }
class PenyewaanLoadRequested extends PenyewaanEvent { final int? kendaraanId; final String? search; final bool? aktif; PenyewaanLoadRequested({this.kendaraanId, this.search, this.aktif}); @override List<Object?> get props => [kendaraanId, search, aktif]; }
class PenyewaanLoadMoreRequested extends PenyewaanEvent {}
class PenyewaanCreateRequested extends PenyewaanEvent {
  final int kendaraanId; final String namaPenyewa, tanggalMulai, tanggalSelesai, penanggungJawab; final bool group; final int masaSewa; final double nilaiSewa; final String? lokasiSewa;
  final XFile? suratPerjanjian;
  PenyewaanCreateRequested({required this.kendaraanId, required this.namaPenyewa, required this.group, required this.masaSewa, required this.tanggalMulai, required this.tanggalSelesai, required this.penanggungJawab, required this.nilaiSewa, this.lokasiSewa, this.suratPerjanjian});
  @override List<Object?> get props => [kendaraanId, namaPenyewa];
}
class PenyewaanUpdateRequested extends PenyewaanEvent {
  final int id; final String? namaPenyewa, tanggalMulai, tanggalSelesai, penanggungJawab, lokasiSewa; final bool? group; final int? masaSewa; final double? nilaiSewa;
  final XFile? suratPerjanjian;
  final bool suratPerjanjianDeleted;
  PenyewaanUpdateRequested({required this.id, this.namaPenyewa, this.group, this.masaSewa, this.tanggalMulai, this.tanggalSelesai, this.penanggungJawab, this.nilaiSewa, this.lokasiSewa, this.suratPerjanjian, this.suratPerjanjianDeleted = false});
  @override List<Object?> get props => [id];
}
class PenyewaanDeleteRequested extends PenyewaanEvent { final int id; PenyewaanDeleteRequested(this.id); @override List<Object?> get props => [id]; }

abstract class PenyewaanState extends Equatable { @override List<Object?> get props => []; }
class PenyewaanInitial extends PenyewaanState {}
class PenyewaanLoading extends PenyewaanState {}
class PenyewaanLoaded extends PenyewaanState {
  final List<PenyewaanEntity> items; final PaginationMeta meta; final bool isLoadingMore;
  PenyewaanLoaded({required this.items, required this.meta, this.isLoadingMore = false});
  @override List<Object?> get props => [items, meta, isLoadingMore];
}
class PenyewaanError extends PenyewaanState { final Failure failure; PenyewaanError(this.failure); @override List<Object?> get props => [failure]; }
class PenyewaanActionSuccess extends PenyewaanState { final String message; PenyewaanActionSuccess(this.message); @override List<Object?> get props => [message]; }
class PenyewaanActionLoading extends PenyewaanState {}
class PenyewaanActionError extends PenyewaanState { final Failure failure; PenyewaanActionError(this.failure); @override List<Object?> get props => [failure]; }

class PenyewaanBloc extends Bloc<PenyewaanEvent, PenyewaanState> {
  final PenyewaanRepository _repo;
  int? _lastKendaraanId; String? _lastSearch; bool? _lastAktif;
  List<PenyewaanEntity> _items = []; PaginationMeta? _meta;

  PenyewaanBloc(this._repo) : super(PenyewaanInitial()) {
    on<PenyewaanLoadRequested>(_onLoad);
    on<PenyewaanLoadMoreRequested>(_onLoadMore);
    on<PenyewaanCreateRequested>(_onCreate);
    on<PenyewaanUpdateRequested>(_onUpdate);
    on<PenyewaanDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(PenyewaanLoadRequested e, Emitter<PenyewaanState> emit) async {
    emit(PenyewaanLoading()); _lastKendaraanId = e.kendaraanId; _lastSearch = e.search; _lastAktif = e.aktif;
    try { final r = await _repo.getAll(kendaraanId: e.kendaraanId, search: e.search, aktif: e.aktif); _items = r.items; _meta = r.meta; emit(PenyewaanLoaded(items: _items, meta: _meta!)); }
    catch (err) { emit(PenyewaanError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onLoadMore(PenyewaanLoadMoreRequested e, Emitter<PenyewaanState> emit) async {
    if (_meta == null || !_meta!.hasNextPage) return;
    emit(PenyewaanLoaded(items: _items, meta: _meta!, isLoadingMore: true));
    try { final r = await _repo.getAll(page: _meta!.currentPage + 1, kendaraanId: _lastKendaraanId, search: _lastSearch, aktif: _lastAktif); _items = [..._items, ...r.items]; _meta = r.meta; emit(PenyewaanLoaded(items: _items, meta: _meta!)); }
    catch (_) { emit(PenyewaanLoaded(items: _items, meta: _meta!)); }
  }

  Future<void> _onCreate(PenyewaanCreateRequested e, Emitter<PenyewaanState> emit) async {
    emit(PenyewaanActionLoading());
    try { await _repo.create(kendaraanId: e.kendaraanId, namaPenyewa: e.namaPenyewa, group: e.group, masaSewa: e.masaSewa, tanggalMulai: e.tanggalMulai, tanggalSelesai: e.tanggalSelesai, penanggungJawab: e.penanggungJawab, nilaiSewa: e.nilaiSewa, lokasiSewa: e.lokasiSewa, suratPerjanjian: e.suratPerjanjian); emit(PenyewaanActionSuccess('Penyewaan berhasil ditambahkan')); }
    catch (err) { emit(PenyewaanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onUpdate(PenyewaanUpdateRequested e, Emitter<PenyewaanState> emit) async {
    emit(PenyewaanActionLoading());
    try { await _repo.update(id: e.id, namaPenyewa: e.namaPenyewa, group: e.group, masaSewa: e.masaSewa, tanggalMulai: e.tanggalMulai, tanggalSelesai: e.tanggalSelesai, penanggungJawab: e.penanggungJawab, nilaiSewa: e.nilaiSewa, lokasiSewa: e.lokasiSewa, suratPerjanjian: e.suratPerjanjian, suratPerjanjianDeleted: e.suratPerjanjianDeleted); emit(PenyewaanActionSuccess('Penyewaan berhasil diperbarui')); }
    catch (err) { emit(PenyewaanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onDelete(PenyewaanDeleteRequested e, Emitter<PenyewaanState> emit) async {
    emit(PenyewaanActionLoading());
    try { await _repo.delete(e.id); emit(PenyewaanActionSuccess('Penyewaan berhasil dihapus')); }
    catch (err) { emit(PenyewaanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }
}
