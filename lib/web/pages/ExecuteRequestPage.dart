import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firebase_users.dart';
import '../widgets/NavigationBarLogin.dart';
import 'LoginPage.dart';

class ExecuteRequestPage extends StatefulWidget {
  const ExecuteRequestPage({Key? key}) : super(key: key);

  @override
  _ExecuteRequestPageState createState() => _ExecuteRequestPageState();
}

class _ExecuteRequestPageState extends State<ExecuteRequestPage> {
  List<dynamic> requests = [];
  Map<String, dynamic>? selectedRequest;
  TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid == null) {
        Future.delayed(
          Duration(seconds: 1),
              () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
        );
        return;
    }
    List<dynamic> loadedRequests = await FirebaseUsers().getAllHelpRequests(user!.uid);
    setState(() {
      requests = loadedRequests;
    });
  }
  @override
  Widget build(BuildContext context) {
    final TextEditingController responseController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),

      appBar: AppBar(
        title: const NavigationBarU(),
      ),
      body: Row(
        children: [
          // Left side: List of requests
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return ListTile(
                  title: Text(request['problem']),
                  subtitle: Text(request['timeStamp']),
                  onTap: () {
                    setState(() {
                      selectedRequest = request;
                    });
                  },
                );
              },
            ),
          ),

          // Right side: Problem details and response box
          Expanded(
            flex: 3,
            child: selectedRequest == null
                ? const Center(child: Text('Select a problem to view details'))
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedRequest!['problem'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Request id : ' + selectedRequest!['uuid'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(selectedRequest!['request']),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: responseController,
                    decoration: const InputDecoration(
                      labelText: 'Response',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle response submission
                      String respond = responseController.text;
                      selectedRequest!['response'] = respond;
                      FirebaseUsers().respond(selectedRequest!['uuid'], selectedRequest!);
                      },
                    child: const Text('Submit Response'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ExecuteRequestPage(),
  ));
}
