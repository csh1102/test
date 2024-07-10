import 'package:amplify/services/auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'Português';

  void _toggleDarkMode(bool darkMode) {
    if (darkMode) {
      // Muda para o tema escuro
      ThemeData darkTheme = ThemeData.dark();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyApp(theme: darkTheme),
        ),
      );
    } else {
      // Muda para o tema claro
      ThemeData lightTheme = ThemeData.light();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyApp(theme: lightTheme),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Modo Escuro'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
                _toggleDarkMode(_darkMode);
              });
            },
            secondary: Icon(Icons.brightness_6),
          ),
          SwitchListTile(
            title: Text('Notificações'),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
            },
            secondary: Icon(Icons.notifications),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Linguagem'),
            subtitle: Text('Selecionar a linguagem'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: <String>['Português', 'Inglês', 'Espanhol', 'Francês']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Sair'),
            onTap: () {
              // showAboutDialog(
              //   context: context,
              //   applicationName: 'Nome do Aplicativo',
              //   applicationVersion: '1.0.0',
              //   applicationLegalese: '© 2024 Nome da Empresa',
              //   children: <Widget>[
              //     Text('Este é um exemplo de um aplicativo Flutter.'),
              //   ],
              // );
              Auth().signOut();
            },
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final ThemeData theme;

  MyApp({required this.theme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: SettingsPage(),
    );
  }
}
