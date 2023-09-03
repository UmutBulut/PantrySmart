import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Storico.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';
import 'package:pantrysmart/Presentation/Screens/prodottoView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

List<Prodotto> prodotti = [];
List<Prodotto> prodottiFiltratiRicerca = [];
List<Prodotto> prodottiFiltratiTipo = [];
List<Prodotto> prodottiFiltratiFinali = [];

class ListaView extends StatefulWidget {
  ListaView({super.key});
  String? tipoProdottoSelezionato;
  @override
  State<ListaView> createState() => ListaViewState();
}

class ListaViewState extends State<ListaView> {
  final fieldText = TextEditingController();
  bool mostraTabProdotto = false;
  Prodotto? prodottoDaModificare;

  @override
  void initState() {
    super.initState();
    _loadprefs();
  }

  @override
  void dispose() {
    fieldText.dispose();
    super.dispose();
  }

  Future<void> _loadprefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? prodottiString = await prefs.getString('prodotti_key');
    final String? prodottoSelezionatoString = await prefs.getString('prodottoSelezionato_key');
    await prefs.remove('prodottoSelezionato_key');

    setState(() {
      if(prodottiString != null){
        prodotti = Prodotto.decode(prodottiString!);

        if(prodottoSelezionatoString != null){
          var prodottoId = int.tryParse(prodottoSelezionatoString);
          var prodottoSelezionato = prodotti.firstWhere((element) => element.id == prodottoId);
          prodottiFiltratiRicerca = [prodottoSelezionato];
          prodottiFiltratiTipo = [prodottoSelezionato];
          prodottiFiltratiFinali = [prodottoSelezionato];

          fieldText.text = prodottoSelezionato.denominazione!;
          widget.tipoProdottoSelezionato = prodottoSelezionato.tipo!;
        }
        else{
          widget.tipoProdottoSelezionato = null;
          prodottiFiltratiRicerca = prodotti;
          prodottiFiltratiTipo = prodotti;
          prodottiFiltratiFinali = prodotti;
        }
      }
    });
  }

  Future<void> _saveProdotti(Prodotto prodotto) async {
    final prefs = await SharedPreferences.getInstance();
    prodottiFiltratiFinali.remove(prodotto);
    prodotti.remove(prodotto);
    var encodedData = Prodotto.encode(prodotti);
    await prefs.setString('prodotti_key', encodedData);
  }

  Future<void> _saveStorico(int id, String denominazione) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storicoString = await prefs.getString('storico_key');
    List<DatoStorico> listaStorico = [];

    if(storicoString != null)
      listaStorico = DatoStorico.decode(storicoString!);

    var nuovaOperazione = DatoStorico(
        idProdotto: id,
        denominazioneProdotto: denominazione,
        tipoOperazione: 'Rimozione',
        dataOperazione: DateTime.now().toString(),
        inRimozione: false
    );
    listaStorico.add(nuovaOperazione);
    var encodedData = DatoStorico.encode(listaStorico);
    await prefs.setString('storico_key', encodedData);
  }

  void clearText() {
    fieldText.clear();
  }

  void applicaFiltroProdotti(String res) {
    setState(() {
      if(res == 'Qualsiasi')
        prodottiFiltratiTipo = prodotti;
      else
        prodottiFiltratiTipo = prodotti.where((p) => p.tipo == res).toList();

      prodottiFiltratiFinali =
          prodottiFiltratiTipo.toSet().where((element) =>
              prodottiFiltratiRicerca.toSet().contains(element))
              .toList();
    });
  }

  void chiudiTabProdotto(){
    setState(() {
      mostraTabProdotto = false;
      prodottoDaModificare = null;
    });
  }

  void apriTabProdotto(){
    setState(() {mostraTabProdotto = true;});
  }

  void chiudiTabProdottoEAggiorna(){
    _loadprefs();
    setState(() {
      mostraTabProdotto = false;
      prodottoDaModificare = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: !mostraTabProdotto ?
      Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,16,16,16),
              child: Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,10,0),
                      child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            hintText: 'Ricerca per nome',
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              prodottiFiltratiRicerca =
                                  prodotti.where((p) => p.denominazione == value).toList();
                              prodottiFiltratiFinali =
                                  prodottiFiltratiRicerca.toSet().where((element) =>
                                      prodottiFiltratiTipo.toSet().contains(element))
                                      .toList();
                            });
                          },
                          controller: fieldText),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      clearText();
                      setState(() {
                        prodottiFiltratiRicerca = prodotti;
                        prodottiFiltratiFinali =
                            prodottiFiltratiRicerca.toSet().where((element) =>
                                prodottiFiltratiTipo.toSet().contains(element))
                                .toList();
                      });
                    },
                    icon: Icon( // <-- Icon
                      Icons.backspace,
                    ),
                    label: Text('Reset'), // <-- Text
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Filtra per tipo:',
                  style: TextStyle(
                      fontSize: 18
                  ),),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,0,0,0),
                  child: DropdownButtonTipi(
                      notifyParent: applicaFiltroProdotti,
                      permettiQualsiasi: true,
                      filtroOperazioni: false,
                      tipoIniziale: widget.tipoProdottoSelezionato,
                  ),
                ),
              ],
            ),
            (prodotti.isNotEmpty)?
            Expanded(
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (prodottiFiltratiFinali != null)? ListView(
                    scrollDirection: Axis.vertical,
                    children: prodottiFiltratiFinali.map<Widget>(
                            (prod) => Card(
                          shape: RoundedRectangleBorder( //<-- SEE HERE
                            side: BorderSide(
                              color: CustomColors.primaryContainer,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                              bottom: Radius.circular(30),
                            ),
                          ),
                          child: (!prod.inRimozione!)?
                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.fromLTRB(0,10,0,10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(iconsMap[prod.tipo!],
                                        size: 25,),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10,0,0,0),
                                        child: Text(
                                          prod.denominazione!,
                                          style: TextStyle(
                                              fontSize: 25
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '('+prod.prezzo.toString()+'€)',
                                    style: TextStyle(
                                      color: CustomColors.primaryContainer,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantità: '+ prod.quantita!,
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                                Text('Scadenza: '+ prod.scadenza!.substring(0,10),
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,10,0,3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: (prod.immagine != null)?() async {
                                          await showDialog(context: context, builder: (context) =>
                                              AlertDialog(
                                                  content: Image.memory(
                                                    base64Decode(prod.immagine!),
                                                  ),
                                                  actionsAlignment: MainAxisAlignment.end,
                                                  actions: [
                                                    ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon( // <-- Icon
                                                        Icons.close,
                                                        size: 24.0,
                                                      ),
                                                      label: Text(
                                                          'Chiudi'
                                                      ), // <-- Text
                                                    ),
                                                  ])
                                          );
                                        } :
                                        null,
                                        icon: Icon( // <-- Icon
                                          Icons.visibility,
                                          size: 24.0,
                                        ),
                                        label: Text('Visualizza immagine'), // <-- Text
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: (){
                                                setState(() {
                                                  mostraTabProdotto = true;
                                                  prodottoDaModificare = prod;
                                                });
                                              },
                                              icon: Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: (){
                                                setState(() {
                                                  prod.inRimozione = true;
                                                });
                                              },
                                              icon: Icon(Icons.delete)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ) :
                          ListTile(
                            title: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0,10,0,10),
                                  child: Text('Confermi la rimozione dell\'oggetto?',
                                      style: TextStyle(
                                          fontSize: 20
                                      )),
                                )),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      prod.inRimozione = false;
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
                                    await _saveProdotti(prod);
                                    await _saveStorico(prod.id!, prod.denominazione!);
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
                          ),
                        )).toList(),
                  ) :
                  Text('Nessun prodotto'),
                )) :
            Expanded(child: Padding(
              padding: const EdgeInsets.fromLTRB(8,16,8,8),
              child: Text('Nessun prodotto da visualizzare.'),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,10),
              child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyBoardVisible) {
                    return Visibility(
                      visible: !isKeyBoardVisible,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          apriTabProdotto();
                        },
                        icon: Icon( // <-- Icon
                          Icons.add,
                          size: 30.0,
                        ),
                        label: Text('Aggiungi',
                          style: TextStyle(
                              fontSize: 25
                          ),
                        ), // <-- Text
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ) :
      ProdottoView(
          title: (prodottoDaModificare != null)?
          'Modifica i campi del Prodotto!' :
          'Aggiungi un nuovo Prodotto!',
          cancelFunction: chiudiTabProdotto,
          okFunction: chiudiTabProdottoEAggiorna,
          prodottoDaModificare: (prodottoDaModificare != null)?
          prodottoDaModificare :
          null),
    );
  }
}
