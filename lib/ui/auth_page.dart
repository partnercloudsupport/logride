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

  Color _leftTextColor = Colors.white;
  Color _rightTextColor = Colors.black;

  Future<FirebaseUser> _handleSignIn() async {
    // TODO: THIS
    print("THOMAS FIX THIS NOW");
    FirebaseUser user =
        await _auth.signInWithEmailAndPassword(email: null, password: null);
    return user;
  }

  void forumSubmit(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
        _buildEmailField(controller: loginEmailController, node: loginEmailNode, next: loginPasswordNode),
        _buildPasswordField(
            controller: loginPasswordController,
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
        _buildUsernameField(controller: signUpUsernameController, node: signUpUsernameNode, next: signUpEmailNode),
        _buildEmailField(controller: signUpEmailController, node: signUpEmailNode, next: signUpPasswordNode),
        _buildPasswordField(
          controller: signUpPasswordController,
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
  Widget _buildUsernameField({TextEditingController controller, FocusNode node, FocusNode next}) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      focusNode: node,
      onSubmitted: (content) {node.unfocus(); FocusScope.of(context).requestFocus(next);},
      decoration: InputDecoration(
        border: InputBorder.none,
        icon: Icon(Icons.person),
        hintText: "Username",
      ),
    );
  }

  /// Returns an appropriately configured text field for emails
  Widget _buildEmailField(
      {TextEditingController controller, FocusNode node, FocusNode next}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      focusNode: node,
      onSubmitted: (content) {node.unfocus(); FocusScope.of(context).requestFocus(next);},
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: InputBorder.none,
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
          border: InputBorder.none,
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
