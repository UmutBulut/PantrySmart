import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantrysmart/LandingViewBloc/landing_view_bloc.dart';
import 'package:pantrysmart/Presentation/Screens/landingView.dart';

class RouteGenerator{
  final LandingViewBloc landingViewBloc = LandingViewBloc();
  Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;
    switch(settings.name){
      case '/':
        return MaterialPageRoute(
            builder: (_) => BlocProvider<LandingViewBloc>.value(
              value: landingViewBloc,
              child: const LandingView(),
            )
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}