import 'package:amplify/models/bankcard_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseCards{

  final CollectionReference cardsRef = FirebaseFirestore.instance.collection('Cards');

  Future<bool> cardExists(String cardUID) async {
    final DocumentSnapshot cardDoc = await cardsRef.doc(cardUID).get();
    return cardDoc.exists;
  }

  Future<bool> addCard({
    required String cardNum,
    required String ownerUID,
    required Map<String, dynamic> cardData,
  }) async {
    try {
      if(await cardExists(cardNum)){
        return false;
      }
      cardsRef.doc(cardNum).set(cardData);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future<bool> removeCard(String cardNum) async {
    try {
      cardsRef.doc(cardNum).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future <List<BankCardData>> getUserCards(String userUID) async {
    List<BankCardData> cards = [];
    QuerySnapshot querySnapshot = await cardsRef
        .where('ownerUID', isEqualTo: userUID)
        .get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      BankCardData card =
      BankCardData.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      cards.add(card);
    }
    return cards;
  }
}