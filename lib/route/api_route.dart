import 'package:vania/vania.dart';
import 'package:vania_furniture_api/app/http/controllers/auth_controller.dart';


class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');
    Router.post("/register", authController.register);
    
  }
}
