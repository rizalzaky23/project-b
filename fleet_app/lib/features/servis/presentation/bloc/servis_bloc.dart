import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/servis_entity.dart';
import '../../domain/repositories/servis_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

// ─── Events ────────────────────────────────────────────────────────────────
abstract class ServisEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServisLoadRequested extends ServisEvent {
  final int? kendaraanId;
  final String? search;
  ServisLoadRequested({this.kendaraanId, this.search});
  @override
  List<Object?> get props => [kendaraanId, search];
}

class ServisLoadMoreRequested extends ServisEvent {}

class ServisCreateRequested extends ServisEvent {
  final int kendaraanId;
  final String tanggalServis;
  final int kilometer;
  final XFile? fotoKm;
  final XFile? fotoInvoice;

  ServisCreateRequested({
    required this.kendaraanId,
    required this.tanggalServis,
    required this.kilometer,
    this.fotoKm,
    this.fotoInvoice,
  });
  @override
  List<Object?> get props => [kendaraanId, tanggalServis];
}

class ServisUpdateRequested extends ServisEvent {
  final int id;
  final String? tanggalServis;
  final int? kilometer;
  final XFile? fotoKm;
  final bool fotoKmDeleted;
  final XFile? fotoInvoice;
  final bool fotoInvoiceDeleted;

  ServisUpdateRequested({
    required this.id,
    this.tanggalServis,
    this.kilometer,
    this.fotoKm,
    this.fotoKmDeleted = false,
    this.fotoInvoice,
    this.fotoInvoiceDeleted = false,
  });
  @override
  List<Object?> get props => [id];
}

class ServisDeleteRequested extends ServisEvent {
  final int id;
  ServisDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── States ────────────────────────────────────────────────────────────────
abstract class ServisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServisInitial extends ServisState {}

class ServisLoading extends ServisState {}

class ServisLoaded extends ServisState {
  final List<ServisEntity> items;
  final PaginationMeta meta;
  final bool isLoadingMore;
  ServisLoaded({required this.items, required this.meta, this.isLoadingMore = false});
  @override
  List<Object?> get props => [items, meta, isLoadingMore];
}

class ServisError extends ServisState {
  final Failure failure;
  ServisError(this.failure);
  @override
  List<Object?> get props => [failure];
}

class ServisActionSuccess extends ServisState {
  final String message;
  ServisActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ServisActionLoading extends ServisState {}

class ServisActionError extends ServisState {
  final Failure failure;
  ServisActionError(this.failure);
  @override
  List<Object?> get props => [failure];
}

// ─── Bloc ──────────────────────────────────────────────────────────────────
class ServisBloc extends Bloc<ServisEvent, ServisState> {
  final ServisRepository _repo;
  int? _lastKendaraanId;
  String? _lastSearch;
  List<ServisEntity> _items = [];
  PaginationMeta? _meta;

  ServisBloc(this._repo) : super(ServisInitial()) {
    on<ServisLoadRequested>(_onLoad);
    on<ServisLoadMoreRequested>(_onLoadMore);
    on<ServisCreateRequested>(_onCreate);
    on<ServisUpdateRequested>(_onUpdate);
    on<ServisDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(ServisLoadRequested e, Emitter<ServisState> emit) async {
    emit(ServisLoading());
    _lastKendaraanId = e.kendaraanId;
    _lastSearch = e.search;
    try {
      final r = await _repo.getAll(kendaraanId: e.kendaraanId, search: e.search);
      _items = r.items;
      _meta = r.meta;
      emit(ServisLoaded(items: _items, meta: _meta!));
    } catch (err) {
      emit(ServisError(err is Failure ? err : ServerFailure(err.toString())));
    }
  }

  Future<void> _onLoadMore(ServisLoadMoreRequested e, Emitter<ServisState> emit) async {
    if (_meta == null || !_meta!.hasNextPage) return;
    emit(ServisLoaded(items: _items, meta: _meta!, isLoadingMore: true));
    try {
      final r = await _repo.getAll(
          page: _meta!.currentPage + 1,
          kendaraanId: _lastKendaraanId,
          search: _lastSearch);
      _items = [..._items, ...r.items];
      _meta = r.meta;
      emit(ServisLoaded(items: _items, meta: _meta!));
    } catch (_) {
      emit(ServisLoaded(items: _items, meta: _meta!));
    }
  }

  Future<void> _onCreate(ServisCreateRequested e, Emitter<ServisState> emit) async {
    emit(ServisActionLoading());
    try {
      await _repo.create(
        kendaraanId: e.kendaraanId,
        tanggalServis: e.tanggalServis,
        kilometer: e.kilometer,
        fotoKm: e.fotoKm,
        fotoInvoice: e.fotoInvoice,
      );
      emit(ServisActionSuccess('Servis record berhasil ditambahkan'));
    } catch (err) {
      emit(ServisActionError(err is Failure ? err : ServerFailure(err.toString())));
    }
  }

  Future<void> _onUpdate(ServisUpdateRequested e, Emitter<ServisState> emit) async {
    emit(ServisActionLoading());
    try {
      await _repo.update(
        id: e.id,
        tanggalServis: e.tanggalServis,
        kilometer: e.kilometer,
        fotoKm: e.fotoKm,
        fotoKmDeleted: e.fotoKmDeleted,
        fotoInvoice: e.fotoInvoice,
        fotoInvoiceDeleted: e.fotoInvoiceDeleted,
      );
      emit(ServisActionSuccess('Servis record berhasil diperbarui'));
    } catch (err) {
      emit(ServisActionError(err is Failure ? err : ServerFailure(err.toString())));
    }
  }

  Future<void> _onDelete(ServisDeleteRequested e, Emitter<ServisState> emit) async {
    emit(ServisActionLoading());
    try {
      await _repo.delete(e.id);
      emit(ServisActionSuccess('Servis record berhasil dihapus'));
    } catch (err) {
      emit(ServisActionError(err is Failure ? err : ServerFailure(err.toString())));
    }
  }
}
