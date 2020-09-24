import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//import 'package:newserverdemo/screens/home_screen.dart';
import './services/atclient_services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import './utils/at_conf.dart' as at_conf;
import './home.dart';

String atSign;

class LoginScreen extends StatefulWidget {
  static final String id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TODO: Instantiate variables
  bool showSpinner = false;
  TextEditingController _loginTextFieldController = TextEditingController();
  AtClientService _atClientService = AtClientService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ModalProgressHUD(
        // TODO: Assign boolean to inAsyncCall
        inAsyncCall: showSpinner,
        child: Center(
          child: ListView(
            children: <Widget>[
              Container(
                width: 500,
                height: 180,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.white,
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person_pin, size: 70),
                        title: Text(
                          'Log In',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                        subtitle: TextField(
                          decoration: InputDecoration(hintText: 'AtSign'),
                          //TODO: Assign to controller
                          controller: _loginTextFieldController,
                          onChanged: (value) {
                            atSign = value;
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: FlatButton(
                          child: Text('Login'),
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          // TODO: Assign function to onPressed
                          onPressed: _login,
                        ),
                      ),
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

  //TODO: Write _login method
  _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      showSpinner = true;
    });
    bool status = false;
    if (atSign != null) {
      String secretKey = at_conf.secretMap[atSign];
      await _atClientService.initClient(atSign, secret: secretKey);
      print(secretKey);
      await _atClientService.initAtClientAuth(atsign: atSign);
      String privateKey = await _atClientService.getPrivateKey(atSign);
      await _atClientService.initClient(atSign, privateKey: privateKey);
      if (privateKey == null) {
        status = await _atClientService.performAuth(atSign, secret: secretKey);
      }

      // if (status) {
      //   setState(() {
      //     showSpinner = false;
      //   });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    }
  }
}
