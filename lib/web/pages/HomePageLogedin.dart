import 'package:amplify/web/widgets/NavigationBarLogin.dart';
import 'package:flutter/material.dart';
 // Importe seu widget de barra de navegação corretamente

class HomePageLogedin extends StatelessWidget {
  const HomePageLogedin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: kToolbarHeight), // Espaço para a barra de navegação
                _buildSection(title: 'Inicio', height: 200),
                _buildSection(title: 'Install APK', height: 200),
                _buildSection(title: 'Our Team', height: 200),
                _buildMarketMapSection(context, height: 200),
                _buildSection(title: 'Be partner', height: 200),
                const FooterSection(),
                SizedBox(height: 20), // Espaço extra no final
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavigationBarU(), // Aqui é onde você coloca sua barra de navegação
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required double height}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMarketMapSection(BuildContext context, {required double height}) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: height,
        color: Colors.grey[200],
        child: Center(
          child: Text(
            'Market/Map',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Só está disponível na versão web.'),
              SizedBox(height: 10),
              Text('Click below to download the APK.'),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => _launchURL(),
                child: Text(
                  'download',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL() async {
    const url = 'https://your-download-link.com'; // Insira o link para download do APK aqui
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  canLaunch(String url) {}
  
  launch(String url) {}
}

class FooterSection extends StatelessWidget {
  const FooterSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amplify',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Install APK'),
                  Text('Our Team'),
                  Text('Politica de Privacidade'),
                  Text('Support'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siga-nos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 10),
                      Icon(Icons.facebook),
                      SizedBox(width: 10),
                      Icon(Icons.phone),
                      // Adicione outros ícones de mídia social aqui, se necessário
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Amplify & Co. © 2024',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
