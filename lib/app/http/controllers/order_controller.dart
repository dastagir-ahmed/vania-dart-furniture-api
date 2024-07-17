import 'dart:convert';

import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/product_bin.dart';

class OrderController extends Controller {
  placeOrder(Request request) {
    try {
      final userId = Auth().id();

      //json format data "id":1, "address":"shanghai"
      final data = request.input("order");



      if (data == null) {
        return Response.json(
            {"code": 401, "data": "", "msg": "You are not authorized"}, 401);
      }
            //Map format data id:1, address:shanghai
      final cartList = jsonDecode(data);

      var dataList = <ProductBin>[];
      for (var element in cartList){

        dataList.add(ProductBin.fromJson(element));
        
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
