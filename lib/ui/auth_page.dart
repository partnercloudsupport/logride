import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/submit_button.dart';
import '../widgets/home_icon.dart';
import '../animations/auth_bubble_painter.dart';
import 'home.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController signUpUsernameController =
      TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();

  final FocusNode loginEmailNode = FocusNode();
  final FocusNode loginPasswordNode = FocusNode();

  final FocusNode signUpUsernameNode = FocusNode();
  final FocusNode signUpEmailNode = FocusNode();
  final FocusNode signUpPasswordNode = FocusNode();

  PageController _pageController = PageController();

  int currentPage = 0;

  bool _obscureLoginText = true;
  bool _obscureSignUpText = true;

  bool _loginEmailValid = true;
  bool _loginPaswordValid = true;
  bool _signUpUsernameValid = true;
  bool _signUpEmailValid = true;
  bool _signUpPasswordValid = true;

  Color _leftTextColor = Colors.white;
  Color _rightTextColor = Colors.black;

  Future<FirebaseUser> _handleSignIn(String email, String password) async {
    FirebaseUser user =
        await _auth.signInWithEmailAndPassword(email: email, password: password);

    if(await user.getIdToken() == null){
      print("error with login");
    }

    return user;
  }
  
  Future<FirebaseUser> _handleSignUp(String username, String email, String password) async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    return user;
  }

  void forumSubmit(){
    switch(currentPage){
      case 0:
        String username = signUpUsernameController.text;
        String email = signUpEmailController.text;
        String password = signUpPasswordController.text;

        // We validate just to make sure they're full
        bool valid = true;
        _signUpUsernameValid = (username != "");
        _signUpEmailValid = (email != "");
        _signUpPasswordValid = (password != "");

        valid = (_signUpUsernameValid && _signUpEmailValid && _signUpPasswordValid);

        if(!valid){
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text("Invalid Sign Up"),
              content: Text("One or more required fields were empty."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
          setState((){});
        }

        //_handleSignUp(username, email, password);
        break;
      case 1:
        String email = loginEmailController.text;
        String password = loginEmailController.text;

        // We validate just to make sure they're full
        bool valid = true;
        _signUpEmailValid = (email != "");
        _signUpPasswordValid = (password != "");

        valid = (_signUpEmailValid && _signUpPasswordValid);

        if(!valid){
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text("Invalid Sign Up"),
              content: Text("One or more required fields were empty."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
          setState((){});
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
          },
          child: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height >= 500.0
                    ? MediaQuery.of(context).size.height
                    : 500.0,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SafeArea(
                      child: Container(
                        child: Center(
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: HomeIconButton(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Welcome to LogRide",
                                      textScaleFactor: 2,
                                    ),
                                  ),
                                  _buildMenuBar(context),
                                  Container(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24.0, horizontal: 24.0),
                                      child: PageView(
                                        controller: _pageController,
                                        onPageChanged: (pageIndex) {
                                          // Change text label colors according to the page we're on
                                          if (pageIndex == 0) {
                                            setState(() {
                                              _leftTextColor = Colors.white;
                                              _rightTextColor = Colors.black;
                                              currentPage = pageIndex;
                                            });
                                          } else {
                                            setState(() {
                                              _leftTextColor = Colors.black;
                                              _rightTextColor = Colors.white;
                                              currentPage = pageIndex;
                                            });
                                          }
                                        },
                                        children: <Widget>[
                                          _buildSignUpPage(context),
                                          _buildLoginPage(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 25.0),
                                      child: _buildSubmitButton(currentPage)),
                                ],
                              )),
                        ),
                      ),
                    ))),
          ),
        ));
  }

  /// Returns the sliding menu bar that manages the page controller
  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 275.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 221, 222, 224),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.decelerate);
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: _leftTextColor, fontSize: 16.0),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController?.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.decelerate);
                },
                child: Text(
                  "Log In",
                  style: TextStyle(color: _rightTextColor, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a column holding all the fields required of a log-in page
  Widget _buildLoginPage(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildEmailField(controller: loginEmailController, valid: _loginEmailValid, node: loginEmailNode, next: loginPasswordNode),
        _buildPasswordField(
            controller: loginPasswordController,
            valid: _loginPaswordValid,
            visibility: _obscureLoginText,
            visibilityTap: () {
              setState(() {
                _obscureLoginText = !_obscureLoginText;
              });
            },
            node: loginPasswordNode,
        ),
      ],
    );
  }

  /// Returns a column holding all the fields that are used in a sign-up page
  Widget _buildSignUpPage(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildUsernameField(controller: signUpUsernameController, valid: _signUpUsernameValid, node: signUpUsernameNode, next: signUpEmailNode),
        _buildEmailField(controller: signUpEmailController, valid: _signUpEmailValid, node: signUpEmailNode, next: signUpPasswordNode),
        _buildPasswordField(
          controller: signUpPasswordController,
          valid: _signUpPasswordValid,
          visibility: _obscureSignUpText,
          visibilityTap: () {
            setState(() {
              _obscureSignUpText = !_obscureSignUpText;
            });
          },
          node: signUpPasswordNode,
        ),
      ],
    );
  }

  // I may remove this
  Widget _buildSubmitButton(num pageIndex) {
    return SubmitButton(
        text: "Submit", onTap: () {forumSubmit();});
  }


  /// Returns the text entry field (with appropriate decor) for usernames
  Widget _buildUsernameField({TextEditingController controller, bool valid, FocusNode node, FocusNode next}) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      focusNode: node,
      onSubmitted: (content) {node.unfocus(); FocusScope.of(context).requestFocus(next);},
      decoration: InputDecoration(
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
        fillColor: Colors.red[300],
        filled: !valid,
        contentPadding: EdgeInsets.all(8.0),
        icon: Icon(Icons.person),
        hintText: "Username",
      ),
    );
  }

  /// Returns an appropriately configured text field for emails
  Widget _buildEmailField(
      {TextEditingController controller, bool valid, FocusNode node, FocusNode next}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      focusNode: node,
      onSubmitted: (content) {node.unfocus(); FocusScope.of(context).requestFocus(next);},
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
        fillColor: Colors.red[300],
        filled: !valid,
        contentPadding: EdgeInsets.all(8.0),
        icon: Icon(Icons.mail),
        hintText: "Email Address",
      ),
    );
  }

  /// Returns a text-field properly configured for passwords. Requires both a
  /// boolean for the visibility of the password and a function that toggles said
  /// visibility when the eye icon is tapped
  Widget _buildPasswordField(
      {TextEditingController controller,
        bool valid,
      bool visibility,
      Function visibilityTap,
      FocusNode node}) {
    return TextField(
      controller: controller,
      obscureText: visibility,
      focusNode: node,
      onSubmitted: (content) {forumSubmit();},
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          border: UnderlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
          fillColor: Colors.red[300],
          filled: !valid,
          contentPadding: EdgeInsets.all(8.0),
          icon: Icon(Icons.lock),
          hintText: "Password",
          suffixIcon: GestureDetector(
            child: Icon(visibility ? Icons.visibility : Icons.visibility_off),
            // Toggle visibility of password on tap
            onTap: visibilityTap,
          )),
    );
  }

}
