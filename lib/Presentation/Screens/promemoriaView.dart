import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantrysmart/Classes/Prodotto.dart';
import 'package:pantrysmart/Classes/Promemoria.dart';
import 'package:pantrysmart/Classes/Storico.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Components/DatePicker.dart';
import 'package:pantrysmart/Components/DropdownButtonTipi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromemoriaView extends StatefulWidget{
  PromemoriaView({super.key,
    required this.title,
    required this.cancelFunction,
    required this.okFunction,
  });
  final String title;
  final Function() cancelFunction;
  final Function() okFunction;
  bool abilitaSalva = false;

  //campi del promemoria
  String? testo;
  String? data;

  @override
  State<PromemoriaView> createState() => PromemoriaViewState();
}

class PromemoriaViewState extends State<PromemoriaView> {
  @override
  void initState() {
    super.initState();
      widget.testo = "";
      widget.data = DateTime.now().toString();
    refreshAbilitaSalva();
  }

  void refreshAbilitaSalva(){
    widget.abilitaSalva = (
        widget.testo!.isNotEmpty &&
            widget.data!.isNotEmpty
    );
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();

    final String? promemoriaString = await prefs.getString('promemoria_key');

    var listaPromemoria = Promemoria.decode(promemoriaString!);

      var nuovoId = 1;
      if(listaPromemoria.isNotEmpty)
      {
        var ultimoPromemoria = listaPromemoria.last;
        nuovoId = ultimoPromemoria.id! +1;
      }

      var nuovoPromemoria = Promemoria(
          id: nuovoId,
          testo: widget.testo,
          data: widget.data,
          inRimozione: false,
      );
    listaPromemoria.add(nuovoPromemoria);

    String encodedPromemoria = Promemoria.encode(listaPromemoria);
    await prefs.setString('promemoria_key', encodedPromemoria);
    widget.okFunction();
  }

  void getSelectedDate(DateTime res) {
    setState(() {
      widget.data = res.toString();
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Inserisci un Testo [OBBLIGATORIO]',
              ),
              onChanged: (value) {
                setState(() {
                  widget.testo = value;
                  refreshAbilitaSalva();
                });
              },),
          ),
        ),
        CalendarDatePicker(
          onDateChanged: (DateTime time){},
          initialDate: DateTime.now(),
          firstDate: DateTime(2021),
          lastDate: DateTime(2025),
        ),
        Expanded(
            child: IconButton(
              onPressed: () async {
                TimeOfDay? pickedTime =  await showTimePicker(
                  initialTime: TimeOfDay.now(),
                  context: context,
                );
              },
              icon: Icon(Icons.access_time),
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