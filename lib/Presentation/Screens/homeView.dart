import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Promemoria.dart';
import 'package:pantrysmart/Classes/Scadenza.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

List<Scadenza> scadenze = [];
List<Promemoria> listPromemoria = [];
DateTime oggi = DateTime.now();

class HomeView extends StatefulWidget {
  HomeView({super.key});
  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    _loadprefs();
  }

  Future<void> _loadprefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? prodottiString = await prefs.getString('prodotti_key');
    final String? promemoriaString = await prefs.getString('promemoria_key');
    scadenze.clear();

    var prodotti = Prodotto.decode(prodottiString!);
    for(var prodotto in prodotti){
      var dataScadenza = DateTime.tryParse(prodotto.scadenza!);
      var giornoScadenza = dataScadenza!
          .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
      var giornoOggi = oggi
          .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
      if(giornoOggi.isAfter(giornoScadenza)){
        Scadenza nuovaScadenza = Scadenza(
            idProdotto: prodotto.id,
            denominazioneProdotto: prodotto.denominazione,
            data: prodotto.scadenza,
            inRimozione: false
        );
        scadenze.add(nuovaScadenza);
      }
    }
    listPromemoria.add(Promemoria(
        id: 74,
        testo: "Test",
        data: DateTime.now().add(Duration(days: 5)).toString(),
        inRimozione: false
    ));

    setState(() {
      if(promemoriaString != null)
        listPromemoria = Promemoria.decode(promemoriaString!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Oggi è il: ' + oggi.toString().substring(0,10)),
          Row(
            children: [
              Text('Scadenze'),
              ElevatedButton.icon(
                onPressed: () {
                },
                icon: Icon( // <-- Icon
                  Icons.delete,
                  size: 24.0,
                ),
                label: Text('Pulisci'), // <-- Text
              )
            ],
          ),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: scadenze.map<Widget>(
                      (scad) => Container(
                    width: 250,
                    child: Card(child:
                    ListTile(
                      title: Column(
                        children: [
                          Text(
                            scad.denominazioneProdotto!,
                            style:TextStyle(fontSize: 18, color: Colors.black),),
                          Text(scad.data!),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                },
                                icon: Icon( // <-- Icon
                                  Icons.arrow_forward,
                                  size: 24.0,
                                ),
                                label: Text('Visualizza'), // <-- Text
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      scad.inRimozione = true;
                                    });
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          )
                        ],
                      ),
                    )),
                  )).toList(),
            ),
          ),
          Row(
            children: [
              Text('Promemoria'),
              ElevatedButton.icon(
                onPressed: () {
                },
                icon: Icon( // <-- Icon
                  Icons.delete,
                  size: 24.0,
                ),
                label: Text('Pulisci'), // <-- Text
              )
            ],
          ),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: scadenze.map<Widget>(
                      (scad) => Container(
                    width: 250,
                    child: Card(child:
                    ListTile(
                      title: Column(
                        children: [
                          Text(
                            scad.denominazioneProdotto!,
                            style:TextStyle(fontSize: 18, color: Colors.black),),
                          Text(scad.data!),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                },
                                icon: Icon( // <-- Icon
                                  Icons.arrow_forward,
                                  size: 24.0,
                                ),
                                label: Text('Visualizza'), // <-- Text
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      scad.inRimozione = true;
                                    });
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          )
                        ],
                      ),
                    )),
                  )).toList(),
            ),
          ),
          Expanded(
            child: Text(''),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
              },
              icon: Icon( // <-- Icon
                Icons.add,
                size: 30.0,
              ),
              label: Text('Nuovo promemoria',
                style: TextStyle(
                    fontSize: 25
                ),
              ), // <-- Text
            ),
          )
        ],
      ),
    );
  }
}
