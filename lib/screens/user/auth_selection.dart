import 'package:smart_fintrack/screens/user/sign_in.dart';
import 'package:smart_fintrack/screens/user/sign_up.dart';
import 'package:flutter/material.dart';

class AuthSelection extends StatelessWidget {
  const AuthSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 239, 231),
      body: SafeArea(  // Wrap the body with SafeArea
        child: Stack(
          children: [
            SingleChildScrollView(  // Make the content scrollable
              child: Center(  // Center the content inside SingleChildScrollView
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/logo.png',
                        height: 100,
                      ),
                      Image.asset(
                        'assets/finTrack.png',
                        height: 40,
                      ),
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 25),
                        padding: EdgeInsets.fromLTRB(20, 40, 20, 30),
                        child: Column(
                          children: [
                            Text(
                              'Welcome to finTrack.\nManage money wisely for a secure future.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,          
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: 310,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 241, 239, 231),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => SignIn())
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 310,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 241, 239, 231),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => SignUp())
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            //Text('----------------- OR -----------------'),
                          ],
                        ),
                      ),                     
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
