import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryMonth = '';
  String _expiryYear = '';
  String _cvv = '';
  String _cardHolderName = '';

  List<String> _months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(16, (index) => (currentYear + index).toString().substring(2));
  }

  Future<void> _addCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário não autenticado')));
      return;
    }

    final uid = user.uid;

    try {
      // Verifica se já existe um cartão com o mesmo número
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Cards')
          .where('CardNumber', isEqualTo: _cardNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Já existe um cartão com este número')));
        return;
      }

      final cardData = {
        'CardHolder': _cardHolderName,
        'ExpirationDate': '$_expiryMonth/$_expiryYear',
        'CardNumber': _cardNumber,
        'CVV': _cvv,
      };

      await FirebaseFirestore.instance.collection('Users').doc(uid).collection('Cards').add(cardData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cartão Adicionado com Sucesso')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar cartão: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Cartão'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Número do Cartão'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número do cartão';
                  }
                  if (value.length != 16 || int.tryParse(value) == null) {
                    return 'O número do cartão deve ter exatamente 16 dígitos';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cardNumber = value ?? '';
                },
              ),
              SizedBox(height: 16),
              Text('Data de validade'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'MM'),
                      value: _expiryMonth.isNotEmpty ? _expiryMonth : null,
                      items: _months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _expiryMonth = newValue ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione o mês de expiração';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _expiryMonth = value ?? '';
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '/',
                      style: TextStyle(fontSize: 24.0), // Aumentar o tamanho da barra
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'YY'),
                      value: _expiryYear.isNotEmpty ? _expiryYear : null,
                      items: _years.map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _expiryYear = newValue ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione o ano de expiração';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _expiryYear = value ?? '';
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CVV';
                  }
                  if (value.length != 3 || int.tryParse(value) == null) {
                    return 'O CVV deve ter exatamente 3 dígitos';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cvv = value ?? '';
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Titular'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do titular';
                  }
                  if (value.contains(RegExp(r'[0-9]'))) {
                    return 'O nome do titular não pode conter números';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cardHolderName = value ?? '';
                },
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      _addCard();
                    }
                  },
                  child: Text('Adicionar Cartão'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
