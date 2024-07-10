import 'package:amplify/services/firebase_users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChangePasswordPage extends StatelessWidget {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final FirebaseUsers _firebaseUsers = FirebaseUsers(); // Instância da classe FirebaseUsers

  void _changePassword(BuildContext context) async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      print('As novas senhas não coincidem.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As novas senhas não coincidem.')),
      );
      return;
    }

    try {
      await _firebaseUsers.changePassword(FirebaseAuth.instance.currentUser!.uid, currentPassword, newPassword);
      print('Senha alterada com sucesso.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha alterada com sucesso.')),
      );
    } catch (e) {
      print('Erro ao alterar a senha: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar a senha: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alterar Senha'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Senha Atual',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey[400],
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nova Senha',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey[400],
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirmar Nova Senha',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey[400],
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _changePassword(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18,
                  ),
                ),
                child: Text('Alterar Senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
