import 'package:attendance/repo/leave.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// EVENTS
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

class LeaveDateChanged extends LeaveEvent {
  final DateTime date;
  const LeaveDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class SubmitLeave extends LeaveEvent {
  final String userId;
  const SubmitLeave(this.userId);

  @override
  List<Object?> get props => [userId];
}

// STATES
class LeaveState extends Equatable {
  final String title;
  final String description;
  final DateTime? date;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool isFailure;

  const LeaveState({
    this.title = '',
    this.description = '',
    this.date,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isFailure = false,
  });

  LeaveState copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? isFailure,
  }) {
    return LeaveState(
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,

      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    date,
    isSubmitting,
    isSuccess,
    isFailure,

    errorMessage,
  ];
}

// BLOC

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository leaveRepository;

  LeaveBloc(this.leaveRepository) : super(const LeaveState()) {
    on<LeaveTitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title, isSuccess: false));
    });

    on<LeaveDescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description, isSuccess: false));
    });

    on<LeaveDateChanged>((event, emit) {
      emit(state.copyWith(date: event.date, isSuccess: false));
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
        date: state.date,
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
