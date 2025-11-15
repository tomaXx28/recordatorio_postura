class PosturaItem {
  final String titulo;
  final String descripcion;

  PosturaItem({
    required this.titulo,
    required this.descripcion,
  });

  factory PosturaItem.fromJson(Map<String, dynamic> json) {
    return PosturaItem(
      titulo: json["titulo"] ?? "",
      descripcion: json["descripcion"] ?? "",
    );
  }
}
class ListaPosturas {
  static final items = <PosturaItem>[
    PosturaItem(
      titulo: "Espalda Recta",
      descripcion:
          "Mantén la espalda erguida y evita encorvarte. Asegúrate de que tu columna esté alineada.",
    ),
    PosturaItem(
      titulo: "Pies Apoyados",
      descripcion:
          "Coloca ambos pies completamente apoyados en el suelo para mejorar la estabilidad postural.",
    ),
    PosturaItem(
      titulo: "Cuello Alineado",
      descripcion:
          "Evita adelantar la cabeza. Mantén el cuello alineado con la columna y la mirada al frente.",
    ),
    PosturaItem(
      titulo: "Hombros Relajados",
      descripcion:
          "Baja los hombros y evita tensarlos. Manténlos alineados y en una posición neutral.",
    ),
    PosturaItem(
      titulo: "Pantalla a la Altura de tus Ojos",
      descripcion:
          "Ajusta tu pantalla para que la parte superior quede a la altura de tus ojos. Evita mirar hacia abajo.",
    ),
    PosturaItem(
      titulo: "Eje Neutro",
      descripcion:
          "Mantén el eje neutro de la columna, evitando arqueamientos excesivos hacia adelante o atrás.",
    ),
    PosturaItem(
      titulo: "Piernas en 90°",
      descripcion:
          "Mantén un ángulo de 90 grados en rodillas y caderas para mejorar la ergonomía al estar sentado.",
    ),
    PosturaItem(
      titulo: "Manos Relajadas",
      descripcion:
          "Evita tensar las manos o muñecas. Mantén una posición neutral al escribir o usar el celular.",
    ),
    PosturaItem(
      titulo: "Pausas Activas",
      descripcion:
          "Levántate y muévete durante 3–5 minutos cada cierto tiempo para reducir tensión muscular.",
    ),
    PosturaItem(
      titulo: "Mirada al Horizonte",
      descripcion:
          "Mantén la mirada hacia adelante, evitando bajar demasiado el mentón o inclinar la cabeza.",
    ),
    PosturaItem(
      titulo: "Respiración Diafragmática",
      descripcion:
          "Realiza respiraciones profundas usando el diafragma para liberar tensión corporal.",
    ),
    PosturaItem(
      titulo: "Apoyo Lumbar",
      descripcion:
          "Usa un cojín o respaldo para mantener la curvatura natural de la zona lumbar.",
    ),
    PosturaItem(
      titulo: "Rodillas al Nivel de las Caderas",
      descripcion:
          "Ajusta la altura de la silla para que las rodillas queden a la misma altura que las caderas.",
    ),
    PosturaItem(
      titulo: "Evitar Cruce de Piernas",
      descripcion:
          "Mantén ambas piernas paralelas para mejorar la circulación y la alineación corporal.",
    ),
    PosturaItem(
      titulo: "Relajar Mandíbula",
      descripcion:
          "Evita apretar los dientes. Mantén la mandíbula suelta para reducir tensión cervical.",
    ),
    PosturaItem(
      titulo: "Alineación de Caderas",
      descripcion:
          "Mantén las caderas niveladas y evita inclinar el cuerpo hacia un lado.",
    ),
    PosturaItem(
      titulo: "Movilidad de Hombros",
      descripcion:
          "Haz rotaciones lentas de hombros cada cierto tiempo para evitar rigidez.",
    ),
    PosturaItem(
      titulo: "Columna Neutra",
      descripcion:
          "Busca que la columna mantenga sus curvas naturales sin exagerarlas.",
    ),
    PosturaItem(
      titulo: "Evitar Joroba",
      descripcion:
          "No metas los hombros hacia adelante. Mantén el pecho abierto y el torso firme.",
    ),
    PosturaItem(
      titulo: "Control de Tensión",
      descripcion:
          "Identifica zonas tensas y libera presión moviendo suavemente el área afectada.",
    ),
    PosturaItem(
      titulo: "Descanso Visual",
      descripcion:
          "Cada 20 minutos, mira 20 segundos a un punto lejano para relajar tus ojos.",
    ),
    PosturaItem(
      titulo: "Higiene de Movilidad",
      descripcion:
          "Realiza pequeños movimientos articulares en cuello, muñecas y hombros cada día.",
    ),
    PosturaItem(
      titulo: "Estiramiento Suave",
      descripcion:
          "Haz estiramientos ligeros para mejorar la flexibilidad y reducir la tensión muscular.",
    ),
    PosturaItem(
      titulo: "Silla Bien Ajustada",
      descripcion:
          "Asegúrate de que tu silla tenga soporte adecuado y esté regulada a tu medida.",
    ),
  ];
}
