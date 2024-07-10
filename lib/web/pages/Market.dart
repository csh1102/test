import 'package:amplify/web/widgets/NavigationBarLogin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify/web/pages/MapPage.dart';
import 'package:amplify/services/helpers.dart'; // Importe o arquivo onde você implementa o _launchURL

class Market extends StatefulWidget {
  const Market({Key? key}) : super(key: key);

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  List<Item> items = [];
  List<Item> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  bool _isPopupVisible = false; // Estado para controlar a visibilidade do pop-up

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterItems);
    fetchItems();
  }

  @override
  void dispose() {
    searchController.removeListener(_filterItems);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchItems() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('Homes').get();

    setState(() {
      items = querySnapshot.docs.map((doc) {
        return Item(
          homeUID: doc.id, 
          homeLocation: doc['Address'] as GeoPoint,
          homeName: doc['HouseName'],
          homePrice: doc['Price'],
        );
      }).toList();
      filteredItems = items;
    });
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = items.where((item) {
        return item.homeUID.toLowerCase().contains(query);
      }).toList();
    });
  }
  
  void _showPopup(BuildContext context) {
    setState(() {
      _isPopupVisible = true;
    });

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
                onTap: () => _launchURL(), // Defina o método _launchURL para abrir o link para download do APK
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
                setState(() {
                  _isPopupVisible = false; // Feche o pop-up e altere o estado para false
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NavigationBarU(),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 500.0),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return ItemCard(
                    item: filteredItems[index],
                    onTapReserve: () {
                      _showPopup(context); // Passa a função _showPopup para o ItemCard
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
            label: Text('Show on Map'),
            icon: Icon(Icons.map),
          ),
        ),
      ),
    );
  }
}

class Item {
  final String homeUID;
  final String homeName;
  final double? homePrice;
  final GeoPoint homeLocation;  

  Item({
    required this.homeUID,
    required this.homeName,
    required this.homePrice,
    required this.homeLocation,
  });
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTapReserve; // Função callback para lidar com o clique em "Reservar"

  const ItemCard({Key? key, required this.item, required this.onTapReserve}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.homeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text('Price: \$${item.homePrice?.toStringAsFixed(2) ?? 'N/A'}'),
                const SizedBox(height: 8.0),
                Text('Address: (${item.homeLocation.latitude}, ${item.homeLocation.longitude})'),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTapReserve, // Chama onTapReserve ao pressionar o botão
                    child: Text('Reservar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _launchURL() async {
  const url = 'https://google.com'; // Insira o link para download do APK aqui
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launch(String url) async {
  // Placeholder implementation
  // Use the url_launcher package to launch the URL in your actual implementation
  print('Launching URL: $url');
}

Future<bool> canLaunch(String url) async {
  // Placeholder implementation
  // Use the url_launcher package to check URL capability in your actual implementation
  return true;
}
