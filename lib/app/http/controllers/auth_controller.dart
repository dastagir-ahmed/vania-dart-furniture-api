import 'dart:convert';
import 'package:vania/src/exception/validation_exception.dart';

import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/user.dart';

class AuthController extends Controller {
  Future<Response> register(Request request) async {
    try {
      request.validate({
        'name': 'required|string|alpha',
        'email': 'required|email',
        'password': 'required|string', // Add password validation
      }, {
        'name.required': 'Name is required',
        'name.string': 'Name must be a string',
        'name.alpha': 'Name must contain only alphabetic characters',
        'email.required': 'Email is required',
        'email.email': 'Invalid email format',
        'password.required':
        'Password is required', // Add password error messages
        'password.string': 'Password must be a string',
      });
    } catch (e) {
      if (e is ValidationException) {
        var errorMessages = e.message;
        var errorMessagesList = errorMessages.values.toList();
        return Response.json({
          "msg": errorMessagesList.isNotEmpty
              ? errorMessagesList[0]
              : "Validation error",
          "code": 401,
          "data": ""
        }, 401);
      } else {
        return Response.json(
            {"msg": "An unexpected server side error", "code": 500, "data": ""},
            500);
      }
    }

    try {
      final name = request.input('name');
      final email = request.input('email');
      var password = request.input('password');
      print("${name} ${email} ${password}");

      var user = await User().query().where('email', '=', email).first();

      if (user != null) {
        //user already exist
        return Response.json(
            {"msg": "Email already exist", "code": 409, "data": ""}, 409);
      }
      password = Hash().make(password);
      await User().query().insert({
        "name":name,
        "email":email,
        "password":password,
        "avatar":"images/01.png",
        "description":"No user content found",
        "created_at":DateTime.now(),
        "updated_at":DateTime.now()
      });
      return Response.json({
        "code":200,
        "msg":"Register success",
        "data":""
      },200);
    } catch (e) {
      return Response.json(
          {"msg": "An unexpected server side error during data insert", "code": 500, "data": ""},
          500);
    }
  }


  Future<Response> login(Request request) async {
    try {
      request.validate({ //void
        'email': 'required|email',
        'password': 'required|string', // Add password validation
      }, {

        'email.required': 'Email is required',
        'email.email': 'Invalid email format',
        'password.required':
        'Password is required', // Add password error messages
        'password.string': 'Password must be a string',
      });
    } catch (e) {
      
      if (e is ValidationException) {
        var errorMessages = e.message;
        var errorMessagesList = errorMessages.values.toList();
        return Response.json({
          "msg": errorMessagesList.isNotEmpty
              ? errorMessagesList[0]
              : "Validation error",
          "code": 401,
          "data": ""
        }, 401);
      } else {
        return Response.json(
            {"msg": "An unexpected server side error", "code": 500, "data": ""},
            500);
      }
    }
  
    try {
      final email = request.input('email');
      var password = request.input('password');
      print("${email} ${password}");

      var user = await User().query().where('email', '=', email).first();

      if (user == null) {
        //user already exist
        return Response.json(
            {"msg": "User not found", "code": 404, "data": ""}, 404);
      }

      if(!Hash().verify(password, user["password"])){
         return Response.json(
            {"msg": "Your email or password is wrong", "code": 401, "data": ""}, 401);
      }

      final auth =   Auth().login(user);
      print(auth);
      final token = await auth.createToken(expiresIn: Duration(days: 30));
      String accessToken = token["access_token"];
  user['access_token'] = accessToken;
      return Response.json({
        "code":200,
        "msg":"login success",
        "data":user
      },200);

    } catch (e) {

      print(e.toString());
      return Response.json(
          {"msg": "An unexpected server side error during login", "code": 500, "data": ""},
          500);
    }
  }

   Future<Response> updatePassword(Request request) async {
    print("hello");
    try {
      request.validate({
        'email': 'required|email',
        'password': 'required|string', // Add password validation
      }, {

        'email.required': 'Email is required',
        'email.email': 'Invalid email format',
        'password.required':
        'Password is required', // Add password error messages
        'password.string': 'Password must be a string',
      });
    } catch (e) {
      if (e is ValidationException) {
        var errorMessages = e.message;
        var errorMessagesList = errorMessages.values.toList();
        return Response.json({
          "msg": errorMessagesList.isNotEmpty
              ? errorMessagesList[0]
              : "Validation error",
          "code": 401,
          "data": ""
        }, 401);
      } else {
        return Response.json(
            {"msg": "An unexpected server side error", "code": 500, "data": ""},
            500);
      }
    }

    try {
      final email = request.input('email');
      var password = request.input('password');
      print("${email} ${password}");

      var user = await User().query().where('email', '=', email).first();

      if (user == null) {
        //user already exist
        return Response.json(
            {"msg": "User not found", "code": 404, "data": ""}, 404);
      }

     await User().query().where('email', '=', email).update({
      "password":Hash().make(password)
     });
 
      return Response.json({
        "code":200,
        "msg":"update success",
        "data":""
      },200);

    } catch (e) {

      print(e.toString());
      return Response.json(
          {"msg": "An unexpected server side error during login", "code": 500, "data": ""},
          500);
    }
  }
}




final AuthController authController = AuthController();
