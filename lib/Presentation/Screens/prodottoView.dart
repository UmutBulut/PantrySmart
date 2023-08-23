import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';

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

  //campi del prodotto
  String denominazione = "";
  String prezzo  = "";
  String quantita = "";
  String tipo = "";
  String scadenza = "";
  String immagine = "";

  @override
  State<ProdottoView> createState() => ProdottoViewState();
}

class ProdottoViewState extends State<ProdottoView> {

  Future<void> getImage() async {
    widget.image = await widget.imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      widget.immagine = widget.image.toString();
    });
  }

  void refresh() {
    setState(() {});
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
                labelText: 'Inserisci un Nome',
              ),
              onSubmitted: (value) {
                setState(() {
                  widget.denominazione = value;
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
                labelText: 'Inserisci un Prezzo (€)',
              ),
              onSubmitted: (value) {
                setState(() {
                  widget.prezzo = value + ' (€)';
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
                labelText: 'Inserisci una Quantità',
              ),
              onSubmitted: (value) {
                setState(() {
                  widget.quantita = value;
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
            notifyParent: refresh,
            dateString: widget.scadenza,
          ),
        ),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16,8,16,8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                    ),
                    onPressed: () {
                      getImage();
                    },
                    icon: Icon( // <-- Icon
                      Icons.upload,
                      size: 24.0,
                    ),
                    label: Text('Carica immagine'), // <-- Text
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16,0,0),
                    child: (widget.image != null)?
                    Text(widget.image!.name):
                    Text('Nessuna immagine selezionata.'),
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
                            onPressed: () {
                              setState(() {
                                widget.okFunction();
                              });
                            },
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