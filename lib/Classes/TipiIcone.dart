import 'package:flutter/material.dart';

List<String> listFiltri = <String>[
  'Qualsiasi',
  'Ortofrutta',
  'Panetteria',
  'Macelleria',
  'Frigo/surgelati',
  'Bevande',
  'Altro'];

List<String> listFiltriSenzaQualsiasi = <String>[
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