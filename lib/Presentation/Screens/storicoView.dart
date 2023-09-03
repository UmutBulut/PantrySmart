import 'package:flutter/material.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Storico.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<DatoStorico> listaStorico = [];
List<DatoStorico> listaStoricoFiltrataData = [];
List<DatoStorico> listaStoricoFiltrataTipo = [];
List<DatoStorico> listaStoricoFiltrataFinale = [];

class StoricoView extends StatefulWidget {
  StoricoView({super.key});
  @override
  State<StoricoView> createState() => StoricoViewState();
}

class StoricoViewState extends State<StoricoView> {
  bool nuovaConferma = false;
  String? dataSelezionata;
  Prodotto? prodottoDaModificare;
  bool? resettato;

  @override
  void initState() {
    super.initState();
    dataSelezionata = DateTime.now().toString();
    resettato = false;
    _loadprefs();
  }

  Future<void> _loadprefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? storicoString = await prefs.getString('storico_key');

    setState(() {
      if(storicoString != null){
        listaStorico = DatoStorico.decode(storicoString!);
        listaStoricoFiltrataData = listaStorico.where((element) =>
        element.dataOperazione!.substring(0,10) == dataSelezionata!.substring(0,10)).toList();
        applicaFiltroTipo('Qualsiasi');

        aggiornaLista();
      }
    });
  }

  Future<void> _saveprefs(DatoStorico? storico) async {
    final prefs = await SharedPreferences.getInstance();
    if(storico != null){
      listaStorico.remove(storico);
      listaStoricoFiltrataFinale.remove(storico);
    }
    else{
      listaStorico.clear();
      listaStoricoFiltrataFinale.clear();
    }

    String encodedData = DatoStorico.encode(listaStorico);
    await prefs.setString('storico_key', encodedData);
  }

  void getSelectedDate(DateTime res) {
    setState(() {
      dataSelezionata = res.toString();
      resettato = false;
      listaStoricoFiltrataData = listaStorico.where((element) =>
      element.dataOperazione!.substring(0,10) == dataSelezionata!.substring(0,10)).toList();

      aggiornaLista();
    });
  }

  void applicaFiltroTipo(String res) {
    setState(() {
      if(res == 'Qualsiasi')
        listaStoricoFiltrataTipo = listaStorico;
      else
        listaStoricoFiltrataTipo = listaStorico.where((p) => p.tipoOperazione == res).toList();

      aggiornaLista();
    });
  }

  void aggiornaLista(){
    listaStoricoFiltrataFinale =
        listaStoricoFiltrataTipo.toSet().where((element) =>
            listaStoricoFiltrataData.toSet().contains(element))
            .toList();
  }

  void resetData(){
    resettato = true;
    listaStoricoFiltrataData = listaStorico;

    aggiornaLista();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8,16,16,0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 255,
                height: 50,
                child: PantryDatePicker(
                  buttonLabel: 'Filtra\nper data:',
                  notifyParent: getSelectedDate,
                  resettato: resettato!,
                  dateString: dataSelezionata!,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    resetData();
                  });
                },
                icon: Icon( // <-- Icon
                  Icons.backspace,
                ),
                label: Text('Reset\ndata'), // <-- Text
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8,16,16,16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Filtra per Tipo:',
                style: TextStyle(
                    fontSize: 18
                ),),
              Padding(
                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                child: DropdownButtonTipi(
                    notifyParent: applicaFiltroTipo,
                    permettiQualsiasi: true,
                    filtroOperazioni: true,
                    tipoIniziale: null),
              ),
            ],
          ),
        ),
        (listaStorico.isNotEmpty)?
        Expanded(
            child: (!nuovaConferma)? Padding(
              padding: const EdgeInsets.all(8.0),
              child: (listaStoricoFiltrataFinale != null)? ListView(
                scrollDirection: Axis.vertical,
                children: listaStoricoFiltrataFinale.map<Widget>(
                        (stor) => Card(
                      shape: RoundedRectangleBorder( //<-- SEE HERE
                        side: BorderSide(
                          color: CustomColors.primaryContainer,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: (!stor.inRimozione!)?
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Nome prodotto:',
                                            style: TextStyle(
                                                color: CustomColors.primary
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8,0,0,0),
                                          child: Text(stor.denominazioneProdotto!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Tipo operazione:',
                                            style: TextStyle(
                                                color: CustomColors.primary
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8,0,0,0),
                                          child: Text(stor.tipoOperazione!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Data operazione:',
                                            style: TextStyle(
                                                color: CustomColors.primary
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8,0,0,0),
                                          child: Text(stor.dataOperazione!.substring(0,16)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(onPressed: (){
                                setState(() {
                                  stor.inRimozione = true;
                                });
                              },
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
                              onPressed: () async {
                                await _saveprefs(stor);
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
              Text('Nessuna operazione.'),
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
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confermi la rimozione\ndi tutte le operazioni?',
                            style: TextStyle(
                                fontSize: 20
                            )),
                      ],
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            nuovaConferma = false;
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
                          await _saveprefs(null);
                          setState(() {
                            nuovaConferma = false;
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
              ),
            )
        ):
        Expanded(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Nessuna operazione da visualizzare.'),
        )),
        Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,10),
            child: SizedBox(
              child: ElevatedButton.icon(
                onPressed: (!nuovaConferma && listaStorico.isNotEmpty)? () {
                  setState(() {
                    nuovaConferma = true;
                  });
                } :
                null,
                icon: Icon( // <-- Icon
                  Icons.delete,
                  size: 30.0,
                ),
                label: Text('Rimuovi tutto',
                    style: TextStyle(
                        fontSize: 25
                    )), // <-- Text
              ),
            )
        )
      ],
    );
  }
}
