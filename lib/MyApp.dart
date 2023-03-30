import 'dart:async';
import 'dart:convert';

import 'package:cotacao/dado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_decorated_text/flutter_decorated_text.dart';

TextField currencyTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.deny(',', replacementString: '.'),
        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})')),
      ],
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          prefix: Text(prefix)),
      keyboardType: TextInputType.number,
      onChanged: (value) => f(value));
}

Future<Dado> fetchDado() async {
  final response = await http.get(Uri.parse(
      "https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL"));

  if (response.statusCode == 200) {
    return Dado.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Falhou em ler o dado');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final realControlTextEd = TextEditingController();
  final dolarControlTextEd = TextEditingController();
  final euroControlTextEd = TextEditingController();
  final btcControlTextEd = TextEditingController();

  double dolar = 0;
  double varDolar = 0;
  double euro = 0;
  double varEuro = 0;
  double btc = 0;
  double varBtc = 0;

  late Future<Dado> dadoFuturo;

  @override
  void initState() {
    super.initState();
    dadoFuturo = fetchDado();
  }

  @override
  void dispose() {
    realControlTextEd.dispose();
    dolarControlTextEd.dispose();
    euroControlTextEd.dispose();
    btcControlTextEd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotação',
      theme: ThemeData(
          primarySwatch: Colors.purple, secondaryHeaderColor: Colors.amber),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Conversor de Moedas'),
          ),
          body: FutureBuilder<Dado>(
            future: dadoFuturo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                dolar = double.parse(snapshot.data!.usdbrl);
                varDolar = double.parse(snapshot.data!.varusd);
                euro = double.parse(snapshot.data!.eurbrl);
                varEuro = double.parse(snapshot.data!.vareur);
                btc = double.parse(snapshot.data!.btcbrl);
                varBtc = double.parse(snapshot.data!.varbtc);
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(Icons.monetization_on, size: 120),
                        currencyTextField(
                            'Real', 'R\$ ', realControlTextEd, _convertReal),
                        const SizedBox(height: 20),
                        currencyTextField('Dólar', 'US\$ ', dolarControlTextEd,
                            _convertDolar),
                        const SizedBox(height: 20),
                        currencyTextField(
                            'Euro', '€\$ ', euroControlTextEd, _convertEuro),
                        const SizedBox(height: 20),
                        currencyTextField(
                            'Bitcoin', 'BTC ', btcControlTextEd, _convertBtc),
                        const SizedBox(height: 20),
                        const Icon(Icons.stacked_line_chart_rounded, size: 120),
                        DecoratedText(
                          text:
                              "Dólar: $varDolar \n\nEuro: $varEuro \n\nBitcoin: $varBtc",
                          style: const TextStyle(fontSize: 24),
                          rules: [
                            DecoratorRule(
                              regExp: RegExp(
                                r'(.-.*)',
                              ),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.red),
                              leadingBuilder: (match) => const Icon(
                                  Icons.arrow_drop_down_sharp,
                                  size: 24,
                                  color: Colors.red),
                            ),
                            DecoratorRule(
                              regExp: RegExp(
                                r'(.[0-9].*)',
                              ),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.green),
                              leadingBuilder: (match) => const Icon(
                                  Icons.arrow_drop_up_sharp,
                                  size: 24,
                                  color: Colors.green),
                            )
                          ],
                        ),
                      ]),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          )),
    );
  }

  void _clearFields() {
    realControlTextEd.clear();
    dolarControlTextEd.clear();
    euroControlTextEd.clear();
    btcControlTextEd.clear();
  }

  void _convertReal(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double real = double.parse(text);
    dolarControlTextEd.text = (real / dolar).toStringAsFixed(2);
    euroControlTextEd.text = (real / euro).toStringAsFixed(2);
    btcControlTextEd.text = (real / btc).toStringAsFixed(2);
  }

  void _convertDolar(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double dolar = double.parse(text);
    realControlTextEd.text = (this.dolar * dolar).toStringAsFixed(2);
    euroControlTextEd.text = ((this.dolar * dolar) / euro).toStringAsFixed(2);
    btcControlTextEd.text = ((this.dolar * dolar) / btc).toStringAsFixed(2);
  }

  void _convertEuro(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double euro = double.parse(text);
    realControlTextEd.text = (this.euro * euro).toStringAsFixed(2);
    dolarControlTextEd.text = ((this.euro * euro) / dolar).toStringAsFixed(2);
    btcControlTextEd.text = ((this.euro * euro) / btc).toStringAsFixed(2);
  }

  void _convertBtc(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double btc = double.parse(text);
    realControlTextEd.text = (this.btc * btc).toStringAsFixed(2);
    dolarControlTextEd.text = ((this.btc * btc) / dolar).toStringAsFixed(2);
    euroControlTextEd.text = ((this.btc * btc) / euro).toStringAsFixed(2);
  }
}
