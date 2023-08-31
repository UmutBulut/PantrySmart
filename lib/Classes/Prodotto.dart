import 'dart:convert';

class Prodotto {
  int? id;
  String? denominazione;
  String? tipo;
  String? prezzo;
  String? quantita;
  String? scadenza;
  String? immagine;
  bool? inRimozione;
  bool? notificheDisattivate;

  Prodotto({
    this.id,
    this.denominazione,
    this.tipo,
    this.prezzo,
    this.quantita,
    this.scadenza,
    this.immagine,
    this.inRimozione,
    this.notificheDisattivate
  });

  factory Prodotto.fromJson(Map<String, dynamic> jsonData) {
    return Prodotto(
        id: jsonData['id'],
        denominazione: jsonData['denominazione'],
        tipo: jsonData['tipo'],
        prezzo: jsonData['prezzo'],
        quantita: jsonData['quantita'],
        scadenza: jsonData['scadenza'],
        immagine: jsonData['immagine'],
        inRimozione: jsonData['inRimozione'],
        notificheDisattivate: jsonData['notificheDisattivate']
    );
  }

  static Map<String, dynamic> toMap(Prodotto prodotto) => {
    'id': prodotto.id,
    'denominazione': prodotto.denominazione,
    'tipo': prodotto.tipo,
    'prezzo': prodotto.prezzo,
    'quantita': prodotto.quantita,
    'scadenza': prodotto.scadenza,
    'immagine': prodotto.immagine,
    'inRimozione': prodotto.inRimozione,
    'notificheDisattivate': prodotto.notificheDisattivate,
  };

  static String encode(List<Prodotto> prodotti) => json.encode(
    prodotti
        .map<Map<String, dynamic>>((prodotto) => Prodotto.toMap(prodotto))
        .toList(),
  );

  static List<Prodotto> decode(String prodotti) =>
      (json.decode(prodotti) as List<dynamic>)
          .map<Prodotto>((item) => Prodotto.fromJson(item))
          .toList();
}