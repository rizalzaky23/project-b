part of 'kendaraan_cubit.dart';

abstract class KendaraanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KendaraanInitial extends KendaraanState {}
class KendaraanLoading extends KendaraanState {}
class KendaraanLoadingMore extends KendaraanState {
  final List<Kendaraan> items;
  KendaraanLoadingMore({required this.items});
  @override
  List<Object?> get props => [items];
}

class KendaraanLoaded extends KendaraanState {
  final List<Kendaraan> items;
  final bool hasMore;
  KendaraanLoaded({required this.items, required this.hasMore});
  @override
  List<Object?> get props => [items, hasMore];
}

class KendaraanSaving extends KendaraanState {}

class KendaraanError extends KendaraanState {
  final String message;
  KendaraanError(this.message);
  @override
  List<Object?> get props => [message];
}
