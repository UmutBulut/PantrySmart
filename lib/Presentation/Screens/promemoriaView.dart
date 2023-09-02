import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pantrysmart/Classes/Promemoria.dart';
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
  DateTime? giorno;
  TimeOfDay? ora;
  String? oraString;

  @override
  State<PromemoriaView> createState() => PromemoriaViewState();
}

class PromemoriaViewState extends State<PromemoriaView> {
  @override
  void initState() {
    super.initState();
    widget.testo = "";
    widget.giorno = DateTime.now()
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0,microsecond: 0);
    widget.ora = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour +1);

    refreshAbilitaSalva();
  }

  void aggiornaOraString(TimeOfDay time){
    widget.oraString = time.format(context);
  }

  void refreshAbilitaSalva(){
    widget.abilitaSalva = (
        widget.testo!.isNotEmpty
    );
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();

    final String? promemoriaString = await prefs.getString('promemoria_key');
    List<Promemoria> lista = [];
    if(promemoriaString != null)
      lista = Promemoria.decode(promemoriaString!);

    var nuovoId = 1;
    if(lista.isNotEmpty)
    {
      var ultimoPromemoria = lista.last;
      nuovoId = ultimoPromemoria.id! +1;
    }

    var nuovoPromemoria = Promemoria(
      id: nuovoId,
      testo: widget.testo,
      data: widget.giorno!.add(Duration(hours: widget.ora!.hour, minutes: widget.ora!.minute)).toString(),
      inRimozione: false,
    );
    lista.add(nuovoPromemoria);

    String encodedPromemoria = Promemoria.encode(lista);
    await prefs.setString('promemoria_key', encodedPromemoria);

    widget.okFunction();
  }

  @override
  Widget build(BuildContext context) {
    aggiornaOraString(widget.ora!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8,24,16,16),
              child: Text(widget.title,
                style: TextStyle(
                    fontSize: 25
                ),),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,8,16,8),
          child: SizedBox(
            height: 50,
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ricordami di... [OBBLIGATORIO]',
              ),
              onChanged: (value) {
                setState(() {
                  widget.testo = value;
                  refreshAbilitaSalva();
                });
              },),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,16,0,0),
          child: Text('Quando?',style: TextStyle(
              fontSize: 20
          ),),
        ),
        Flexible(
          child: CalendarDatePicker(
            onDateChanged: (DateTime time){
              setState(() {
                widget.giorno = time;
              });
            },
            initialDate: DateTime.now(),
            firstDate: DateTime(2021),
            lastDate: DateTime(2025),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,16,0,0),
          child: Text('A che ora?',style: TextStyle(
              fontSize: 20
          ),),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16,0,0,0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                ),
                onPressed: () async {
                  TimeOfDay? pickedTime =  await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );
                  if(pickedTime != null){
                    setState(() {
                      widget.ora = pickedTime;
                      aggiornaOraString(widget.ora!);
                    });
                  }
                },
                icon: Icon( // <-- Icon
                  Icons.watch_later_outlined,
                  size: 24.0,
                ),
                label: Text(
                    'Seleziona un orario'
                ), // <-- Text
              ),
              Text(widget.oraString!)
            ],
          ),
        ),
        Expanded(
            child: Text("")
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