import 'package:http/http.dart' as http;

const String _FUNCTION_URL =
    "https://us-central1-logride-ff53e.cloudfunctions.net/checkIfNewUserName";

Future<bool> isNewUsername(String username) async {
  if (username == "" || username == null) return false;

  // For some reason they're using 'get' requests still 🎉🎉🎉
  http.Response response =
      await http.get(_FUNCTION_URL + "?userName=$username");

  print(response.body);
  if (response.body == "true") return true;
  return false;
}
