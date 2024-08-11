import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/http/controllers/auth_controller.dart';
import 'package:vania_furniture_api/app/http/controllers/home_controller.dart';
import 'package:vania_furniture_api/app/http/controllers/order_controller.dart';
import 'package:vania_furniture_api/app/http/controllers/profile_controller.dart';
import 'package:vania_furniture_api/app/http/middleware/authenticate.dart';


class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');
    Router.post("/register", authController.register);
    Router.post("/login", authController.login);
    Router.put("/update_password", authController.updatePassword);
    Router.any("/webhook", orderController.webhook);

    Router.group((){
      //products
      Router.post('/get_products', homeController.productList);
      Router.post('/detail', homeController.detail);
      Router.post('/search', homeController.search);

      //wish list
      Router.post("/add_wishlist", profileController.addWishList);
      Router.post("/my_wishlist", profileController.myWishList);

      //payment section
      Router.post("place_order", orderController.placeOrder);
    }, middleware: [AuthenticateMiddleware()]);
    
  }
}
