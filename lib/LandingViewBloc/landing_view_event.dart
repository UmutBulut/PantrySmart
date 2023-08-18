part of 'landing_view_bloc.dart';

@immutable
abstract class LandingViewEvent {

}

class TabChange extends LandingViewEvent{
  final int tabIndex;

  TabChange({required this.tabIndex});
}
