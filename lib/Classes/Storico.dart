import 'dart:convert';

class DatoStorico {
  int? idProdotto;
  String? denominazioneProdotto;
  String? tipoOperazione;
  String? dataOperazione;
  bool? inRimozione;

  DatoStorico({
    this.idProdotto,
    this.denominazioneProdotto,
    this.tipoOperazione,
    this.dataOperazione,
    this.inRimozione
  });

  factory DatoStorico.fromJson(Map<String, dynamic> jsonData) {
    return DatoStorico(
      idProdotto: jsonData['idProdotto'],
      denominazioneProdotto: jsonData['denominazioneProdotto'],
      tipoOperazione: jsonData['tipoOperazione'],
      dataOperazione: jsonData['dataOperazione'],
      inRimozione: jsonData['inRimozione']
    );
  }

  static Map<String, dynamic> toMap(DatoStorico storico) => {
    'idProdotto': storico.idProdotto,
    'denominazioneProdotto': storico.denominazioneProdotto,
    'tipoOperazione': storico.tipoOperazione,
    'dataOperazione': storico.dataOperazione,
    'inRimozione': storico.inRimozione,
  };

  static String encode(List<DatoStorico> dati) => json.encode(
    dati
        .map<Map<String, dynamic>>((dato) => DatoStorico.toMap(dato))
        .toList(),
  );

  static List<DatoStorico> decode(String dati) =>
      (json.decode(dati) as List<dynamic>)
          .map<DatoStorico>((item) => DatoStorico.fromJson(item))
          .toList();
}