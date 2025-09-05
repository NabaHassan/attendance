import 'dart:async';

import 'package:attendance/repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// EVENTS
abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoreAttendance extends AttendanceEvent {
  final String userId;
  final String type; // "checkIn" or "checkOut"
  final DateTime time;

  StoreAttendance(this.userId, this.type, this.time);

  @override
  List<Object?> get props => [userId];
}
class GetUserAttendance extends AttendanceEvent {
  final String userId;
  

  GetUserAttendance(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserAttendanceLoaded extends AttendanceState {
  final Map<String, dynamic> attendance; 

  UserAttendanceLoaded(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

// STATES
abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final String type; // "checkIn" or "checkOut"
  final DateTime time;

  AttendanceSuccess(this.type, this.time);
}
class StoreAttendanceSuccess extends AttendanceState {

  StoreAttendanceSuccess();
}

class AttendanceFailure extends AttendanceState {
  final String message;
  AttendanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AuthRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<StoreAttendance>(_onStoreAttendance);
    on<GetUserAttendance>(_onGetUserAttendance);
  }

  Future<void> _onStoreAttendance(
    StoreAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    try {
      await repository.storeAttendanceTime(
        event.userId,
        event.type,
        event.time,
      );
      emit(AttendanceSuccess(event.type, event.time));
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }

  
  StreamSubscription? _attendanceSubscription;

  Future<void> _onGetUserAttendance(
    GetUserAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());

    await _attendanceSubscription?.cancel(); 

    _attendanceSubscription = repository
        .getUserAttendance(
          event.userId,
        ) 
        .listen(
          (attendanceData) {
            if (attendanceData != null) {
              emit(UserAttendanceLoaded(attendanceData));
            }
          },
          onError: (e) {
            emit(AttendanceFailure(e.toString()));
          },
        );
  }
   @override
  Future<void> close() {
    _attendanceSubscription?.cancel(); // cancel when bloc is disposed
    return super.close();
  }

}
