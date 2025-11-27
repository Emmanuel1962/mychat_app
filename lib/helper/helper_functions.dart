import 'package:shared_preferences/shared_preferences.dart';

class HelperFuctions {
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
// saving the shared preferences
  static Future<bool?> userLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userLoggedInKey,
        isUserLoggedIn); // first write the key and then write what you would want to pass into it
  }

  static Future<bool?> usernameLoggedInStatus(String username) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey,
        username); // first write the key and then write what you would want to pass into it
  }

  static Future<bool?> emailLoggedInStatus(String useremail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey,
        useremail); // first write the key and then write what you would want to pass into it
  }

  //getting the data from shared preferences
  static Future<bool?> getUserLoginStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getemailLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getusernameLoggedInKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
}
