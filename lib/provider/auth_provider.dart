import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rpl_b/ui/home/home_page.dart';
import 'package:rpl_b/utils/result_state.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String _message = '';

  ResultState _state = ResultState.initialState;

  ResultState get state => _state;

  String get message => _message;

  // * do login with email and password
  Future loginWithEmailPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _state = ResultState.hasData;
      notifyListeners();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login success: ${user.user!.email}'),
          backgroundColor: Colors.green,
        ),
      );
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, HomePage.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      _state = ResultState.error;
      _message = e.message!;
      notifyListeners();
      if (_message ==
          'The password is invalid or the user does not have a password.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password is invalid'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (_message ==
          'There is no user record corresponding to this identifier. The user may have been deleted.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email is invalid'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _state = ResultState.error;
      _message = e.toString();
      notifyListeners();
    }
  }
}
