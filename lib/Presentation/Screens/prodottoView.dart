import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Storico.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdottoView extends StatefulWidget{
  ProdottoView({super.key,
    required this.title,
    required this.cancelFunction,
    required this.okFunction,
    this.prodottoDaModificare,
  });
  final String title;
  final Function() cancelFunction;
  final Function() okFunction;
  final ImagePicker imagePicker = ImagePicker();
  XFile? image;
  bool abilitaSalva = false;
  bool nuovaConferma = false;

  //campi del prodotto
  Prodotto? prodottoDaModificare;
  String? denominazione;
  String? prezzo;
  String? quantita;
  String? tipo;
  String? scadenza;
  String? immagine;

  @override
  State<ProdottoView> createState() => ProdottoViewState();
}

class ProdottoViewState extends State<ProdottoView> {
  @override
  void initState() {
    super.initState();
    if(widget.prodottoDaModificare != null ){
      widget.denominazione = widget.prodottoDaModificare!.denominazione;
      widget.prezzo  = widget.prodottoDaModificare!.prezzo;
      widget.quantita = widget.prodottoDaModificare!.quantita;
      widget.tipo = widget.prodottoDaModificare!.tipo;
      widget.scadenza = widget.prodottoDaModificare!.scadenza;
      widget.immagine = widget.prodottoDaModificare!.immagine;
    }
    else{
      widget.denominazione = "";
      widget.prezzo  = "";
      widget.quantita = "";
      widget.tipo = listFiltriTipoProdotti.first;
      widget.scadenza = DateTime.now().toString();
      widget.immagine = null;
    }

    refreshAbilitaSalva();
  }

  void refreshAbilitaSalva(){
    widget.abilitaSalva = (
        widget.denominazione!.isNotEmpty &&
            widget.prezzo!.isNotEmpty &&
            widget.quantita!.isNotEmpty
    );
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();

    final String? prodottiString = await prefs.getString('prodotti_key');
    final String? storicoString = await prefs.getString('storico_key');

    var listaStorico = DatoStorico.decode(storicoString!);
    var prodotti = Prodotto.decode(prodottiString!);

    prodotti.sort((a, b) => a.id!.compareTo(b.id!));

    if(widget.prodottoDaModificare != null)
    {
      var nuovoProdotto = Prodotto(
          id: widget.prodottoDaModificare!.id,
          denominazione: widget.denominazione,
          prezzo: widget.prezzo!,
          tipo: widget.tipo,
          scadenza: widget.scadenza,
          quantita: widget.quantita,
          immagine: widget.immagine,
          inRimozione: false,
          notificheDisattivate: widget.prodottoDaModificare!.notificheDisattivate);

      var vecchioProdotto =
      prodotti.firstWhere((element) => element.id == widget.prodottoDaModificare!.id);
      prodotti.remove(vecchioProdotto);
      prodotti.add(nuovoProdotto);

      var nuovaOperazione = DatoStorico(
          idProdotto: widget.prodottoDaModificare!.id,
          denominazioneProdotto: widget.denominazione,
          tipoOperazione: 'Modifica',
          dataOperazione: DateTime.now().toString(),
          inRimozione: false
      );
      listaStorico.add(nuovaOperazione);
    }
    else
    {
      var nuovoId = 1;
      if(prodotti.isNotEmpty)
      {
        var ultimoProdotto = prodotti.last;
        nuovoId = ultimoProdotto.id! +1;
      }

      var nuovoProdotto = Prodotto(
          id: nuovoId,
          denominazione: widget.denominazione,
          prezzo: widget.prezzo!,
          tipo: widget.tipo,
          scadenza: widget.scadenza,
          quantita: widget.quantita,
          immagine: widget.immagine,
          inRimozione: false,
          notificheDisattivate: false
      );
      prodotti.add(nuovoProdotto);

      var nuovaOperazione = DatoStorico(
          idProdotto: nuovoId,
          denominazioneProdotto: widget.denominazione,
          tipoOperazione: 'Aggiunta',
          dataOperazione: DateTime.now().toString(),
          inRimozione: false
      );
      listaStorico.add(nuovaOperazione);
    }

    String encodedProdotti = Prodotto.encode(prodotti);
    await prefs.setString('prodotti_key', encodedProdotti);
    String encodedStorico = DatoStorico.encode(listaStorico);
    await prefs.setString('storico_key', encodedStorico);
    widget.okFunction();
  }

  Future<void> getImage() async {
    widget.image = await widget.imagePicker.pickImage(source: ImageSource.camera);
    var byteImage = await widget.image!.readAsBytes();
    String base64Image = base64Encode(byteImage);
    setState(() {
      widget.immagine = base64Image;
    });
  }

  void getSelectedDate(DateTime res) {
    setState(() {
      widget.scadenza = res.toString();
    });
  }

  void applicaFiltroProdotti(String res) {
    setState(() {
      widget.tipo = res;
    });
  }

  void aggiornaStatoImmagine(bool stato, bool rimuoviImmagine){
    setState(() {
      widget.nuovaConferma = stato;
      if(rimuoviImmagine){
        widget.immagine = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8,24,16,16),
            child: Text(widget.title,
              style: TextStyle(
                  fontSize: 25
              ),),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,8),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              initialValue: (widget.prodottoDaModificare != null)?
              widget.denominazione :
              null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Inserisci un Nome [OBBLIGATORIO]',
              ),
              onChanged: (value) {
                setState(() {
                  widget.denominazione = value;
                  refreshAbilitaSalva();
                });
              },),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,8),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              initialValue: (widget.prodottoDaModificare != null)?
              widget.prezzo :
              null,
              keyboardType:TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Inserisci un Prezzo (€) [OBBLIGATORIO]',
              ),
              onChanged: (value) {
                setState(() {
                  widget.prezzo = value;
                  refreshAbilitaSalva();
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,8),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              initialValue: (widget.prodottoDaModificare != null)?
              widget.quantita :
              null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Inserisci una Quantità [OBBLIGATORIO]',
              ),
              onChanged: (value) {
                setState(() {
                  widget.quantita = value;
                  refreshAbilitaSalva();
                });
              },),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28,8,16,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Seleziona un Tipo:',
                  style: TextStyle(
                      fontSize: 18
                  ),),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,0,0,0),
                  child: DropdownButtonTipi(
                      notifyParent: applicaFiltroProdotti,
                      permettiQualsiasi: false,
                      filtroOperazioni: false,
                      tipoIniziale: (widget.prodottoDaModificare != null)?
                      widget.tipo! :
                      null),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: PantryDatePicker(
            buttonLabel: 'Seleziona una\ndata di Scadenza:',
            notifyParent: getSelectedDate,
            resettato: false,
            dateString: widget.scadenza!,
          ),
        ),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16,8,16,8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                    ),
                    onPressed: () {
                      getImage();
                    },
                    icon: Icon( // <-- Icon
                      Icons.camera,
                      size: 24.0,
                    ),
                    label: Text(
                        'Scatta una\nFoto!'
                    ), // <-- Text
                  ),
                  ElevatedButton.icon(
                    onPressed: (widget.immagine != null)?() async {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context, setState) {
                              return AlertDialog(
                                  content: Image.memory(
                                    base64Decode(widget.immagine!),
                                  ),
                                  actionsAlignment: MainAxisAlignment.spaceBetween,
                                  actions: [
                                    ElevatedButton.icon(
                                      style: ButtonStyle(
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        aggiornaStatoImmagine(false, false);
                                      },
                                      icon: Icon( // <-- Icon
                                        Icons.close,
                                        size: 24.0,
                                      ),
                                      label: Text(
                                          'Chiudi'
                                      ), // <-- Text
                                    ),
                                    (!widget.nuovaConferma)?
                                    ElevatedButton.icon(
                                      style: ButtonStyle(
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          aggiornaStatoImmagine(true, false);
                                        });
                                      },
                                      icon: Icon( // <-- Icon
                                        Icons.delete,
                                        size: 24.0,
                                      ),
                                      label: Text(
                                          'Rimuovi'
                                      ), // <-- Text
                                    )
                                        :
                                    ElevatedButton.icon(
                                      style: TextButton.
                                      styleFrom(backgroundColor: CustomColors.secondary),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        aggiornaStatoImmagine(false, true);
                                      },
                                      icon: Icon( // <-- Icon
                                        Icons.delete,
                                        size: 24.0,
                                      ),
                                      label: Text(
                                          'Premi per confermare'
                                      ), // <-- Text
                                    )
                                  ]
                              );
                            });
                          });
                    } :
                    null,
                    icon: Icon( // <-- Icon
                      Icons.visibility,
                      size: 24.0,
                    ),
                    label: Text('Visualizza\nimmagine'), // <-- Text
                  ),
                ],
              ),
            )
        ),
        KeyboardVisibilityBuilder(
            builder: (context, isKeyBoardVisible) {
              return Visibility(
                  visible: !isKeyBoardVisible,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16,8,8,8),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                widget.cancelFunction();
                              });
                            },
                            icon: Icon( // <-- Icon
                              Icons.close,
                              size: 24.0,
                            ),
                            label: Text('Annulla'), // <-- Text
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8,8,16,8),
                          child: ElevatedButton.icon(
                            onPressed: widget.abilitaSalva? () {
                              setState(() {
                                _saveChanges();
                                widget.okFunction();
                              });
                            } :
                            null,
                            icon: Icon( // <-- Icon
                              Icons.save,
                              size: 24.0,
                            ),
                            label: Text('Salva'), // <-- Text
                          ),
                        ),
                      ],
                    ),
                  )
              );
            }),
      ],
    );
  }
}