import 'package:amplify/mobile/pages/AddCardPage.dart';
import 'package:amplify/mobile/pages/changeCard.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:amplify/services/auth.dart';
import 'package:flutter/material.dart';

class addBalance extends StatefulWidget {
  @override
  _AddBalanceState createState() => _AddBalanceState();
}

class _AddBalanceState extends State<addBalance> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseUsers _firebaseUsers = FirebaseUsers();
  double _currentBalance = 0.0;
  String _userUID = '';

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  Future<void> _fetchUserBalance() async {
    _userUID = Auth().currentUserUID;
    double balance = await _firebaseUsers.getUserBalance(_userUID);
    setState(() {
      _currentBalance = balance;
    });
  }

  Future<void> _updateUserBalance(double amount) async {
    double newBalance = _currentBalance + amount;
    await _firebaseUsers.updateUserBalance(_userUID, newBalance);
    setState(() {
      _currentBalance = newBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carregar Saldo'),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                children: [
                  Text(
                    'Saldo atual',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$_currentBalance €',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de carregamento',
                  style: TextStyle(fontSize: 19),
                ),
                SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.credit_card),
                      SizedBox(width: 10),
                      Text('Cartão terminado em 1123'),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CardSelectionPage()),
                        );
                      },
                      child: Text('Alterar Cartão'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddCardPage()),
                        );
                      },
                      child: Text('Adicionar Cartão'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantia a adicionar',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Insira o valor',
                      ),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String value = _controller.text;
                if (value.isNotEmpty) {
                  double amountToAdd = double.parse(value);
                  _updateUserBalance(amountToAdd);
                  print('Valor inserido: $value');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
