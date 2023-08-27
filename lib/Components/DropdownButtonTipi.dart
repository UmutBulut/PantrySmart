import 'package:flutter/material.dart';
import 'package:pantrysmart/Classes/Colors.dart';
import 'package:pantrysmart/Classes/TipiIcone.dart';

class DropdownButtonTipi extends StatefulWidget {
  DropdownButtonTipi({
    super.key,
    required this.notifyParent,
    required this.permettiQualsiasi,
    required this.filtroOperazioni,
    this.tipoIniziale
  });
  final Function(String res) notifyParent;
  final bool filtroOperazioni;
  final bool permettiQualsiasi;
  String? tipoIniziale;
  @override
  State<DropdownButtonTipi> createState() => _DropdownButtonTipiState();
}

class _DropdownButtonTipiState extends State<DropdownButtonTipi> {
  String dropdownValue = "";
  List<String> list = [];

  @override
  void initState() {
    super.initState();
    list = widget.filtroOperazioni ?
    List.of(listFiltriTipoOperazioni) :
    List.of(listFiltriTipoProdotti);

    if(widget.permettiQualsiasi)
      list.insert(0,'Qualsiasi');

    if(widget.tipoIniziale != null)
      dropdownValue = widget.tipoIniziale!;
    else
      dropdownValue = list.first;
  }

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
          widget.notifyParent(value);
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