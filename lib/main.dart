import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

// API URL
const url = "https://api.hgbrasil.com/finance?format=json&key=";

void main() async {
  runApp(MaterialApp(home: Home()));
}

// Getting currency data
Future<Map> _getData() async {
  http.Response response = await http.get(url);
  return json.decode(response.body)["results"]["currencies"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Text editing controllers
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  // Currency values
  double _dolarCurr;
  double _euroCurr;

  // Formatter
  final formatter = NumberFormat("#,##0.00", "pt-BR");

  // onChange method for Real text field
  void _realDidChange(String value) {
    if (value.isEmpty) {
      clearAllTextFields();
    }
    double real = double.parse(value.replaceAll(",", "."));
    double dolarValue = (real / _dolarCurr);
    double euroValue = (real / _euroCurr);
    dolarController.text = formatter.format(dolarValue);
    euroController.text = formatter.format(euroValue);
  }

  // onChange method for Dolar text field
  void _dolarDidChange(String value) {
    if (value.isEmpty) {
      clearAllTextFields();
    }
    double dolar = double.parse(value.replaceAll(",", "."));
    double realValue = (dolar * _dolarCurr);
    double euroValue = (dolar * _dolarCurr / _euroCurr);
    realController.text = formatter.format(realValue);
    euroController.text = formatter.format(euroValue);
  }

  // onChange method for Euro text field
  void _euroDidChange(String value) {
    if (value.isEmpty) {
      clearAllTextFields();
    }
    double euro = double.parse(value.replaceAll(",", "."));
    double realValue = (euro * _euroCurr);
    double dolarValue = (euro * _euroCurr / _dolarCurr);
    realController.text = formatter.format(realValue);
    dolarController.text = formatter.format(dolarValue);
  }

  // Clears all text fields
  void clearAllTextFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversor de moedas"),
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder<Map>(
          future: _getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(fontSize: 25.0),
                  ),
                );
                break;
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar os dados...",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  );
                } else {
                  _dolarCurr = snapshot.data["USD"]["buy"];
                  _euroCurr = snapshot.data["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                            "Preencha qualquer das moedas para efetuar a conversão:"),
                        Divider(),
                        buildTextField(
                            "Real", "R\$ ", realController, _realDidChange),
                        Divider(height: 5.0),
                        buildTextField(
                            "Dólar", "US\$ ", dolarController, _dolarDidChange),
                        Divider(height: 5.0),
                        buildTextField(
                            "Euro", "€ ", euroController, _euroDidChange),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

// Returns a text field
Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function completion) {
  return TextField(
      controller: controller,
      onChanged: completion,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
        BlacklistingTextInputFormatter.singleLineFormatter,
      ],
      decoration: InputDecoration(
          labelText: label, border: OutlineInputBorder(), prefixText: prefix));
}
