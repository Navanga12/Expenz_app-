import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenz/models/expence_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenceService {
  // Define the key for storing expenses in shared preferences
  static const String _expensesKey = 'expenses';

  // Check if Firebase is initialized
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  // Reference to Firestore expenses collection
  CollectionReference<Map<String, dynamic>>? get _firestoreCollection {
    if (_isFirebaseReady) {
      return FirebaseFirestore.instance.collection('expenses');
    }
    return null;
  }

  // Save the expense to Firebase and local storage
  Future<void> saveExpense(Expense expense, BuildContext context) async {
    try {
      // 1. Store in Cloud Firestore if Firebase is initialized
      if (_isFirebaseReady) {
        try {
          await _firestoreCollection!
              .doc(expense.id.toString())
              .set(expense.toJson());
        } catch (fbError) {
          debugPrint("Firestore save warning: $fbError");
        }
      }

      // 2. Always persist locally in SharedPreferences for offline reliability
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? existingExpenses = prefs.getStringList(_expensesKey);

      List<Expense> existingExpenseObjects = [];
      if (existingExpenses != null) {
        existingExpenseObjects = existingExpenses
            .map((e) => Expense.fromJson(json.decode(e)))
            .toList();
      }

      existingExpenseObjects.add(expense);

      List<String> updatedExpenses =
          existingExpenseObjects.map((e) => json.encode(e.toJson())).toList();

      await prefs.setStringList(_expensesKey, updatedExpenses);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("saveExpense error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  // Load the expenses from Firebase or local storage
  Future<List<Expense>> loadExpenses() async {
    // 1. Try to load from Firebase Cloud Firestore if initialized
    if (_isFirebaseReady) {
      try {
        final querySnapshot = await _firestoreCollection!
            .orderBy('date', descending: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final cloudExpenses = querySnapshot.docs
              .map((doc) => Expense.fromJson(doc.data()))
              .toList();

          // Sync cloud data back to local SharedPreferences cache
          final prefs = await SharedPreferences.getInstance();
          final stringList =
              cloudExpenses.map((e) => json.encode(e.toJson())).toList();
          await prefs.setStringList(_expensesKey, stringList);

          return cloudExpenses;
        }
      } catch (fbError) {
        debugPrint(
            "Firestore load warning, using local storage cache: $fbError");
      }
    }

    // 2. Fallback to local SharedPreferences cache
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? existingExpenses = prefs.getStringList(_expensesKey);

    List<Expense> loadedExpenses = [];
    if (existingExpenses != null) {
      loadedExpenses = existingExpenses
          .map((e) => Expense.fromJson(json.decode(e)))
          .toList();
    }

    return loadedExpenses;
  }

  // Delete the expense from Firebase and local storage by id
  Future<void> deleteExpense(int id, BuildContext context) async {
    try {
      // 1. Delete from Firestore if Firebase is initialized
      if (_isFirebaseReady) {
        try {
          await _firestoreCollection!.doc(id.toString()).delete();
        } catch (fbError) {
          debugPrint("Firestore delete warning: $fbError");
        }
      }

      // 2. Delete from local SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? existingExpenses = prefs.getStringList(_expensesKey);

      List<Expense> existingExpenseObjects = [];
      if (existingExpenses != null) {
        existingExpenseObjects = existingExpenses
            .map((e) => Expense.fromJson(json.decode(e)))
            .toList();
      }

      existingExpenseObjects.removeWhere((element) => element.id == id);

      List<String> updatedExpenses =
          existingExpenseObjects.map((e) => json.encode(e.toJson())).toList();

      await prefs.setStringList(_expensesKey, updatedExpenses);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("deleteExpense error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  // Update an existing expense in Firebase and local storage
  Future<void> updateExpense(
      Expense updatedExpense, BuildContext context) async {
    try {
      // 1. Update in Cloud Firestore if initialized
      if (_isFirebaseReady) {
        try {
          await _firestoreCollection!
              .doc(updatedExpense.id.toString())
              .set(updatedExpense.toJson(), SetOptions(merge: true));
        } catch (fbError) {
          debugPrint("Firestore update warning: $fbError");
        }
      }

      // 2. Update in local SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? existingExpenses = prefs.getStringList(_expensesKey);

      List<Expense> existingExpenseObjects = [];
      if (existingExpenses != null) {
        existingExpenseObjects = existingExpenses
            .map((e) => Expense.fromJson(json.decode(e)))
            .toList();
      }

      int index = existingExpenseObjects
          .indexWhere((element) => element.id == updatedExpense.id);

      if (index != -1) {
        existingExpenseObjects[index] = updatedExpense;

        List<String> updatedExpenses =
            existingExpenseObjects.map((e) => json.encode(e.toJson())).toList();

        await prefs.setStringList(_expensesKey, updatedExpenses);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("updateExpense error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  // Delete all expenses from Firebase and local storage
  Future<void> deleteAllExpenses(BuildContext context) async {
    try {
      if (_isFirebaseReady) {
        try {
          final snapshot = await _firestoreCollection!.get();
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }
        } catch (fbError) {
          debugPrint("Firestore deleteAll warning: $fbError");
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_expensesKey);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All expenses deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("deleteAllExpenses error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing expenses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
