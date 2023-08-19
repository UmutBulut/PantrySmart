import 'package:pantrysmart/Classes/Enums.dart';

class StorageHelper{
  static TipiProdotto? fromInteger(int x) {
    switch(x) {
      case 0:
        return TipiProdotto.ortofrutta;
      case 1:
        return TipiProdotto.panetteria;
      case 2:
        return TipiProdotto.macelleria;
      case 3:
        return TipiProdotto.frigo;
      case 4:
        return TipiProdotto.bevande;
      case 5:
        return TipiProdotto.altro;
    }
    return null;
  }

  static int? fromTipo(TipiProdotto x) {
    switch(x) {
      case TipiProdotto.ortofrutta:
        return 0;
      case TipiProdotto.panetteria:
        return 1;
      case TipiProdotto.macelleria:
        return 2;
      case TipiProdotto.frigo:
        return 3;
      case TipiProdotto.bevande:
        return 4;
      case TipiProdotto.altro:
        return 5;
    }
    return null;
  }
}