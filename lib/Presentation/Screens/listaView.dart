import 'package:flutter/material.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';


List<String> list = <String>[
  'Qualsiasi',
  'Ortofrutta',
  'Panetteria',
  'Macelleria',
  'Frigo/surgelati',
  'Bevande',
  'Altro'];

Map<String, IconData> iconsMap = {
  'Ortofrutta': Icons.apple,
  'Panetteria': Icons.bakery_dining,
  'Macelleria': Icons.kebab_dining,
  'Frigo/surgelati': Icons.ac_unit,
  'Bevande': Icons.local_bar,
  'Altro': Icons.pending,
};

List<Prodotto> prodotti = [];
List<Prodotto> prodottiFiltratiRicerca = [];
List<Prodotto> prodottiFiltratiTipo = [];
List<Prodotto> prodottiFiltratiFinali = [];

class ListaView extends StatefulWidget {
  ListaView({super.key});
  @override
  State<ListaView> createState() => ListaViewState();
}

class ListaViewState extends State<ListaView> {
  //final SharedPreferences prefs;
  final fieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadprefs();
  }

  Future<void> _loadprefs() async {
    final prefs = await SharedPreferences.getInstance();
    /*String encodedData = '';
    List<Prodotto> listaTest = [
      Prodotto(
          id:1,
          denominazione: 'Formaggio',
          tipo: 'Frigo/surgelati',
          prezzo: 0.5,
          quantita: '150g',
          scadenza: DateTime.now().toString(),
          inRimozione: false),
      Prodotto(
          id:2,
          denominazione: 'Vino',
          tipo: 'Bevande',
          prezzo: 7,
          quantita: '1L',
          scadenza: DateTime.now().toString(),
          inRimozione: false),
    ];
    encodedData = Prodotto.encode(listaTest);
    await prefs.setString('prodotti_key', encodedData);*/

    final String? prodottiString = await prefs.getString('prodotti_key');
    setState(() {
      prodotti = Prodotto.decode(prodottiString!);
      prodottiFiltratiRicerca = prodotti;
      prodottiFiltratiTipo = prodotti;
      prodottiFiltratiFinali = prodotti;
    });
  }

  Future<void> _saveprefs() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = '';
    encodedData = Prodotto.encode(prodotti);
    await prefs.setString('prodotti_key', encodedData);
  }

  void clearText() {
    fieldText.clear();
  }

  void refresh() {
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                  child: DropdownButtonTipi(notifyParent: refresh),
                ),
              ],
            ),
            Expanded(
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: prodottiFiltratiFinali.map<Widget>(
                            (v) => Card(
                          child: (!v.inRimozione!)?
                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.fromLTRB(0,0,0,10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(iconsMap[v.tipo!],
                                        size: 25,),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10,0,0,0),
                                        child: Text(
                                          v.denominazione!,
                                          style: TextStyle(
                                              fontSize: 25
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '('+v.prezzo.toString()+'€)',
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
                                Text('Quantità: '+ v.quantita!,
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                                Text('Scadenza: '+ v.scadenza!.substring(0,10),
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: Icon( // <-- Icon
                                          Icons.visibility,
                                          size: 24.0,
                                        ),
                                        label: Text('Visualizza immagine'), // <-- Text
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: (){},
                                              icon: Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: (){
                                                setState(() {
                                                  v.inRimozione = true;
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
                                  padding: const EdgeInsets.fromLTRB(0,0,0,10),
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
                                      v.inRimozione = false;
                                    });
                                  },
                                  icon: Icon( // <-- Icon
                                    Icons.close,
                                    size: 24.0,
                                  ),
                                  label: Text('No'), // <-- Text
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      prodottiFiltratiFinali.remove(v);
                                      prodotti.remove(v);
                                      _saveprefs();
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
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,10),
              child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyBoardVisible) {
                    return Visibility(
                      visible: !isKeyBoardVisible,
                      child: ElevatedButton.icon(
                        onPressed: () {},
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
      ),
    );
  }
}

class DropdownButtonTipi extends StatefulWidget {
  const DropdownButtonTipi({super.key, required this.notifyParent});
  final Function() notifyParent;
  @override
  State<DropdownButtonTipi> createState() => _DropdownButtonTipiState();
}

class _DropdownButtonTipiState extends State<DropdownButtonTipi> {
  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: CustomColors.primary),
      underline: Container(
        height: 2,
        color: CustomColors.primaryContainer,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          if(value == 'Qualsiasi'){
            prodottiFiltratiTipo = prodotti;
            prodottiFiltratiFinali =
                prodottiFiltratiTipo.toSet().where((element) =>
                    prodottiFiltratiRicerca.toSet().contains(element))
                    .toList();
          }else{
            prodottiFiltratiTipo = prodotti.where((p) => p.tipo == value).toList();
            prodottiFiltratiFinali =
                prodottiFiltratiTipo.toSet().where((element) =>
                    prodottiFiltratiRicerca.toSet().contains(element))
                    .toList();
          }
        });
        widget.notifyParent();
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              (value == 'Qualsiasi')?
              const Text(''):
              Icon(iconsMap[value])
              ,
              Padding(
                padding: const EdgeInsets.fromLTRB(10,0,0,0),
                child: Text(value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
