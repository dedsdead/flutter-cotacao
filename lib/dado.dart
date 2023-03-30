class Dado {
  final String usdbrl;
  final String varusd;
  final String eurbrl;
  final String vareur;
  final String btcbrl;
  final String varbtc;

  const Dado(
      {required this.usdbrl,
      required this.varusd,
      required this.eurbrl,
      required this.vareur,
      required this.btcbrl,
      required this.varbtc});

  factory Dado.fromJson(Map<String, dynamic> json) {
    return Dado(
      usdbrl: json['USDBRL']['bid'],
      varusd: json['USDBRL']['varBid'],
      eurbrl: json['EURBRL']['bid'],
      vareur: json['EURBRL']['varBid'],
      btcbrl: json['BTCBRL']['bid'],
      varbtc: json['BTCBRL']['varBid'],
    );
  }
}
