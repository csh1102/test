import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/web/pages/BalancePage.dart';
import 'package:amplify/web/pages/HomePageLogedout.dart';
import 'package:amplify/web/pages/MyCars.dart';
import 'package:amplify/web/pages/MyHomes.dart';
import 'package:amplify/web/pages/UserDataPage.dart';
import 'package:amplify/web/widgets/NavigationBarLogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_users.dart';
import 'MyCarbonPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double balance = 0.0;
  String email = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    User? usera = FirebaseAuth.instance.currentUser;
    if (usera != null) {
      UserData user = await FirebaseUsers().getUserData(usera.uid);
      setState(() {
        email = user.email;
        balance = user.balance;
      });
    }
  }

  Future<void> _logOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePageLogedout()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: NavigationBarU(),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        double boxWidth = (constraints.maxWidth > 1200)
                            ? (1200 - 3 * 10) /
                                4 // 3 espaçamentos para 4 caixas
                            : (constraints.maxWidth > 800)
                                ? (constraints.maxWidth - 2 * 10) /
                                    3 // 2 espaçamentos para 3 caixas
                                : (constraints.maxWidth > 600)
                                    ? (constraints.maxWidth - 1 * 10) /
                                        2 // 1 espaçamento para 2 caixas
                                    : constraints.maxWidth -
                                        16.0 * 2; // largura total menos padding

                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }

                        return Center(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Conta',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            email,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                    UserBalancePage()),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Balance',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              '\$$balance',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              'Click for more details',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    AccountCard(
                                      icon: Icons.person,
                                      title: 'Informações pessoais',
                                      subtitle:
                                          'Forneça informações pessoais e como podemos entrar em contacto consigo',
                                      color: Colors.white,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Userdatapage()),
                                        );
                                      },
                                    ),
                                    AccountCard(
                                      imageIcon: ImageIcon(
                                        AssetImage(
                                            '../../assets/images/CarbonFeet.png'),
                                        size: 24.0,
                                        color: Colors.black,
                                      ),
                                      title: 'Pegada Carbonica',
                                      subtitle:
                                          'Check how much carbon you are saved',
                                      color: Colors.white,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Mycarbonpage()),
                                        );
                                      },
                                    ),
                                    AccountCard(
                                      icon: Icons.house,
                                      title: 'Minhas Casas',
                                      subtitle:
                                          'Gerencie as suas reservas e propriedades',
                                      color: Colors.white,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyHomes()),
                                        );
                                      },
                                    ),
                                    AccountCard(
                                      icon: Icons.car_rental,
                                      title: 'Meus Carros',
                                      subtitle:
                                          'Gerencie os seus consumos e despesas elétricas',
                                      color: Colors.white,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyCars()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 50),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () => _logOut(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red, // Cor vermelha
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Menos arredondado
                                      ),
                                    ),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white, // Cor do texto
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final IconData? icon;
  final ImageIcon? imageIcon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const AccountCard({
    this.icon,
    this.imageIcon,
    required this.title,
    required this.subtitle,
    this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) Icon(icon, size: 40),
              if (imageIcon != null) imageIcon!,
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
