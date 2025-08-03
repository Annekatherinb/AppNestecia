import 'models/student.dart';

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;

  Session._internal();

  Estudiante? estudianteActual;
}

final session = Session();
