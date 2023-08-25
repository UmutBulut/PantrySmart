import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Storico.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Presentation/Screens/prodottoView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

List<DatoStorico> listaStorico = [];

class StoricoView extends StatefulWidget {
  StoricoView({super.key});
  @override
  State<StoricoView> createState() => StoricoViewState();
}

class StoricoViewState extends State<StoricoView> {
  final fieldText = TextEditingController();
  bool mostraTabProdotto = false;
  String? dataSelezionata;
  Prodotto? prodottoDaModificare;

  @override
  void initState() {
    super.initState();
    dataSelezionata = DateTime.now().toString();
    _loadprefs();
  }

  @override
  void dispose() {
    fieldText.dispose();
    super.dispose();
  }

  Future<void> _loadprefs() async {
    final prefs = await SharedPreferences.getInstance();

    /*String encodedData = '';
    List<DatoStorico> listaTest = [
      DatoStorico(
          idProdotto:74,
          denominazioneProdotto: 'Formaggio',
          tipoOperazione: 'Rimozione',
          dataOperazione: DateTime.now().toString(),
          inRimozione: false)
    ];
    encodedData = DatoStorico.encode(listaTest);
    await prefs.setString('storico_key', encodedData);*/


    final String? storicoString = await prefs.getString('storico_key');
    setState(() {
      listaStorico = DatoStorico.decode(storicoString!);
    });
  }

  Future<void> _saveprefs() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = '';
    encodedData = DatoStorico.encode(listaStorico);
    await prefs.setString('storico_key', encodedData);
  }

  void getSelectedDate(DateTime res) {
    setState(() {
      dataSelezionata = res.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 208,
              height: 50,
              child: PantryDatePicker(
                buttonLabel: 'Filtra\nper data:',
                notifyParent: getSelectedDate,
                dateString: dataSelezionata!,
              ),
            ),
            SizedBox(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {

                  });
                },
                icon: Icon( // <-- Icon
                  Icons.delete,
                ),
                label: Text('Rimuovi\ntutto'), // <-- Text
              ),
            ),
          ],
        ),
        Expanded(
            child:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: (listaStorico != null)? ListView(
                scrollDirection: Axis.vertical,
                children: listaStorico.map<Widget>(
                        (stor) => Card(
                      child: (!stor.inRimozione!)?
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Nome prodotto:',
                                          style: TextStyle(
                                              color: CustomColors.primary
                                          )),
                                      Text(stor.denominazioneProdotto!),
                                    ],
                                  ),
                                  Text(stor.tipoOperazione!),
                                  Text(stor.dataOperazione!),
                                ],
                              ),
                              IconButton(onPressed: (){},
                                  icon: Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      ) :
                      ListTile(
                        title: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0,0,0,10),
                              child: Text('Confermi la rimozione dell\'operazione?',
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
                                  stor.inRimozione = false;
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
                                  listaStorico.remove(stor);
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
              ) :
              Text('Nessun operazione'),
            )),
      ],
    );
  }
}
