import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';
import '../../domain/repositories/detail_kendaraan_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class DetailKendaraanEvent extends Equatable {
  @override List<Object?> get props => [];
}
class DetailKendaraanLoadRequested extends DetailKendaraanEvent {
  final int? kendaraanId; final String? search;
  DetailKendaraanLoadRequested({this.kendaraanId, this.search});
  @override List<Object?> get props => [kendaraanId, search];
}
class DetailKendaraanLoadMoreRequested extends DetailKendaraanEvent {}
class DetailKendaraanCreateRequested extends DetailKendaraanEvent {
  final int kendaraanId; final String noPolisi, namaPemilik; final String? berlakuMulai;
  final XFile? fotoStnk, fotoBpkb, fotoNomor, fotoKm;
  DetailKendaraanCreateRequested({required this.kendaraanId, required this.noPolisi, required this.namaPemilik, this.berlakuMulai, this.fotoStnk, this.fotoBpkb, this.fotoNomor, this.fotoKm});
  @override List<Object?> get props => [kendaraanId, noPolisi];
}
class DetailKendaraanUpdateRequested extends DetailKendaraanEvent {
  final int id; final String? noPolisi, namaPemilik, berlakuMulai;
  final XFile? fotoStnk, fotoBpkb, fotoNomor, fotoKm;
  DetailKendaraanUpdateRequested({required this.id, this.noPolisi, this.namaPemilik, this.berlakuMulai, this.fotoStnk, this.fotoBpkb, this.fotoNomor, this.fotoKm});
  @override List<Object?> get props => [id];
}
class DetailKendaraanDeleteRequested extends DetailKendaraanEvent {
  final int id;
  DetailKendaraanDeleteRequested(this.id);
  @override List<Object?> get props => [id];
}

abstract class DetailKendaraanState extends Equatable {
  @override List<Object?> get props => [];
}
class DetailKendaraanInitial extends DetailKendaraanState {}
class DetailKendaraanLoading extends DetailKendaraanState {}
class DetailKendaraanLoaded extends DetailKendaraanState {
  final List<DetailKendaraanEntity> items; final PaginationMeta meta; final bool isLoadingMore;
  DetailKendaraanLoaded({required this.items, required this.meta, this.isLoadingMore = false});
  DetailKendaraanLoaded copyWith({List<DetailKendaraanEntity>? items, PaginationMeta? meta, bool? isLoadingMore}) =>
      DetailKendaraanLoaded(items: items ?? this.items, meta: meta ?? this.meta, isLoadingMore: isLoadingMore ?? this.isLoadingMore);
  @override List<Object?> get props => [items, meta, isLoadingMore];
}
class DetailKendaraanError extends DetailKendaraanState {
  final Failure failure;
  DetailKendaraanError(this.failure);
  @override List<Object?> get props => [failure];
}
class DetailKendaraanActionSuccess extends DetailKendaraanState {
  final String message;
  DetailKendaraanActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class DetailKendaraanActionLoading extends DetailKendaraanState {}
class DetailKendaraanActionError extends DetailKendaraanState {
  final Failure failure;
  DetailKendaraanActionError(this.failure);
  @override List<Object?> get props => [failure];
}

class DetailKendaraanBloc extends Bloc<DetailKendaraanEvent, DetailKendaraanState> {
  final DetailKendaraanRepository _repo;
  int? _lastKendaraanId; String? _lastSearch;
  List<DetailKendaraanEntity> _items = []; PaginationMeta? _meta;

  DetailKendaraanBloc(this._repo) : super(DetailKendaraanInitial()) {
    on<DetailKendaraanLoadRequested>(_onLoad);
    on<DetailKendaraanLoadMoreRequested>(_onLoadMore);
    on<DetailKendaraanCreateRequested>(_onCreate);
    on<DetailKendaraanUpdateRequested>(_onUpdate);
    on<DetailKendaraanDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(DetailKendaraanLoadRequested e, Emitter<DetailKendaraanState> emit) async {
    emit(DetailKendaraanLoading());
    _lastKendaraanId = e.kendaraanId; _lastSearch = e.search;
    try {
      final r = await _repo.getAll(kendaraanId: e.kendaraanId, search: e.search);
      _items = r.items; _meta = r.meta;
      emit(DetailKendaraanLoaded(items: _items, meta: _meta!));
    } catch (err) {
      emit(DetailKendaraanError(err is Failure ? err : ServerFailure(err.toString())));
    }
  }

  Future<void> _onLoadMore(DetailKendaraanLoadMoreRequested e, Emitter<DetailKendaraanState> emit) async {
    if (_meta == null || !_meta!.hasNextPage) return;
    emit(DetailKendaraanLoaded(items: _items, meta: _meta!, isLoadingMore: true));
    try {
      final r = await _repo.getAll(page: _meta!.currentPage + 1, kendaraanId: _lastKendaraanId, search: _lastSearch);
      _items = [..._items, ...r.items]; _meta = r.meta;
      emit(DetailKendaraanLoaded(items: _items, meta: _meta!));
    } catch (_) { emit(DetailKendaraanLoaded(items: _items, meta: _meta!)); }
  }

  Future<void> _onCreate(DetailKendaraanCreateRequested e, Emitter<DetailKendaraanState> emit) async {
    emit(DetailKendaraanActionLoading());
    try {
      await _repo.create(kendaraanId: e.kendaraanId, noPolisi: e.noPolisi, namaPemilik: e.namaPemilik, berlakuMulai: e.berlakuMulai, fotoStnk: e.fotoStnk, fotoBpkb: e.fotoBpkb, fotoNomor: e.fotoNomor, fotoKm: e.fotoKm);
      emit(DetailKendaraanActionSuccess('Detail kendaraan berhasil ditambahkan'));
    } catch (err) { emit(DetailKendaraanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onUpdate(DetailKendaraanUpdateRequested e, Emitter<DetailKendaraanState> emit) async {
    emit(DetailKendaraanActionLoading());
    try {
      await _repo.update(id: e.id, noPolisi: e.noPolisi, namaPemilik: e.namaPemilik, berlakuMulai: e.berlakuMulai, fotoStnk: e.fotoStnk, fotoBpkb: e.fotoBpkb, fotoNomor: e.fotoNomor, fotoKm: e.fotoKm);
      emit(DetailKendaraanActionSuccess('Detail kendaraan berhasil diperbarui'));
    } catch (err) { emit(DetailKendaraanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }

  Future<void> _onDelete(DetailKendaraanDeleteRequested e, Emitter<DetailKendaraanState> emit) async {
    emit(DetailKendaraanActionLoading());
    try {
      await _repo.delete(e.id);
      emit(DetailKendaraanActionSuccess('Detail kendaraan berhasil dihapus'));
    } catch (err) { emit(DetailKendaraanActionError(err is Failure ? err : ServerFailure(err.toString()))); }
  }
}
