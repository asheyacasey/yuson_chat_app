import 'package:yuson_chat_app/src/controller/auth_controller.dart';
import 'package:yuson_chat_app/src/controller/navigation/navigation_service.dart';
import 'package:yuson_chat_app/src/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../service_locators.dart';

class AuthScreen extends StatefulWidget {
  static const String route = 'auth-screen';

  const AuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCon = TextEditingController(),
      _passCon = TextEditingController(),
      _pass2Con = TextEditingController(),
      _usernameCon = TextEditingController();
  final AuthController _authController = locator<AuthController>();

  String prompts = '';

  @override
  void initState() {
    _authController.addListener(handleLogin);
    super.initState();
  }

  handleLogin() {
    if (_authController.currentUser != null) {
      locator<NavigationService>().pushReplacementNamed(HomeScreen.route);
    }
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _passCon.dispose();
    _pass2Con.dispose();
    _usernameCon.dispose();
    _authController.removeListener(handleLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _authController,
        builder: (context, Widget? w) {
          ///shows a loading screen while initializing
          if (_authController.working) {
            return const Scaffold(
              body: Center(
                child: SizedBox(
                    width: 50, height: 50, child: CircularProgressIndicator()),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title:  Text('CHATSY',
                  style: GoogleFonts.koulen( textStyle: TextStyle (fontSize: 30)),
                ),
                // backgroundColor: const Color(0xFF303030),
                centerTitle: true,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/chatapp.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.lightBlueAccent,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Form(
                                  key: _formKey,
                                  onChanged: () {
                                    _formKey.currentState?.validate();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: DefaultTabController(
                                    length: 2,
                                    initialIndex: 0,
                                    child: Column(
                                      children: [
                                         TabBar(
                                             indicatorWeight: 8,
                                             tabs: [
                                          Tab(
                                            child: Text(
                                              'Log In',
                                              style: GoogleFonts.koulen( textStyle: TextStyle (fontSize: 23,), color: Colors.black,),
                                            ),
                                          ),
                                          Tab(
                                            child: Text(
                                              'Register',
                                                style: GoogleFonts.koulen( textStyle: TextStyle (fontSize: 23,), color: Colors.black,),
                                            ),
                                          )
                                        ]),
                                        Expanded(
                                          child: TabBarView(

                                            children: [
                                              ///login
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  Text(_authController
                                                      .error?.message ??
                                                      ''),
                                                  TextFormField(
                                                    decoration:
                                                    const InputDecoration(
                                                        hintText: 'Email'),
                                                    controller: _emailCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your email';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                    const InputDecoration(
                                                      hintText: 'Password',
                                                    ),
                                                    controller: _passCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (_formKey
                                                        .currentState
                                                        ?.validate() ??
                                                        false)
                                                        ? () {
                                                      _authController
                                                          .login(
                                                          _emailCon
                                                              .text
                                                              .trim(),
                                                          _passCon
                                                              .text
                                                              .trim());
                                                    }
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              20.0),
                                                        ),
                                                        fixedSize: const Size(240, 50),
                                                        primary: (_formKey
                                                            .currentState
                                                            ?.validate() ??
                                                            false)
                                                            ?  Colors.lightBlueAccent
                                                            : Colors.grey),
                                                    child: Text('Log In',
                                                      style: GoogleFonts.koulen( textStyle: TextStyle (fontSize: 20,),),
                                                    ),
                                                  )
                                                ],
                                              ),

                                              ///register
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  Text(_authController
                                                      .error?.message ??
                                                      ''),
                                                  TextFormField(
                                                    decoration:
                                                    const InputDecoration(
                                                        hintText: 'Email'),
                                                    controller: _emailCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your email';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                    const InputDecoration(
                                                      hintText: 'Password',
                                                    ),
                                                    controller: _passCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter your password';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    obscureText: true,
                                                    decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                      'Confirm Password',
                                                    ),
                                                    controller: _pass2Con,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please confirm your password';
                                                      } else if (_passCon
                                                          .text !=
                                                          _pass2Con.text) {
                                                        return 'Passwords do not match!';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                      'Enter username',
                                                    ),
                                                    controller: _usernameCon,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter username';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (_formKey
                                                        .currentState
                                                        ?.validate() ??
                                                        false)
                                                        ? () {
                                                      _authController.register(
                                                          email: _emailCon
                                                              .text
                                                              .trim(),
                                                          password:
                                                          _passCon
                                                              .text
                                                              .trim(),
                                                          username:
                                                          _usernameCon
                                                              .text
                                                              .trim());
                                                    }
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                             20.0),
                                                        ),
                                                        fixedSize: const Size(240, 50),
                                                        primary: (_formKey
                                                            .currentState
                                                            ?.validate() ??
                                                            false)
                                                            ?  Colors.lightBlueAccent
                                                            : Colors.grey),
                                                    child:
                                                    Text('Register',
                                                      style: GoogleFonts.koulen( textStyle: TextStyle (fontSize: 20,)),),

                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
