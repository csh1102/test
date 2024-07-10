import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/NavigationBarLogin.dart';
import 'LoginPage.dart';

class UserBalancePage extends StatefulWidget {
  @override
  _UserBalancePageState createState() => _UserBalancePageState();
}

class _UserBalancePageState extends State<UserBalancePage> {
  double balance = 0.0;
  List<Map<String, dynamic>> transactionRecords = [];
  final TextEditingController rechargeController = TextEditingController();
  final TextEditingController withdrawController = TextEditingController();
  dynamic user = UserData(
    UID: 'a',
    email: 'a',
    hasSetupAccount: true,
    firstName: 'a',
    lastName: 'a',
    dateOfBirth: DateTime.now(), gender: 'a', 
  );

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadTransactions();
  }

  void _loadBalance() async {
    User? useri = FirebaseAuth.instance.currentUser;
    if (useri == null) {
      Future.delayed(
        Duration(seconds: 1),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
      );
      return;
    }
    dynamic temp = await FirebaseUsers().getUserData(useri.uid);
    double userBalance = await FirebaseUsers().getUserBalance(useri.uid) as double;

    setState(() {
      user = temp;
      balance = userBalance;
    });
  }

  void _loadTransactions() async {
    User? useri = FirebaseAuth.instance.currentUser;
    if (useri == null) return;

    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: useri.uid)
        .get();

    List<Map<String, dynamic>> transactions = transactionSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      transactionRecords = transactions;
    });
  }

  void _recharge() {
    double amount = double.tryParse(rechargeController.text) ?? 0;

    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    dynamic record = {
      'uid': uid,
      'type': 'Recharge',
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };
    if (amount > 0) {
      setState(() {
        balance += amount;
        transactionRecords.add(record);
        FirebaseUsers().updateUserBalance(uid, balance);
        FirebaseFirestore.instance.collection('transactions').add(record);
      });
      rechargeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount'),
        ),
      );
    }
  }

  void _withdraw() {
    double amount = double.tryParse(withdrawController.text) ?? 0;
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (amount > 0 && amount <= balance) {
      FirebaseUsers().updateUserBalance(uid, balance - amount);

      dynamic record = {
        'uid': uid,
        'type': 'Withdraw',
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
      };
      FirebaseFirestore.instance.collection('transactions').add(record);
      setState(() {
        balance -= amount;
        transactionRecords.add(record);
      });
      withdrawController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid amount'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: NavigationBarU(),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'User Balance',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<double>(
                  future: FirebaseUsers().getUserBalance(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No data available');
                    } else {
                      return Text(
                        'Balance: \$${snapshot.data!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: rechargeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Recharge Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _recharge,
                  child: Text('Recharge'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: withdrawController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Withdraw Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _withdraw,
                  child: Text('Withdraw'),
                ),
                SizedBox(height: 30),
                Text(
                  'Transaction Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .where('uid', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No transactions found');
                      } else {
                        transactionRecords = snapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();
                        return ListView.builder(
                          itemCount: transactionRecords.length,
                          itemBuilder: (context, index) {
                            final record = transactionRecords[index];
                            return ListTile(
                              title: Text(
                                  '${record['type']}: \$${record['amount']}'),
                              subtitle: Text('${record['date']}'),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
