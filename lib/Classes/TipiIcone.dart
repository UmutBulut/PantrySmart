import 'package:flutter/material.dart';

List<String> listFiltriTipoProdotti = <String>[
  'Ortofrutta',
  'Panetteria',
  'Macelleria',
  'Frigo/surgelati',
  'Bevande',
  'Altro'];

List<String> listFiltriTipoOperazioni = <String>[
  'Aggiunta',
  'Modifica',
  'Rimozione',];

Map<String, IconData> iconsMap = {
  'Ortofrutta': Icons.apple,
  'Panetteria': Icons.bakery_dining,
  'Macelleria': Icons.kebab_dining,
  'Frigo/surgelati': Icons.ac_unit,
  'Bevande': Icons.local_bar,
  'Altro': Icons.pending,
  'Rimozione': Icons.delete_forever_rounded,
  'Aggiunta': Icons.add,
  'Modifica': Icons.edit
};