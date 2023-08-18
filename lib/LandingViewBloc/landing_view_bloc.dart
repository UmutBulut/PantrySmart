import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'landing_view_event.dart';
part 'landing_view_state.dart';

class LandingViewBloc extends Bloc<LandingViewEvent, LandingViewState> {
  LandingViewBloc() : super(const LandingViewInitial(tabIndex: 0)) {
    on<LandingViewEvent>((event, emit) {
      if(event is TabChange){
        emit(LandingViewInitial(tabIndex: event.tabIndex));
      }
    });
  }
}
