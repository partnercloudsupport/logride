import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:log_ride/data/account_deleter.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/ui/dialogs/single_value_dialog.dart';
import 'package:log_ride/widgets/settings/account_tile.dart';
import 'package:log_ride/widgets/settings/settings_tile.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  AccountSettings(this.onSignedOut);

  final Function onSignedOut;

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  /// Provides a dialog to have the user sign-in with their password.
  /// Returns the FirebaseUser from the result. Null if error.
  Future<FirebaseUser> refreshSignIn(BaseAuth auth, LogRideUser user) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleValueDialog(
            title: "Verify Password",
            submitText: "Submit",
            type: SingleValueDialogType.PASSWORD,
          );
        });
    if (result == null || result == "") return null;

    var authUser = await auth.getCurrentUser();

    AuthCredential creds = EmailAuthProvider.getCredential(
        email: user.email, password: result as String);

    var authUserResult;
    try {
      authUserResult = await authUser.reauthenticateWithCredential(creds);
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_CREDENTIAL":
          print(
              "I'm not really sure what happened, but we've got an invalid credential");
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentication Error",
                    body: "An error occured",
                    actionText: "Ok",
                  ));
          return null;
        case "ERROR_USER_DISABLED":
          print("User's account was disabled");
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentication Error",
                    body: "Your account is disabled. Please contact LogRide",
                    actionText: "Ok",
                  ));
          return null;
        case "ERROR_USER_NOT_FOUND":
          print("User's account doesn't exist");
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentication Error",
                    body: "Account not found",
                    actionText: "Ok",
                  ));
          return null;
        case "ERROR_OPERATION_NOT_ALLOWED":
          print("Sign-in method disabled");
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentication Error",
                    body: "This method is disabled. Please contact LogRide",
                    actionText: "Ok",
                  ));
          return null;
        case "ERROR_WRONG_PASSWORD":
          print("User did words wrong");
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentication Error",
                    body: "Incorrect Password",
                    actionText: "Ok",
                  ));
          return null;
        default:
          showDialog(
              context: context,
              builder: (BuildContext context) => StyledDialog(
                    title: "Authentiaction Error",
                    body: "Unhandled error: ${e.code}",
                    actionText: "Ok",
                  ));
          return null;
      }
    }

    if (authUserResult != null) return authUserResult;

    return null;
  }

  void updateEmailTap(BaseAuth auth, LogRideUser user) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleValueDialog(
            title: "Change Email",
            hintText: "example@example.com",
            submitText: "Submit",
            type: SingleValueDialogType.TEXT,
            initialValue: user.email,
          );
        });
    if (result == null || result == "") return;
    updateEmail(auth, user, result as String);
  }

  /// Updates the user's email. If the user hasn't logged in recently, it'll sign them in with their password.
  void updateEmail(BaseAuth auth, LogRideUser user, String newEmail) async {
    FirebaseUser fbUser = await auth.getCurrentUser();
    print("Got current user");
    try {
      print("Attempting to update email");
      await fbUser.updateEmail(newEmail);
    } catch (exception) {
      print("Failed");
      print(exception);
      if (exception.code == "ERROR_REQUIRES_RECENT_LOGIN") {
        print("User needs to sign in again");
        FirebaseUser result = await refreshSignIn(auth, user);
        if (result != null) {
          result.updateEmail(newEmail);
        }
      }
      return;
    }
    // It succeeded!
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StyledDialog(
            title: "Success",
            body: "Your email was changed successfully.",
            actionText: "Ok",
          );
        });

    user.email = newEmail;
    setState(() {});
    return;
  }

  void updatePasswordTap(BaseAuth auth, LogRideUser user) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleValueDialog(
            title: "New Password",
            submitText: "Submit",
            type: SingleValueDialogType.PASSWORD,
          );
        });
    if (result == null || result == "") return;
    updatePassword(auth, user, result as String);
  }

  void updatePassword(BaseAuth auth, LogRideUser user, String newPass) async {
    FirebaseUser fbUser = await auth.getCurrentUser();
    print("Got current user");
    try {
      print("Attempting to update password");
      await fbUser.updatePassword(newPass);
    } catch (exception) {
      print("Failed");
      print(exception.code);
      if (exception.code == "ERROR_REQUIRES_RECENT_LOGIN") {
        print("User needs to sign in again");
        FirebaseUser result = await refreshSignIn(auth, user);
        if (result != null) {
          result.updatePassword(newPass);
        }
      } else if (exception.code == "ERROR_WEAK_PASSWORD") {
        print("User needs a stronger password");
        showDialog(
            context: context,
            builder: (BuildContext context) => StyledDialog(
                  title: "Authentication Error",
                  body:
                      "Password is too weak. It must be six characters or longer.",
                  actionText: "Ok",
                ));
        return;
      }
    }

    // It worked!
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StyledDialog(
            title: "Success",
            body: "Your password was changed successfully.",
            actionText: "Ok",
          );
        });
  }

  void signOut(BaseAuth auth, LogRideUser user) async {
    try {
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void deleteAccountConfirmation(
      BaseAuth auth, BaseDB db, LogRideUser user) async {
    // User must sign in first, regardless
    var refreshAuth = await refreshSignIn(auth, user);
    if (refreshAuth == null) return;

    // User then confirms that they want to delete their account
    var confirmation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StyledDialog(
            title: "Deletion Confirmation",
            body:
                "This action will permanantely delete your account. This cannot be undone. Are you sure you want to continue?",
            actionText: "Cancel",
            additionalAction: FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Continue")),
          );
        });

    if (confirmation == null) return;

    // Go through account deletion.
    await AccountDeleter.deleteAccount(auth, db, user);

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StyledDialog(
            title: "Account Deleted",
            body: "Thank you for using LogRide.",
            actionText: "Ok",
          );
        });

    // All firebase data is gone. Delete account and sign out.
    refreshAuth.delete();
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    LogRideUser user = Provider.of<LogRideUser>(context);

    BaseDB db = Provider.of<BaseDB>(context);
    BaseAuth auth = Provider.of<BaseAuth>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
      ),
      body: PreferencePage([
        // UserTile again (no arrow)
        AccountTile(),
        // Change Email button/field
        SettingsTile(
          title: "Change Email",
          subtitle: "Current Email: ${user.email}",
          onTap: () => updateEmailTap(auth, user),
        ),
        // Change password button/field
        SettingsTile(
          title: "Change Password",
          subtitle: "Change your password",
          onTap: () => updatePasswordTap(auth, user),
        ),
        SettingsTile(
          title: "Reset Password",
          subtitle:
              "Send an email to ${user.email} with instructions on how to reset your password",
          onTap: () async {
            await auth.resetPassword(user.email);
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StyledDialog(
                    title: "Email Sent",
                    body:
                        "An email with password reset instructions has been sent.",
                    actionText: "Ok",
                  );
                });
          },
        ),
        // Sign Out button
        SettingsTile(
          title: "Sign Out",
          subtitle: "Log Out of your account on this device",
          onTap: () => signOut(auth, user),
        ),
        // Delete Account button (in RED)
        SettingsTile(
          title: "Delete Account",
          subtitle: "Permanently delete your account. This CANNOT be undone.",
          decor: Colors.red,
          onTap: () => deleteAccountConfirmation(auth, db, user),
        )
      ]),
    );
  }
}
