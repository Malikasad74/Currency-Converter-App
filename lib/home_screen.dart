import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = "USD";
  String toCurrency = "EUR";
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  // Get available currencies from API
  Future<void> _getCurrencies() async {
    var response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
        rate = data['rates'][toCurrency];
      });
    }
  }

  // Fetch conversion rate
  Future<void> _getRate() async {
    var response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        rate = data['rates'][toCurrency];
      });
    }
  }

  // Swap source and target currencies
  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _getRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Currency Converter"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(40),
                child: Image.asset(
                  'images/currency_bg.png',
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                  onChanged: (value) {
                    if (value != '') {
                      setState(() {
                        double amount = double.parse(value);
                        total = amount * rate;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: fromCurrency,
                          isExpanded: true,
                          style: TextStyle(color: Colors.white),
                          dropdownColor: Color(0xFF1d2630),
                          items: currencies.isNotEmpty
                              ? currencies.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem(
                                    value: fromCurrency,
                                    child: Text(fromCurrency),
                                  ),
                                ],
                          onChanged: (newValue) {
                            setState(() {
                              fromCurrency = newValue!;
                              _getRate();
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _swapCurrencies,
                      icon: Icon(
                        Icons.swap_horiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: toCurrency,
                          isExpanded: true,
                          style: TextStyle(color: Colors.white),
                          dropdownColor: Color(0xFF1d2630),
                          items: currencies.isNotEmpty
                              ? currencies.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem(
                                    value: toCurrency,
                                    child: Text(toCurrency),
                                  ),
                                ],
                          onChanged: (newValue) {
                            setState(() {
                              toCurrency = newValue!;
                              _getRate();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Rate $rate",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${total.toStringAsFixed(3)}',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
