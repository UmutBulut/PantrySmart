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
String dropdownValue = list.first;

class ListaView extends StatefulWidget {
  ListaView({super.key});
  @override
  State<ListaView> createState() => ListaViewState();
}

class ListaViewState extends State<ListaView> {
  //final SharedPreferences prefs;
  List<Prodotto> prodotti = [];

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
          scadenza: DateTime.now().toString()),
      Prodotto(
          id:2,
          denominazione: 'Vino',
          tipo: 'Bevande',
          prezzo: 7,
          quantita: '1L',
          scadenza: DateTime.now().toString()),
    ];
    encodedData = Prodotto.encode(listaTest);
    await prefs.setString('prodotti_key', encodedData);*/
    final String? prodottiString = await prefs.getString('prodotti_key');
    setState(() {
      prodotti = Prodotto.decode(prodottiString!);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,16,32,16),
              child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    hintText: 'Ricerca',
                  )),
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
                  child: DropdownButtonTipi(),
                ),
              ],
            ),
            Expanded(
                child:  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: prodotti.map<Widget>(
                            (v) => Card(
                          child: ListTile(
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
                                              onPressed: (){},
                                              icon: Icon(Icons.delete)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
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
  const DropdownButtonTipi({super.key});
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
        });
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
