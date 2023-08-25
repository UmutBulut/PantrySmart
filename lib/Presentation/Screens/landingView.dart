import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantrysmart/LandingViewBloc/landing_view_bloc.dart';
import 'package:pantrysmart/Presentation/Screens/listaView.dart';
import 'package:pantrysmart/Presentation/Screens/storicoView.dart';

class LandingView extends StatelessWidget{
  LandingView({super.key});
  final List<BottomNavigationBarItem> bottomNavItems = const [
    BottomNavigationBarItem(
      label: 'Home',
      icon: Icon(Icons.home),
    ),
    BottomNavigationBarItem(
      label: 'Lista',
      icon: Icon(Icons.list),
    ),
    BottomNavigationBarItem(
      label: 'Storico',
      icon: Icon(Icons.history),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomNavScreens = [
      Text('Uno'),
      ListaView(),
      StoricoView(),
    ];

    return BlocConsumer<LandingViewBloc, LandingViewState>(
        builder: (context, state){
          return Scaffold(
              appBar: AppBar(
                title: Text('Pantry Smart'),
                leading: Padding(
                    padding: EdgeInsets.fromLTRB(10,0,0,0),
                    child: Image.asset('assets/pantrylogo.png')),
              ),
            body: Center(
            child: bottomNavScreens.elementAt(state.tabIndex)
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: bottomNavItems,
              type: BottomNavigationBarType.fixed,
              currentIndex: state.tabIndex,
              backgroundColor: Theme.of(context).colorScheme.primary,
              selectedItemColor: Theme.of(context).colorScheme.background,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(.60),
              selectedLabelStyle: Theme.of(context).textTheme.caption,
              unselectedLabelStyle: Theme.of(context).textTheme.caption,
              onTap: (value) {
                BlocProvider.of<LandingViewBloc>(context).add(TabChange(tabIndex: value));
              },
            ),
          );
        },
        listener: (context, state){});
  }
}