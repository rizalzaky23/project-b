import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/asuransi_entity.dart';
import '../../domain/repositories/asuransi_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class AsuransiEvent extends Equatable {
  @override List<Object?> get props => [];
}
class AsuransiLoadRequested extends AsuransiEvent {
  final int? kendaraanId; final String? search;
  AsuransiLoadRequested({this.kendaraanId, this.search});
  @override List<Object?> get props => [kendaraanId, search];
}
class AsuransiLoadMoreRequested extends AsuransiEvent {}
class AsuransiCreateRequested extends AsuransiEvent {
  final int kendaraanId; final String perusahaanAsuransi, jenisAsuransi, tanggalMulai, tanggalAkhir, noPolis; final double nilaiPremi, nilaiPertanggungan;
  final XFile? fotoDepan, fotoKiri, fotoKanan, fotoBelakang, fotoDashboard, fotoKm;
  AsuransiCreateRequested({required this.kendaraanId, required this.perusahaanAsuransi, required this.jenisAsuransi, required this.tanggalMulai, required this.tanggalAkhir, required this.noPolis, required this.nilaiPremi, required this.nilaiPertanggungan, this.fotoDepan, this.fotoKiri, this.fotoKanan, this.fotoBelakang, this.fotoDashboard, this.fotoKm});
  @override List<Object?> get props => [noPolis];
}
class AsuransiUpdateRequested extends AsuransiEvent {
  final int id; final String? perusahaanAsuransi, jenisAsuransi, tanggalMulai, tanggalAkhir, noPolis; final double? nilaiPremi, nilaiPertanggungan;
  final XFile? fotoDepan, fotoKiri, fotoKanan, fotoBelakang, fotoDashboard, fotoKm;
  AsuransiUpdateRequested({required this.id, this.perusahaanAsuransi, this.jenisAsuransi, this.tanggalMulai, this.tanggalAkhir, this.noPolis, this.nilaiPremi, this.nilaiPertanggungan, this.fotoDepan, this.fotoKiri, this.fotoKanan, this.fotoBelakang, this.fotoDashboard, this.fotoKm});
  @override List<Object?> get props => [id];
}
class AsuransiDeleteRequested extends AsuransiEvent {
  final int id; AsuransiDeleteRequested(this.id); @override List<Object?> get props => [id];
}

abstract class AsuransiState extends Equatable { @override List<Object?> get props => []; }
class AsuransiInitial extends AsuransiState {}
class AsuransiLoading extends AsuransiState {}
class AsuransiLoaded extends AsuransiState {
  final List<AsuransiEntity> items; final PaginationMeta meta; final bool isLoadingMore;
  AsuransiLoaded({required this.items, required this.meta, this.isLoadingMore = false});
  @override List<Object?> get props => [items, meta, isLoadingMore];
}
class AsuransiError extends AsuransiState {
  final Failure failure; AsuransiError(this.failure); @override List<Object?> get props => [failure];
}
class AsuransiActionSuccess extends AsuransiState {
  final String message; AsuransiActionSuccess(this.message); @override List<Object?> get props => [message];
}
class AsuransiActionLoading extends AsuransiState {}
class AsuransiActionError extends AsuransiState {
  final Failure failure; AsuransiActionError(this.failure); @override List<Object?> get props => [failure];
}

class AsuransiBloc extends Bloc<AsuransiEvent, AsuransiState> {
  final AsuransiRepository _repo;
  int? _lastKendaraanId; String? _lastSearch;
  List<AsuransiEntity> _items = []; PaginationMeta? _meta;

  AsuransiBloc(this._repo) : super(AsuransiInitial()) {
    on<AsuransiLoadRequested>(_onLoad);
    on<AsuransiLoadMoreRequested>(_onLoadMore);
    on<AsuransiCreateRequested>(_onCreate);
    on<AsuransiUpdateRequested>(_onUpdate);
    on<AsuransiDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(AsuransiLoadRequested e, Emitter<AsuransiState> emit) async {
    emit(AsuransiLoading()); _lastKendaraanId = e.kendaraanId; _lastSearch = e.search;
    try { final r = await _repo.getAll(kendaraanId: e.kendaraanId, search: e.search); _items = r.items; _meta = r.meta; emit(AsuransiLoaded(items: _items, meta: _meta!)); }
    catch (err) { emit(AsuransiError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onLoadMore(AsuransiLoadMoreRequested e, Emitter<AsuransiState> emit) async {
    if (_meta == null || !_meta!.hasNextPage) return;
    emit(AsuransiLoaded(items: _items, meta: _meta!, isLoadingMore: true));
    try { final r = await _repo.getAll(page: _meta!.currentPage + 1, kendaraanId: _lastKendaraanId, search: _lastSearch); _items = [..._items, ...r.items]; _meta = r.meta; emit(AsuransiLoaded(items: _items, meta: _meta!)); }
    catch (_) { emit(AsuransiLoaded(items: _items, meta: _meta!)); }
  }

  Future<void> _onCreate(AsuransiCreateRequested e, Emitter<AsuransiState> emit) async {
    emit(AsuransiActionLoading());
    try { await _repo.create(kendaraanId: e.kendaraanId, perusahaanAsuransi: e.perusahaanAsuransi, jenisAsuransi: e.jenisAsuransi, tanggalMulai: e.tanggalMulai, tanggalAkhir: e.tanggalAkhir, noPolis: e.noPolis, nilaiPremi: e.nilaiPremi, nilaiPertanggungan: e.nilaiPertanggungan, fotoDepan: e.fotoDepan, fotoKiri: e.fotoKiri, fotoKanan: e.fotoKanan, fotoBelakang: e.fotoBelakang, fotoDashboard: e.fotoDashboard, fotoKm: e.fotoKm); emit(AsuransiActionSuccess('Asuransi berhasil ditambahkan')); }
    catch (err) { emit(AsuransiActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onUpdate(AsuransiUpdateRequested e, Emitter<AsuransiState> emit) async {
    emit(AsuransiActionLoading());
    try { await _repo.update(id: e.id, perusahaanAsuransi: e.perusahaanAsuransi, jenisAsuransi: e.jenisAsuransi, tanggalMulai: e.tanggalMulai, tanggalAkhir: e.tanggalAkhir, noPolis: e.noPolis, nilaiPremi: e.nilaiPremi, nilaiPertanggungan: e.nilaiPertanggungan, fotoDepan: e.fotoDepan, fotoKiri: e.fotoKiri, fotoKanan: e.fotoKanan, fotoBelakang: e.fotoBelakang, fotoDashboard: e.fotoDashboard, fotoKm: e.fotoKm); emit(AsuransiActionSuccess('Asuransi berhasil diperbarui')); }
    catch (err) { emit(AsuransiActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onDelete(AsuransiDeleteRequested e, Emitter<AsuransiState> emit) async {
    emit(AsuransiActionLoading());
    try { await _repo.delete(e.id); emit(AsuransiActionSuccess('Asuransi berhasil dihapus')); }
    catch (err) { emit(AsuransiActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }
}
