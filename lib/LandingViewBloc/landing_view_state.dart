part of 'landing_view_bloc.dart';

@immutable
abstract class LandingViewState {
  final int tabIndex;

  const LandingViewState({required this.tabIndex});

}

class LandingViewInitial extends LandingViewState {
  const LandingViewInitial({required super.tabIndex});
}
