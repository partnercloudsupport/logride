import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/submit_button.dart';
import '../widgets/home_icon.dart';
import '../widgets/page_controller_slider_bar.dart';
import '../data/auth_manager.dart';
import '../data/contact_url_constants.dart';

class AuthPage extends StatefulWidget {
  AuthPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final Function onSignedIn;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
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
  bool _loginPasswordValid = true;
  bool _signUpUsernameValid = true;
  bool _signUpEmailValid = true;
  bool _signUpPasswordValid = true;

  bool _signUpError = false;
  bool _signInError = false;

  Color _leftTextColor = Colors.white;
  Color _rightTextColor = Colors.black;

  void _pageChanged(pageIndex) {
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
  }

  void _validationAlertDialog({String body}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Invalid Authentication"),
            content: Text(body),
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
  }

  Future<String> _handleSignIn(String email, String password) async {
    _signInError = false;

    return widget.auth.signIn(email, password).catchError((exception) {
      String displayMessage;
      _signInError = true;
      _loginEmailValid = _loginPasswordValid = true;
      switch (exception.code) {
        case "ERROR_INVALID_EMAIL":
          displayMessage = "Invalid Email. Check the formatting.";
          _loginEmailValid = false;
          break;
        case "ERROR_WRONG_PASSWORD":
          displayMessage = "Incorrect Password";
          _loginPasswordValid = false;
          break;
        case "ERROR_USER_NOT_FOUND":
          displayMessage = "There is no account associated with that email.";
          _loginEmailValid = false;
          break;
        case "ERROR_USER_DISABLED":
          displayMessage =
              "This account has been disabled by the LogRide Administration";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          displayMessage =
              "There have been too many attempts to sign in to this account. Please try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          // This really shouldn't happen, but just in case
          displayMessage = "Unable to log in at this time.";
          break;
        default:
          displayMessage = exception.message;
          break;
      }
      _validationAlertDialog(body: displayMessage);
      setState(() {});
      return;
    }).then((String createdUser) {
      print(_signInError
          ? "Error signing in user"
          : "Successfully singed in a user");
      if (_signInError) return null;
      return createdUser;
    });
  }

  Future<String> _handleSignUp(
      String username, String email, String password) async {
    _signUpError = false;
    return widget.auth
        .signUp(username, email, password)
        .catchError((exception) {
      String displayMessage;
      _signUpError = true;
      _signUpPasswordValid = _signUpEmailValid = _signUpUsernameValid = true;
      switch (exception.code) {
        case "ERROR_WEAK_PASSWORD":
          // Weak Password
          displayMessage =
              "Password is too weak. It must be six characters or longer.";
          _signUpPasswordValid = false;
          break;
        case "ERROR_INVALID_CREDENTIAL":
          // Email is malformed
          displayMessage = "Invalid Email Address. Check the formatting.";
          _signUpEmailValid = false;
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          // Email is already used
          displayMessage =
              "That email is already in use by a different account.";
          _signUpEmailValid = false;
          break;
        default:
          // Any other error
          displayMessage = exception.message;
          break;
      }
      _validationAlertDialog(body: displayMessage);
      setState(() {}); // Set the forms to be invalid
    }).then((String createdUser) {
      print(_signUpError
          ? "Error creating a new user"
          : "Creating a user successful");
      if (_signUpError) return null;

      // Sign up is done.
      return createdUser;
    });
  }

  void _resetPassword() async {
    String email = loginEmailController.text;
    _loginEmailValid = true;
    bool wasReset = true;
    if (email == "") {
      _validationAlertDialog(body: "Please enter your email");
      setState(() {
        _loginEmailValid = false;
      });
      return;
    }
    await widget.auth.resetPassword(email).catchError((exception) {
      String displayMessage;
      switch (exception.code) {
        case "ERROR_INVALID_EMAIL":
          displayMessage = "Invalid email. Please check the formatting.";
          _loginEmailValid = false;
          break;
        case "ERROR_USER_NOT_FOUND":
          displayMessage = "There is no account associated with that email.";
          break;
        default:
          displayMessage = exception.message;
      }
      setState(() {});
      _validationAlertDialog(body: displayMessage);
      wasReset = false;
    });
    if (wasReset) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Password Rest"),
              content: Text(
                  "An email has been sent with a link to reset your password."),
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
    }
  }

  void forumSubmit() {
    switch (currentPage) {
      case 0:
        String username = signUpUsernameController.text;
        String email = signUpEmailController.text;
        String password = signUpPasswordController.text;

        // We validate just to make sure they're full
        bool valid = true;
        _signUpUsernameValid = (username != "");
        _signUpEmailValid = (email != "");
        _signUpPasswordValid = (password != "");

        valid =
            (_signUpUsernameValid && _signUpEmailValid && _signUpPasswordValid);

        if (!valid) {
          _validationAlertDialog(
              body: "One or more required fields were empty.");
          setState(() {});
          return;
        }

        _handleSignUp(username, email, password).then((user) {
          print("Checking for user stuff");
          if (user == null) return;
          print("User data is good");
          // No errors in the process, we have a valid signed-in user
          widget.onSignedIn();
        });
        break;
      case 1:
        String email = loginEmailController.text;
        String password = loginPasswordController.text;

        // We validate just to make sure they're full
        bool valid = true;
        _loginEmailValid = (email != "");
        _loginPasswordValid = (password != "");

        valid = (_loginEmailValid && _loginPasswordValid);

        if (!valid) {
          _validationAlertDialog(
              body: "One or more required fields were empty");
          setState(() {});
          return;
        }

        _handleSignIn(email, password).then((user) {
          print("Checking for user stuff");
          if (user == null) return;
          print("User data is good");
          // No errors in the process, we have a valid signed-in user
          widget.onSignedIn();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: SafeArea(
                  minimum: EdgeInsets.all(8.0),
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
                                    onPageChanged: _pageChanged,
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
                              _buildInfoRow(context)
                            ],
                          )),
                    ),
                  ),
                )),
          ),
        ));
  }

  /// Returns the sliding menu bar that manages the page controller
  Widget _buildMenuBar(BuildContext context) {
    return PageControllerSliderBar(
      pageController: _pageController,
      height: 50,
      width: 275,
      leftText: "Sign Up",
      rightText: "Log In",
      leftTextColor: _leftTextColor,
      rightTextColor: _rightTextColor,
    );
  }

  /// Returns a column holding all the fields required of a log-in page
  Widget _buildLoginPage(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildEmailField(
            controller: loginEmailController,
            valid: _loginEmailValid,
            node: loginEmailNode,
            next: loginPasswordNode),
        _buildPasswordField(
          controller: loginPasswordController,
          valid: _loginPasswordValid,
          visibility: _obscureLoginText,
          visibilityTap: () {
            setState(() {
              _obscureLoginText = !_obscureLoginText;
            });
          },
          node: loginPasswordNode,
        ),
        FlatButton(
            onPressed: () => _resetPassword(),
            child: Text(
              "Forgot password?",
              textScaleFactor: 1.2,
            ))
      ],
    );
  }

  /// Returns a column holding all the fields that are used in a sign-up page
  Widget _buildSignUpPage(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildUsernameField(
            controller: signUpUsernameController,
            valid: _signUpUsernameValid,
            node: signUpUsernameNode,
            next: signUpEmailNode),
        _buildEmailField(
            controller: signUpEmailController,
            valid: _signUpEmailValid,
            node: signUpEmailNode,
            next: signUpPasswordNode),
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
        text: "Submit",
        onTap: () {
          forumSubmit();
        });
  }

  /// Returns the text entry field (with appropriate decor) for usernames
  Widget _buildUsernameField(
      {TextEditingController controller,
      bool valid,
      FocusNode node,
      FocusNode next}) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      focusNode: node,
      onSubmitted: (content) {
        node.unfocus();
        FocusScope.of(context).requestFocus(next);
      },
      decoration: InputDecoration(
        border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
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
      {TextEditingController controller,
      bool valid,
      FocusNode node,
      FocusNode next}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      focusNode: node,
      onSubmitted: (content) {
        node.unfocus();
        FocusScope.of(context).requestFocus(next);
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
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
      onSubmitted: (content) {
        forumSubmit();
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(width: 0.0, style: BorderStyle.none)),
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      print("Couldn't launch $url");
    }
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton(
          child: Text(
            "Privacy Policy",
            textScaleFactor: 1.1,
          ),
          onPressed: () => _launchURL(URL_PRIVACY),
        ),
        FlatButton(
          child: Text(
            "Terms of Service",
            textScaleFactor: 1.2,
          ),
          onPressed: () => _launchURL(URL_TOS),
        )
      ],
    );
  }
}
