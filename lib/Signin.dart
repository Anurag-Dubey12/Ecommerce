import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_application/Homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Signin extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>UserAuth();
}
class UserAuth extends State<Signin>{
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  Future<void> _login() async{
    final response=await http.post(
      Uri.parse('https://fakestoreapi.com/auth/login'),
      body: {
        'username':_usernameController.text,
        'password':_passwordController.text
      }
    );
    if(response.statusCode==200){
      final data=jsonDecode(response.body);
      final token=data['token'];
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>Homescreen(token: token,)
          ));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Login', true);
      await prefs.setString('token', token);
      await _saveUserDetailsToFirestore(token);

    }else{
      setState(() {
        _errorMessage='Invalid Credential';
      });
    }
  }

  Future<void> _saveUserDetailsToFirestore(String token) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('EUsers').doc(token).set({
      'username': _usernameController.text,
      'token': token,
      'loginTime': DateTime.now(),
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Welcome Back User",style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10,),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter The Username',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(LineIcons.user, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter The Password',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login',
              style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                overlayColor: Colors.purple,
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}