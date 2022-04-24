import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/randomWordsPage.dart';
import 'auth.dart';

class loginPage extends StatefulWidget {
  loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Wrapper(),
        ),
      );
    }

    return firebaseApp;
  }

  final _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;

  final _emailTextController = TextEditingController();

  final _passwordTextController = TextEditingController();

  final _passwordTextConrollerRegister = TextEditingController();

  final _focusEmail = FocusNode();

  final _focusPassword = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 650,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                          child: Column(
                            children: [
                              Text(
                                'Welcome to Startup Name Generator, please log in below',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children: [
                              TextFormField(controller: _emailTextController,
                                decoration: const InputDecoration(hintText: 'Enter Your Username/Email', labelText: 'Email',),
                              ),
                              TextFormField(controller: _passwordTextController, obscureText: true,
                                decoration: const InputDecoration(hintText: 'Enter Your Password', labelText: 'Password',),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: _isProcessing
                                      ? CircularProgressIndicator()
                                      : Column(
                                          children: [
                                            login(),
                                            register(),
                                            //SizedBox(width: 24.0),
                                          ],
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Row login() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () async {
              _focusEmail.unfocus();
              _focusPassword.unfocus();
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isProcessing = true;
                });
                User? user = await AuthRepository.instance().signIn(_emailTextController.text, _passwordTextController.text,);
                print(user);
                setState(() {
                  _isProcessing = false;
                });

                if (user != null) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Wrapper(),), (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There was an error logging into the app'),));
                }
              }
            },
            child: Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16),),
            style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple, fixedSize: Size(400, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
          ),
        ),
      ],
    );
  }

  Row register() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () async {
              _focusEmail.unfocus();
              _focusPassword.unfocus();
              if (_formKey.currentState!.validate()) {
                showModalBottomSheet<dynamic>(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 25),
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Please confirm your password below:"),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _passwordTextConrollerRegister,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Your Password',
                                    labelText: 'Password',
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    while (_passwordTextConrollerRegister.text != _passwordTextController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Password must match'),
                                      ));
                                    }
                                    await AuthRepository.instance().signUp(_emailTextController.text, _passwordTextController.text);
                                    print("Hi");
                                    User? user = await AuthRepository.instance().signIn(
                                      _emailTextController.text,
                                      _passwordTextController.text,
                                    );
                                    if (user != null) {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Wrapper(),), (route) => false);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There was an error logging into the app'),));
                                    }
                                  },
                                  child: Text.rich(TextSpan(text: "Confirm")))
                            ])),
                      );
                    });
              }
            },
            child: Text('New user? Click to sign up', style: TextStyle(color: Colors.white, fontSize: 16),),
            style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue, fixedSize: Size(400, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
          ),
        ),
      ],
    );
  }
}
