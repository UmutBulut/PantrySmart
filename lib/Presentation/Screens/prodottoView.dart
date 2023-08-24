import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdottoView extends StatefulWidget{
  ProdottoView({super.key,
    required this.title,
    required this.cancelFunction,
    required this.okFunction,
    required this.denominazione,
    required this.prezzo,
    required this.quantita,
    required this.tipo,
    required this.scadenza,
    required this.immagine,
  });
  final String title;
  final Function() cancelFunction;
  final Function() okFunction;
  final ImagePicker imagePicker = ImagePicker();
  XFile? image;
  bool abilitaSalva = false;

  //campi del prodotto
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

    widget.denominazione = "";
    widget.prezzo  = "";
    widget.quantita = "";
    widget.tipo = listFiltriSenzaQualsiasi.first;
    widget.scadenza = DateTime.now().toString();
    widget.immagine = null;

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
    var prodotti = Prodotto.decode(prodottiString!);
    prodotti.sort((a, b) => a.id!.compareTo(b.id!));
    var ultimoProdotto = prodotti.last;
    var nuovoProdotto = Prodotto(
        id: 7,
        denominazione: widget.denominazione,
        prezzo: widget.prezzo!,
        tipo: widget.tipo,
        scadenza: widget.scadenza,
        quantita: widget.quantita,
        immagine: widget.immagine,
        inRimozione: false
    );
    prodotti.add(nuovoProdotto);
    String encodedData = Prodotto.encode(prodotti);
    await prefs.setString('prodotti_key', encodedData);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8,24,16,8),
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
            child: TextField(
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
            child: TextField(
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
            child: TextField(
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
                      permettiQualsiasi: false),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: PantryDatePicker(
            buttonLabel: 'Seleziona una data di Scadenza:',
            notifyParent: getSelectedDate,
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
                    onPressed: (widget.immagine != null)?() {
                      showDialog(context: context, builder: (context) =>
                          AlertDialog(
                              title: Text('Foto'),
                              content: Image.memory(
                                  base64Decode(widget.immagine!),
                              ))
                      );
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