import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Promemoria.dart';
import 'package:pantrysmart/Classes/Scadenza.dart';
import 'package:pantrysmart/LandingViewBloc/landing_view_bloc.dart';
import 'package:pantrysmart/Presentation/Screens/promemoriaView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

List<Scadenza> scadenze = [];
List<Promemoria> listPromemoria = [];
DateTime oggi = DateTime.now();

class HomeView extends StatefulWidget {
  HomeView({super.key});
  @override
  State<HomeView> createState() => HomeViewState();
  List<Prodotto> prodotti = [];
  bool nuovaConfermaScadenze = false;
  bool nuovaConfermaPromemoria = false;
}

class HomeViewState extends State<HomeView> {
  bool mostraTabPromemoria = false;

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
    await prefs.remove('prodottoSelezionato_key');

    if(prodottiString != null){
      widget.prodotti = Prodotto.decode(prodottiString!);
      for(var prodotto in widget.prodotti){
        var dataScadenza = DateTime.tryParse(prodotto.scadenza!);
        var giornoScadenza = dataScadenza!
            .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
        var giornoOggi = oggi
            .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
        if(!prodotto.notificheDisattivate! && giornoOggi.isAfter(giornoScadenza)){
          Scadenza nuovaScadenza = Scadenza(
              idProdotto: prodotto.id,
              denominazioneProdotto: prodotto.denominazione,
              data: prodotto.scadenza,
              inRimozione: false
          );
          scadenze.add(nuovaScadenza);
        }
      }
    }

    setState(() {
      if(promemoriaString != null){
        listPromemoria = Promemoria.decode(promemoriaString);
        listPromemoria.sort((a, b) =>
            DateTime.parse(a.data!).compareTo(DateTime.parse(b.data!)));
      }
    });
  }

  Future<void> _loadPromemoria() async {
    final prefs = await SharedPreferences.getInstance();
    final String? promemoriaString = await prefs.getString('promemoria_key');
    if(promemoriaString != null) {
      listPromemoria = Promemoria.decode(promemoriaString);
      listPromemoria.sort((a, b) =>
          DateTime.parse(a.data!).compareTo(DateTime.parse(b.data!)));
    }
  }

  Future<void> _rimuoviPromemoria(Promemoria promemoria) async {
    final prefs = await SharedPreferences.getInstance();
    listPromemoria.remove(promemoria);
    String encodedPromemoria = Promemoria.encode(listPromemoria);
    await prefs.setString('promemoria_key', encodedPromemoria);
  }

  Future<void> _rimuoviPromemoriaTutti() async {
    final prefs = await SharedPreferences.getInstance();
    listPromemoria.clear();
    String encodedPromemoria = Promemoria.encode(listPromemoria);
    await prefs.setString('promemoria_key', encodedPromemoria);
  }

  Future<void> _salvaProdottoSelezionato(int prodottoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prodottoSelezionato_key', prodottoId.toString());
  }

  Future<void> _disattivaNotificheProdotto(int prodottoId) async {
    final prefs = await SharedPreferences.getInstance();
    var prodotto = widget.prodotti.firstWhere((element) => element.id == prodottoId);
    if(prodotto != null){
      prodotto.notificheDisattivate = true;
      var encodedData = Prodotto.encode(widget.prodotti);
      await prefs.setString('prodotti_key', encodedData);
    }
  }

  Future<void> _disattivaNotificheTutte() async {
    final prefs = await SharedPreferences.getInstance();
    for(var scadenza in scadenze){
      var prodotto = widget.prodotti.firstWhere((element) => element.id == scadenza.idProdotto);
      if(prodotto != null){
        prodotto.notificheDisattivate = true;
      }
    }
    var encodedData = Prodotto.encode(widget.prodotti);
    await prefs.setString('prodotti_key', encodedData);
  }

  void chiudiTabPromemoria(){
    setState(() {
      mostraTabPromemoria = false;
    });
  }

  void apriTabPromemoria(){
    setState(() {
      mostraTabPromemoria = true;});
  }

  void chiudiTabPromemoriaEAggiorna(){
    _loadPromemoria();
    setState(() {
      mostraTabPromemoria = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (!mostraTabPromemoria) ?
      Column(
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
                    onPressed: (scadenze.isNotEmpty)? () {
                      setState(() {
                        widget.nuovaConfermaScadenze = true;
                      });
                    }:
                    null,
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
          (scadenze.isNotEmpty)?
          Container(
            height: 168,
            child: (!widget.nuovaConfermaScadenze)?
            ListView(
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
                        child: (!scad.inRimozione!)?
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                child: Text('NOME:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: CustomColors.primary
                                  ),),
                              ),
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
                                  BlocConsumer<LandingViewBloc, LandingViewState>(
                                      builder: (context, state){
                                        return ElevatedButton.icon(
                                          onPressed: () async {
                                            await _salvaProdottoSelezionato(scad.idProdotto!);
                                            BlocProvider.of<LandingViewBloc>(context).add(
                                                TabChange(
                                                    tabIndex: 1));
                                          },
                                          icon: Icon( // <-- Icon
                                            Icons.arrow_forward,
                                            size: 24.0,
                                          ),
                                          label: Text('Visualizza'), // <-- Text
                                        );
                                      },
                                      listener: (context, state){}),
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
                        )
                            :
                        ListTile(
                          title: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                  child: Text('Attenzione!\nLa notifica per l\'oggetto non verrà più mostrata.\n'
                                      'Confermare?',
                                      style: TextStyle(
                                          fontSize: 15
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,0,10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            scad.inRimozione = false;
                                          });
                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.close,
                                          size: 24.0,
                                        ),
                                        label: Text('No'), // <-- Text
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _disattivaNotificheProdotto(scad.idProdotto!);
                                          setState(() {
                                            scadenze.remove(scad);
                                          });
                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.done,
                                          size: 24.0,
                                        ),
                                        label: Text('Si'), // <-- Text
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        )),
                  )).toList(),
            )
                :
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: CustomColors.primaryContainer,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,10,0,0),
                        child: Text('Attenzione!\nLe notifiche elencate non verranno più mostrate.\n'
                            'Confermare?',
                            style: TextStyle(
                                fontSize: 18
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,0,10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  widget.nuovaConfermaScadenze = false;
                                });
                              },
                              icon: Icon( // <-- Icon
                                Icons.close,
                                size: 24.0,
                              ),
                              label: Text('No'), // <-- Text
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _disattivaNotificheTutte();
                                setState(() {
                                  scadenze.clear();
                                  widget.nuovaConfermaScadenze = false;
                                });
                              },
                              icon: Icon( // <-- Icon
                                Icons.done,
                                size: 24.0,
                              ),
                              label: Text('Si'), // <-- Text
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              :
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Nessuna scadenza da visualizzare.'),
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
                    onPressed: (listPromemoria != null && listPromemoria.isNotEmpty)? () {
                      setState(() {
                        widget.nuovaConfermaPromemoria = true;
                      });
                    }:
                    null,
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
          (listPromemoria.isNotEmpty)?
          Container(
            height: 168,
            child: (!widget.nuovaConfermaPromemoria)?
            ListView(
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
                        child: (!prom.inRimozione!)?
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                child: Text('RICORDAMI DI:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: CustomColors.primary
                                  ),),
                              ),
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
                              Text(prom.data!.substring(0,16)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  (DateTime.tryParse(prom.data!)!.isAfter(DateTime.now()))?
                                  Text('Attivo',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: CustomColors.primary
                                    ),) :
                                  Text('Scaduto',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: CustomColors.secondary
                                    ),),
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
                        ) :
                        ListTile(
                          title: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                  child: Text('Rimuovere il promemoria selezionato?',
                                      style: TextStyle(
                                          fontSize: 15
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,0,0,10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            prom.inRimozione = false;
                                          });
                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.close,
                                          size: 24.0,
                                        ),
                                        label: Text('No'), // <-- Text
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _rimuoviPromemoria(prom);
                                          setState(() {
                                          });
                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.done,
                                          size: 24.0,
                                        ),
                                        label: Text('Si'), // <-- Text
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        )
                    ),
                  )).toList(),
            ) :
            Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: CustomColors.primaryContainer,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: ListTile(
                  title:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,20,0,0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Rimuovere tutti i promemoria elencati?',
                                style: TextStyle(
                                    fontSize: 18
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,0,10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  widget.nuovaConfermaPromemoria = false;
                                });
                              },
                              icon: Icon( // <-- Icon
                                Icons.close,
                                size: 24.0,
                              ),
                              label: Text('No'), // <-- Text
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _rimuoviPromemoriaTutti();
                                setState(() {
                                  widget.nuovaConfermaPromemoria = false;
                                });
                              },
                              icon: Icon( // <-- Icon
                                Icons.done,
                                size: 24.0,
                              ),
                              label: Text('Si'), // <-- Text
                            ),
                          ],
                        ),
                      ),
                    ],),
                ),
              ),
            ),
          ) :
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Nessun promemoria da visualizzare.'),
          ),
          Expanded(
            child: Text(''),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,10),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mostraTabPromemoria = true;
                });
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
      ) :
      PromemoriaView(title: 'Crea un nuovo Promemoria!',
          cancelFunction: chiudiTabPromemoria,
          okFunction: chiudiTabPromemoriaEAggiorna),
    );
  }
}
