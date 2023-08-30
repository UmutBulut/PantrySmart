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
          Padding(
            padding: const EdgeInsets.fromLTRB(0,16,0,0),
            child: Text('Oggi è il: ' + oggi.toString().substring(0,10),
              style: TextStyle(
                  fontSize: 20
              ),),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,20,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,0,0,0),
                  child: Text('SCADENZE',
                    style: TextStyle(
                        fontSize: 28,
                        color: CustomColors.primaryContainer
                    ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: Icon( // <-- Icon
                      Icons.delete,
                      size: 24.0,
                    ),
                    label: Text('Pulisci'), // <-- Text
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 158,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: scadenze.map<Widget>(
                      (scad) => Container(
                    width: 250,
                    child: Card(
                        shape: RoundedRectangleBorder( //<-- SEE HERE
                          side: BorderSide(
                            color: CustomColors.primaryContainer,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child:
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NOME:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: CustomColors.primary
                                ),),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,0,10),
                                child: Text(
                                  scad.denominazioneProdotto!,
                                  style:TextStyle(fontSize: 18, color: Colors.black),),
                              ),
                              Text('SCADUTO IL:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: CustomColors.primary
                                ),),
                              Text(scad.data!.substring(0,10)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0,25,0,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,0,0,0),
                  child: Text('PROMEMORIA',
                    style: TextStyle(
                        fontSize: 28,
                        color: CustomColors.primaryContainer
                    ),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: Icon( // <-- Icon
                      Icons.delete,
                      size: 24.0,
                    ),
                    label: Text('Pulisci'), // <-- Text
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 158,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: listPromemoria.map<Widget>(
                      (prom) => Container(
                    width: 250,
                    child: Card(
                        shape: RoundedRectangleBorder( //<-- SEE HERE
                          side: BorderSide(
                            color: CustomColors.primaryContainer,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RICORDAMI DI:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: CustomColors.primary
                                ),),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,0,10),
                                child: Text(
                                  prom.testo!,
                                  style:TextStyle(fontSize: 18, color: Colors.black),),
                              ),
                              Text('QUANDO:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: CustomColors.primary
                                ),),
                              Text(prom.data!.substring(0,10)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          prom.inRimozione = true;
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,10),
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
