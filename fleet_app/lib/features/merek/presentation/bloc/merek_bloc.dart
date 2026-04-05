import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/utils/failure.dart';
import '../../domain/entities/merek_entity.dart';
import '../../domain/repositories/merek_repository.dart';

// EVENTS
abstract class MerekEvent {}
class MerekLoadRequested extends MerekEvent {}
class MerekCreateRequested extends MerekEvent { final String nama; MerekCreateRequested(this.nama); }
class MerekUpdateRequested extends MerekEvent { final int id; final String nama; MerekUpdateRequested(this.id, this.nama); }
class MerekDeleteRequested extends MerekEvent { final int id; MerekDeleteRequested(this.id); }

// STATES
abstract class MerekState {}
class MerekInitial extends MerekState {}
class MerekLoading extends MerekState {}
class MerekLoaded extends MerekState {
  final List<MerekEntity> items;
  MerekLoaded(this.items);
}
class MerekError extends MerekState { final String message; MerekError(this.message); }
class MerekActionLoading extends MerekState {}
class MerekActionSuccess extends MerekState { final String message; MerekActionSuccess(this.message); }
class MerekActionError extends MerekState { final String message; MerekActionError(this.message); }

// BLOC
class MerekBloc extends Bloc<MerekEvent, MerekState> {
  final MerekRepository repository;

  MerekBloc(this.repository) : super(MerekInitial()) {
    on<MerekLoadRequested>(_onLoad);
    on<MerekCreateRequested>(_onCreate);
    on<MerekUpdateRequested>(_onUpdate);
    on<MerekDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(MerekLoadRequested event, Emitter<MerekState> emit) async {
    emit(MerekLoading());
    try {
      final items = await repository.getAll();
      emit(MerekLoaded(items));
    } catch (e) {
      if (e is Failure) {
        emit(MerekError(e.message));
      } else {
        emit(MerekError('Terjadi kesalahan: $e'));
      }
    }
  }

  Future<void> _onCreate(MerekCreateRequested event, Emitter<MerekState> emit) async {
    emit(MerekActionLoading());
    try {
      await repository.create(event.nama);
      emit(MerekActionSuccess('Merek berhasil ditambahkan'));
    } catch (e) {
      if (e is Failure) {
        emit(MerekActionError(e.message));
      } else {
        emit(MerekActionError('Terjadi kesalahan: $e'));
      }
    }
  }

  Future<void> _onUpdate(MerekUpdateRequested event, Emitter<MerekState> emit) async {
    emit(MerekActionLoading());
    try {
      await repository.update(event.id, event.nama);
      emit(MerekActionSuccess('Merek berhasil diperbarui'));
    } catch (e) {
      if (e is Failure) {
        emit(MerekActionError(e.message));
      } else {
        emit(MerekActionError('Terjadi kesalahan: $e'));
      }
    }
  }

  Future<void> _onDelete(MerekDeleteRequested event, Emitter<MerekState> emit) async {
    emit(MerekActionLoading());
    try {
      await repository.delete(event.id);
      emit(MerekActionSuccess('Merek berhasil dihapus'));
    } catch (e) {
      if (e is Failure) {
        emit(MerekActionError(e.message));
      } else {
        emit(MerekActionError('Terjadi kesalahan: $e'));
      }
    }
  }
}
