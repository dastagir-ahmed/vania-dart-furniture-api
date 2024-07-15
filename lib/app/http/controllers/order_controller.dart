import 'dart:convert';

import 'package:vania/vania.dart';

class OrderController extends Controller {
  placeOrder(Request request) {
    try {
      final userId = Auth().id();

      //json format data "id":1, "address":"shanghai"
      final data = request.input("order");

      //Map format data id:1, address:shanghai
      final cartList = jsonDecode(data);
      
      if (data == null) {
        return Response.json(
            {"code": 401, "data": "", "msg": "You are not authorized"}, 401);
      }
    } catch (e) {
      return Response.json({
        "code": 500,
        "data": "",
        "msg": "Server side error during placing order"
      }, 500);
    }
  }
}

final OrderController orderController = OrderController();
