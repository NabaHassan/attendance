import 'package:attendance/repo/leave_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// EVENTS
abstract class LeaveEvent extends Equatable {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}

class LeaveTitleChanged extends LeaveEvent {
  final String title;
  const LeaveTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class LeaveDescriptionChanged extends LeaveEvent {
  final String description;
  const LeaveDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class LeaveToDateChanged extends LeaveEvent {
  final DateTime date;
  const LeaveToDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class LeaveFromDateChanged extends LeaveEvent {
  final DateTime date;
  const LeaveFromDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class SubmitLeave extends LeaveEvent {
  final String userId;
  const SubmitLeave(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// STATES
class LeaveState extends Equatable {
  final String title;
  final String description;
  final DateTime? toDate;
  final DateTime? fromDate;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool isFailure;

  const LeaveState({
    this.title = '',
    this.description = '',
    this.toDate,
    this.fromDate,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isFailure = false,
  });

  LeaveState copyWith({
    String? title,
    String? description,
    DateTime? toDate,
    DateTime? fromDate,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? isFailure,
  }) {
    return LeaveState(
      title: title ?? this.title,
      description: description ?? this.description,
      toDate: toDate ?? this.toDate,
      fromDate: fromDate ?? this.fromDate,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    toDate,
    fromDate,
    isSubmitting,
    isSuccess,
    isFailure,
    errorMessage,
  ];
}

/// BLOC
class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository leaveRepository;

  LeaveBloc(this.leaveRepository) : super(const LeaveState()) {
    on<LeaveTitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title, isSuccess: false));
    });

    on<LeaveDescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description, isSuccess: false));
    });

    on<LeaveFromDateChanged>((event, emit) {
      emit(state.copyWith(fromDate: event.date, isSuccess: false));
    });

    on<LeaveToDateChanged>((event, emit) {
      emit(state.copyWith(toDate: event.date, isSuccess: false));
    });

    on<SubmitLeave>(_onSubmitLeave);
  }

  Future<void> _onSubmitLeave(
    SubmitLeave event,
    Emitter<LeaveState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        isSuccess: false,
        isFailure: false,
        errorMessage: null,
      ),
    );

    try {
      await leaveRepository.submitLeave(
        userId: event.userId,
        title: state.title,
        description: state.description,
        fromDate: state.fromDate,
        toDate: state.toDate,
      );

      emit(
        state.copyWith(isSubmitting: false, isSuccess: true, isFailure: false),
      );

      // reset success after delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(isSuccess: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          isFailure: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
