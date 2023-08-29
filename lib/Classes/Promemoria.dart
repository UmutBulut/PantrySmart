import 'dart:convert';

class Promemoria {
  int? id;
  String? testo;
  String? data;
  bool? inRimozione;

  Promemoria({
    this.id,
    this.testo,
    this.data,
    this.inRimozione
  });

  factory Promemoria.fromJson(Map<String, dynamic> jsonData) {
    return Promemoria(
      id: jsonData['id'],
      testo: jsonData['testo'],
      data: jsonData['data'],
      inRimozione: jsonData['inRimozione'],
    );
  }

  static Map<String, dynamic> toMap(Promemoria promemoria) => {
    'id': promemoria.id,
    'testo': promemoria.testo,
    'data': promemoria.data,
    'inRimozione': promemoria.inRimozione,
  };

  static String encode(List<Promemoria> proms) => json.encode(
    proms
        .map<Map<String, dynamic>>((promemoria) => Promemoria.toMap(promemoria))
        .toList(),
  );

  static List<Promemoria> decode(String proms) =>
      (json.decode(proms) as List<dynamic>)
          .map<Promemoria>((item) => Promemoria.fromJson(item))
          .toList();
}