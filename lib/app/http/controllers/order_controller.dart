import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:stripe/stripe.dart';
import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/models/order.dart';
import 'package:vania_furniture_api/app/models/order_detail.dart';
import 'package:vania_furniture_api/app/models/product_bin.dart';

class OrderController extends Controller {
  placeOrder(Request request) async {
    try {
      final userId = Auth().id();

      //json format data "id":1, "address":"shanghai"
      final data = request.input("order");
   
      if (data == null) {
        return Response.json(
            {"code": 401, "data": "", "msg": "You are not authorized"}, 401);
      }
           
      //Map format data id:1, address:shanghai
     // final cartList = jsonDecode(data);
      final cartList = data;
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
                unitAmount: priceInt),
            quantity: element.cartNumber));

        await OrderDetail().query().insert({
          "user_id": userId,
          "amount": amountSum,
          "order_num": orderNum,
          "product_id": element.id,
          "title": element.title,
          "num": element.cartNumber,
          "price": element.price,
          "pic": element.thumbnail,
          "created_at": DateTime.now(),
          "updated_at": DateTime.now()
        });

         
      }

      await Order().query().insert({
        "user_id": userId,
        "amount_total": amountTotal.toStringAsFixed(2),
        "order_num": orderNum,
        "created_at": DateTime.now(),
        "updated_at": DateTime.now()
      });

      final stripe = Stripe(
          "sk_test_51NDjUSDcNOyMHK5HXM82Vp9SmGNrUbu4wTpn4KsvytjoVxnJXo6243K262SqdHHypMIloirm1xSVEnqW0edTSH1N00h9q3RWf3");
      final checkoutData = CreateCheckoutSessionRequest(
          successUrl: env('APP_URL') + '/success.html',
          cancelUrl: env('APP_URL') + '/cancel.html',
          mode: SessionMode.payment,
          clientReferenceId: "${orderNum}",
          paymentMethodTypes: [PaymentMethodType.card],
          lineItems: lineItems);
      final checkoutSession = await stripe.checkoutSession.create(checkoutData);
      
      return Response.json({
        "code":200,
        "data":checkoutSession.id,
        "msg":"Payment success"
      });

    } catch (e) {
      return Response.json({
        "code": 500,
        "data": "",
        "msg": e.toString()
      }, 500);
    }
  }
}

final OrderController orderController = OrderController();
