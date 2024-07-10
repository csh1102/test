import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  final List<String> reservationKeys;

  ReservationPage({required this.reservationKeys});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas'),
        backgroundColor: Color.fromARGB(255, 158, 251, 77), // Verde
      ),
      body: Center(
        child: reservationKeys.isEmpty
            ? Text('Nenhuma reserva encontrada para exibir.')
            : ListView.builder(
                itemCount: reservationKeys.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Reserva ${index + 1}'),
                    subtitle: Text('Chave: ${reservationKeys[index]}'),
                  );
                },
              ),
      ),
    );
  }
}
