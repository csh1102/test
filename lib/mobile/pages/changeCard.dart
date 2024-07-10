import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartões',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saldo Atual'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Saldo atual: XX.XX €'),
            Text('Método de carregamento'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardSelectionPage()),
                );
              },
              child: Text('Alterar Cartão'),
            ),
          ],
        ),
      ),
    );
  }
}

class CardSelectionPage extends StatelessWidget {
  final List<Map<String, String>> cards = [
    {'cardNumber': '**** **** **** 1234', 'expiryDate': '12/23'},
    {'cardNumber': '**** **** **** 5678', 'expiryDate': '11/24'},
    {'cardNumber': '**** **** **** 9012', 'expiryDate': '10/25'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Cartão'),
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.credit_card),
              title: Text(cards[index]['cardNumber']!),
              subtitle: Text('Válido até: ${cards[index]['expiryDate']}'),
              onTap: () {
                // Aqui você pode adicionar a lógica para selecionar o cartão
              },
            ),
          );
        },
      ),
    );
  }
}
