import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:stripe/stripe.dart';
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
      for (var element in cartList) {
        dataList.add(ProductBin.fromJson(element));
      }

      final orderNum = DateTime.now().millisecondsSinceEpoch;
      double amountTotal = 0;

      //get order info
      //get the amount
      //convert the amount to cents
      //LineItem refers to the order, number, amount.....
      List<LineItem> lineItems = [];

      for (var element in dataList) {
        //"12.303"-->12.303
        final price = Decimal.parse(element.price!);
        //12.30
        final priceDouble = price.floor(scale: 2).toDouble();

        //12.30*100=>1230
        int priceInt = (priceDouble * 100).toInt();

        //12.30*3
        final amountSum = priceDouble * element.cartNumber!;
        //add all the items in a loop
        amountTotal = amountTotal + amountSum;

        lineItems.add(LineItem(
            priceData: PriceData(
                currency: "usd",
                productData: ProductData(name: "${element.title}"),
                unitAmount: priceInt
                ),
                quantity:element.cartNumber
                ));
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
