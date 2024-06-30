import 'package:vania/vania.dart';

class CreateUserTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTable('users', () {
      id();
      char('name',length: 100);
      char('avatar', length: 100);
      char('password', length: 200);
      char('email', length: 191);
      char('phone', length: 150);
      longText('description');
      char('birthday', length: 200);
      mediumInt("gender");
      dateTime('created_at');
      dateTime('updated_at');
      dateTime('deleted');
    });
  }

    @override
  Future<void> down() async{
    super.down();
    await dropIfExists('users');
  }
}
