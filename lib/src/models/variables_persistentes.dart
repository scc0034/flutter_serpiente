class VariablesPersistentes {
  // Atributos del modelo
  int value;
  String nombre;
  DateTime createdTime;

  // Constructor
  VariablesPersistentes(this.value, this.nombre, this.createdTime);

  VariablesPersistentes.fromMap(Map<String, dynamic> map)
      : assert(map["value"] != null),
        assert(map["nombre"] != null),
        assert(map["createdTime"] != null),
        value = map["value"],
        nombre = map["nombre"],
        createdTime = map["createdTime"] is String
            ? DateTime.parse(map["createdTime"])
            : map["createdTime"];

  // Mapa de cada uno de los objetos de la clase
  Map<String, dynamic> toMap() {
    return {
      "value": this.value,
      "nombre": this.nombre,
      "createdTime": this.createdTime.toString(),
    };
  }
}
