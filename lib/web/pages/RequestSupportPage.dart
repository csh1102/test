import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../services/firebase_users.dart';
import '../widgets/NavigationBarLogin.dart';
import 'LoginPage.dart';

class RequestSupportPage extends StatefulWidget {
  @override
  _RequestSupportPageState createState() => _RequestSupportPageState();
}

class _RequestSupportPageState extends State<RequestSupportPage> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  List<dynamic> requests = [];
  Map<String, dynamic>? selectedRequest;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Usuário não autenticado. Will redirect to login page in 1 second.'),
        ));

        Future.delayed(
          Duration(seconds: 1),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
        );
        return;
    }
    List<dynamic> loadedRequests =
        await FirebaseUsers().getGivenHelpRequests(user.uid);
    setState(() {
      requests = loadedRequests;
    });
  }

  void requestWindow() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Submit a Request'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Problem'),
                    maxLines: 1,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a problem';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(labelText: 'Body'),
                    maxLines:
                        (MediaQuery.of(context).size.height * 0.01).ceil(),
                    maxLength: 5000,
                    // Allows multiline input
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a body';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text(
                    //       'Usuário não autenticado. Will redirect to login page in 1 second.'),
                    // ));

                    Future.delayed(
                      Duration(seconds: 1),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                    );
                    return;
                }
                  // Handle form submission
                  String uuid = Uuid().v4();
                  String userUID = FirebaseAuth.instance.currentUser!.uid;
                  String question = questionController.text;
                  String subject = subjectController.text;

                  bool result = await FirebaseUsers()
                      .askForHelp(uuid, userUID, question, subject);

                  if (result) {
                    print('Help request submitted successfully');
                    Navigator.of(context).pop(); // Close the dialog
                  } else {
                    print(
                        'Failed to submit help request, maybe reached the limit or server error');
                  }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: const NavigationBarU(),
      ),
      body: Row(
        children: [
          ElevatedButton(
            onPressed: requestWindow,
            child: const Text('Submit a Request'),
          ),
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
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Response : ',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text((selectedRequest?['response'] == ''
                                      ? 'Waiting Response'
                                      : '\n' + selectedRequest!['response'])),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
