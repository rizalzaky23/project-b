import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../../domain/repositories/kendaraan_repository.dart';
import '../../../../shared/utils/failure.dart';
import '../../../../shared/utils/pagination_meta.dart';

// Events
abstract class KendaraanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class KendaraanLoadRequested extends KendaraanEvent {
  final String? search;
  final String? merk;
  final String? kepemilikan;
  final String? status;
  KendaraanLoadRequested(
      {this.search, this.merk, this.kepemilikan, this.status});
  @override
  List<Object?> get props => [search, merk, kepemilikan, status];
}

class KendaraanLoadMoreRequested extends KendaraanEvent {}

class KendaraanCreateRequested extends KendaraanEvent {
  final String kodeKendaraan, merk, tipe, warna, noChasis, noMesin;
  final int tahunPerolehan, tahunPembuatan;
  final double hargaPerolehan;
  final String? kepemilikan;
  final String? jenisPembayaran;
  final String? jenisKredit;
  final int? tenor;
  final XFile? fileKontrak;
  final bool fileKontrakDeleted;
  final XFile? fotoDepan, fotoKiri, fotoKanan, fotoBelakang;

  KendaraanCreateRequested({
    required this.kodeKendaraan,
    required this.merk,
    required this.tipe,
    required this.warna,
    required this.noChasis,
    required this.noMesin,
    required this.tahunPerolehan,
    required this.tahunPembuatan,
    required this.hargaPerolehan,
    this.kepemilikan,
    this.jenisPembayaran,
    this.jenisKredit,
    this.tenor,
    this.fileKontrak,
    this.fileKontrakDeleted = false,
    this.fotoDepan,
    this.fotoKiri,
    this.fotoKanan,
    this.fotoBelakang,
  });

  @override
  List<Object?> get props => [kodeKendaraan, merk];
}

class KendaraanUpdateRequested extends KendaraanEvent {
  final int id;
  final String? kodeKendaraan,
      merk,
      tipe,
      warna,
      noChasis,
      noMesin,
      kepemilikan;
  final String? jenisPembayaran;
  final String? jenisKredit;
  final int? tenor;
  final XFile? fileKontrak;
  final bool fileKontrakDeleted;
  final int? tahunPerolehan, tahunPembuatan;
  final double? hargaPerolehan;
  final XFile? fotoDepan, fotoKiri, fotoKanan, fotoBelakang;
  final bool fotoDepanDeleted,
      fotoKiriDeleted,
      fotoKananDeleted,
      fotoBelakangDeleted;
  final String? status;
  final String? tanggalJual;
  final double? hargaJual;

  KendaraanUpdateRequested({
    required this.id,
    this.kodeKendaraan,
    this.merk,
    this.tipe,
    this.warna,
    this.noChasis,
    this.noMesin,
    this.tahunPerolehan,
    this.tahunPembuatan,
    this.hargaPerolehan,
    this.kepemilikan,
    this.jenisPembayaran,
    this.jenisKredit,
    this.tenor,
    this.fileKontrak,
    this.fileKontrakDeleted = false,
    this.fotoDepan,
    this.fotoKiri,
    this.fotoKanan,
    this.fotoBelakang,
    this.fotoDepanDeleted = false,
    this.fotoKiriDeleted = false,
    this.fotoKananDeleted = false,
    this.fotoBelakangDeleted = false,
    this.status,
    this.tanggalJual,
    this.hargaJual,
  });

  @override
  List<Object?> get props => [id];
}

class KendaraanDeleteRequested extends KendaraanEvent {
  final int id;
  KendaraanDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class KendaraanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KendaraanInitial extends KendaraanState {}

class KendaraanLoading extends KendaraanState {}

class KendaraanLoaded extends KendaraanState {
  final List<KendaraanEntity> items;
  final PaginationMeta meta;
  final bool isLoadingMore;

  KendaraanLoaded(
      {required this.items, required this.meta, this.isLoadingMore = false});

  KendaraanLoaded copyWith({
    List<KendaraanEntity>? items,
    PaginationMeta? meta,
    bool? isLoadingMore,
  }) {
    return KendaraanLoaded(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, meta, isLoadingMore];
}

class KendaraanError extends KendaraanState {
  final Failure failure;
  KendaraanError(this.failure);
  @override
  List<Object?> get props => [failure];
}

class KendaraanActionSuccess extends KendaraanState {
  final String message;
  KendaraanActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class KendaraanActionLoading extends KendaraanState {}

class KendaraanActionError extends KendaraanState {
  final Failure failure;
  KendaraanActionError(this.failure);
  @override
  List<Object?> get props => [failure];
}

// Bloc
class KendaraanBloc extends Bloc<KendaraanEvent, KendaraanState> {
  final KendaraanRepository _repository;
  String? _lastSearch;
  String? _lastMerk;
  String? _lastKepemilikan;
  String? _lastStatus;
  List<KendaraanEntity> _currentItems = [];
  PaginationMeta? _currentMeta;

  KendaraanBloc(this._repository) : super(KendaraanInitial()) {
    on<KendaraanLoadRequested>(_onLoad);
    on<KendaraanLoadMoreRequested>(_onLoadMore);
    on<KendaraanCreateRequested>(_onCreate);
    on<KendaraanUpdateRequested>(_onUpdate);
    on<KendaraanDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
      KendaraanLoadRequested event, Emitter<KendaraanState> emit) async {
    emit(KendaraanLoading());
    _lastSearch = event.search;
    _lastMerk = event.merk;
    _lastKepemilikan = event.kepemilikan;
    _lastStatus = event.status;
    try {
      final result = await _repository.getAll(
        page: 1,
        search: event.search,
        merk: event.merk,
        kepemilikan: event.kepemilikan,
        status: event.status,
      );
      _currentItems = result.items;
      _currentMeta = result.meta;
      emit(KendaraanLoaded(items: _currentItems, meta: _currentMeta!));
    } catch (e) {
      if (e is Failure) {
        emit(KendaraanError(e));
      } else {
        emit(KendaraanError(ServerFailure(e.toString())));
      }
    }
  }

  Future<void> _onLoadMore(
      KendaraanLoadMoreRequested event, Emitter<KendaraanState> emit) async {
    if (_currentMeta == null || !_currentMeta!.hasNextPage) return;
    emit(KendaraanLoaded(
        items: _currentItems, meta: _currentMeta!, isLoadingMore: true));
    try {
      final result = await _repository.getAll(
        page: _currentMeta!.currentPage + 1,
        search: _lastSearch,
        merk: _lastMerk,
        kepemilikan: _lastKepemilikan,
        status: _lastStatus,
      );
      _currentItems = [..._currentItems, ...result.items];
      _currentMeta = result.meta;
      emit(KendaraanLoaded(items: _currentItems, meta: _currentMeta!));
    } catch (e) {
      emit(KendaraanLoaded(items: _currentItems, meta: _currentMeta!));
    }
  }

  Future<void> _onCreate(
      KendaraanCreateRequested event, Emitter<KendaraanState> emit) async {
    emit(KendaraanActionLoading());
    try {
      await _repository.create(
        kodeKendaraan: event.kodeKendaraan,
        merk: event.merk,
        tipe: event.tipe,
        warna: event.warna,
        noChasis: event.noChasis,
        noMesin: event.noMesin,
        tahunPerolehan: event.tahunPerolehan,
        tahunPembuatan: event.tahunPembuatan,
        hargaPerolehan: event.hargaPerolehan,
        kepemilikan: event.kepemilikan,
        jenisPembayaran: event.jenisPembayaran,
        jenisKredit: event.jenisKredit,
        tenor: event.tenor,
        fileKontrak: event.fileKontrak,
        fileKontrakDeleted: event.fileKontrakDeleted,
        fotoDepan: event.fotoDepan,
        fotoKiri: event.fotoKiri,
        fotoKanan: event.fotoKanan,
        fotoBelakang: event.fotoBelakang,
      );
      emit(KendaraanActionSuccess('Kendaraan berhasil ditambahkan'));
    } catch (e) {
      if (e is Failure) {
        emit(KendaraanActionError(e));
      } else {
        emit(KendaraanActionError(ServerFailure(e.toString())));
      }
    }
  }

  Future<void> _onUpdate(
      KendaraanUpdateRequested event, Emitter<KendaraanState> emit) async {
    emit(KendaraanActionLoading());
    try {
      await _repository.update(
        id: event.id,
        kodeKendaraan: event.kodeKendaraan,
        merk: event.merk,
        tipe: event.tipe,
        warna: event.warna,
        noChasis: event.noChasis,
        noMesin: event.noMesin,
        tahunPerolehan: event.tahunPerolehan,
        tahunPembuatan: event.tahunPembuatan,
        hargaPerolehan: event.hargaPerolehan,
        kepemilikan: event.kepemilikan,
        jenisPembayaran: event.jenisPembayaran,
        jenisKredit: event.jenisKredit,
        tenor: event.tenor,
        fileKontrak: event.fileKontrak,
        fileKontrakDeleted: event.fileKontrakDeleted,
        fotoDepan: event.fotoDepan,
        fotoKiri: event.fotoKiri,
        fotoKanan: event.fotoKanan,
        fotoBelakang: event.fotoBelakang,
        fotoDepanDeleted: event.fotoDepanDeleted,
        fotoKiriDeleted: event.fotoKiriDeleted,
        fotoKananDeleted: event.fotoKananDeleted,
        fotoBelakangDeleted: event.fotoBelakangDeleted,
        status: event.status,
        tanggalJual: event.tanggalJual,
        hargaJual: event.hargaJual,
      );
      emit(KendaraanActionSuccess('Kendaraan berhasil diperbarui'));
    } catch (e) {
      if (e is Failure) {
        emit(KendaraanActionError(e));
      } else {
        emit(KendaraanActionError(ServerFailure(e.toString())));
      }
    }
  }

  Future<void> _onDelete(
      KendaraanDeleteRequested event, Emitter<KendaraanState> emit) async {
    emit(KendaraanActionLoading());
    try {
      await _repository.delete(event.id);
      emit(KendaraanActionSuccess('Kendaraan berhasil dihapus'));
    } catch (e) {
      if (e is Failure) {
        emit(KendaraanActionError(e));
      } else {
        emit(KendaraanActionError(ServerFailure(e.toString())));
      }
    }
  }
}
