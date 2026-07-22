class Book {
  final String title;
  final String author;
  final String summary;
  final String youtubeVideoId;
  final List<String> hangmanWords;
  final List<String> wordSearchWords;
  final List<QuizQuestion> quizQuestions;
  final List<MatchingItem> matchingItems;
  final String genre;
  final String year;
  final String imagePath;

  Book({
    required this.title,
    required this.author,
    required this.summary,
    required this.youtubeVideoId,
    required this.hangmanWords,
    required this.wordSearchWords,
    required this.quizQuestions,
    required this.matchingItems,
    required this.genre,
    required this.year,
    required this.imagePath,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

class MatchingItem {
  final String description; // Quote or character description
  final String match;       // Book or character name

  MatchingItem({
    required this.description,
    required this.match,
  });
}

final List<Book> booksData = [
  Book(
    title: "La Ilíada",
    author: "Homero",
    genre: "Epopeya Griega",
    year: "Siglo VIII a.C.",
    youtubeVideoId: "6j2POfkICx4",
    imagePath: "assets/images/iliada.png",
    summary: "La Ilíada narra los acontecimientos ocurridos durante 51 días en el último año de la Guerra de Troya. El tema central es la cólera de Aquiles, el héroe griego, desencadenada por la ofensa de Agamenón al arrebatarle a su esclava Briseida. Aquiles decide retirarse del combate, lo que provoca grandes pérdidas para los griegos ante el avance del príncipe troyano Héctor. La muerte de Patroclo, mejor amigo de Aquiles, hace que este regrese a la lucha para vengarlo, derrotando finalmente a Héctor y sellando el destino de Troya.",
    hangmanWords: ["AQUILES", "HECTOR", "TROYA", "PATROCLO", "AGAMENON", "PRIAMO", "HELENA"],
    wordSearchWords: ["AQUILES", "HECTOR", "TROYA", "GUERRA", "HOMERO", "GRECIA", "DIOSES"],
    quizQuestions: [
      QuizQuestion(
        question: "¿Cuál es el tema principal de La Ilíada?",
        options: ["El caballo de Troya", "La cólera de Aquiles", "El viaje de Ulises", "La muerte de Príamo"],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: "¿Quién mata a Patroclo, desatando el regreso de Aquiles?",
        options: ["Héctor", "París", "Príamo", "Eneas"],
        correctOptionIndex: 0,
      ),
      QuizQuestion(
        question: "¿Quién es el rey de Troya en la obra?",
        options: ["Agamenón", "Menelao", "Príamo", "Ulises"],
        correctOptionIndex: 2,
      ),
    ],
    matchingItems: [
      MatchingItem(description: "Héroe troyano, defensor de la ciudad y hermano de París.", match: "Héctor"),
      MatchingItem(description: "El de los pies ligeros, el guerrero más fuerte de los aqueos.", match: "Aquiles"),
      MatchingItem(description: "Su rapto desencadenó el asedio a Troya.", match: "Helena"),
    ],
  ),
  Book(
    title: "La Odisea",
    author: "Homero",
    genre: "Epopeya Griega",
    year: "Siglo VIII a.C.",
    youtubeVideoId: "TUVVooDPnW8",
    imagePath: "assets/images/odisea.png",
    summary: "La Odisea relata el accidentado viaje de retorno de Odiseo (Ulises), rey de Ítaca, a su hogar tras la caída de Troya. Durante diez años, Odiseo debe enfrentar monstruos míticos como el cíclope Polifemo, las sirenas y los monstruos marinos Escila y Caribdis, además de la furia del dios Poseidón. En Ítaca, su esposa Penélope y su hijo Telémaco sufren el acoso de decenas de pretendientes que buscan apoderarse del trono. Odiseo regresa disfrazado de mendigo para tramar su venganza y recuperar su hogar.",
    hangmanWords: ["ODISEO", "PENELOPE", "TELEMACO", "POLIFEMO", "ITACA", "CIRCE", "CALIPSO"],
    wordSearchWords: ["ODISEO", "PENELOPE", "ITACA", "CIRENE", "SIRENAS", "RETORNO", "VIAJE"],
    quizQuestions: [
      QuizQuestion(
        question: "¿Cuánto dura el viaje de retorno de Odiseo a Ítaca?",
        options: ["5 años", "10 años", "15 años", "20 años"],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: "¿Cómo se llama el cíclope que Odiseo ciega?",
        options: ["Polifemo", "Poseidón", "Telémaco", "Escila"],
        correctOptionIndex: 0,
      ),
      QuizQuestion(
        question: "¿Qué tejía y destejía Penélope para engañar a sus pretendientes?",
        options: ["Un tapiz", "Una corona", "Un sudario", "Un vestido"],
        correctOptionIndex: 2,
      ),
    ],
    matchingItems: [
      MatchingItem(description: "Rey de Ítaca, astuto creador del caballo de Troya.", match: "Odiseo"),
      MatchingItem(description: "Fiel esposa que espera tejiendo el regreso de su marido.", match: "Penélope"),
      MatchingItem(description: "Hijo de Odiseo que viaja en busca de noticias de su padre.", match: "Telémaco"),
    ],
  ),
  Book(
    title: "Las Cruces sobre el Agua",
    author: "Joaquín Gallegos Lara",
    genre: "Novela Social",
    year: "1946",
    youtubeVideoId: "ja5o067tBs4",
    imagePath: "assets/images/cruces.png",
    summary: "Las cruces sobre el agua es una novela ecuatoriana clásica que retrata la masacre obrera del 15 de noviembre de 1922 en Guayaquil. La historia sigue a Alfredo Baldeón y Alfonso Cortés, dos amigos con realidades distintas. Alfredo, de origen humilde, se une a la lucha obrera motivado por las terribles condiciones sociales. La represión brutal del gobierno termina en una masacre y los cadáveres de los huelguistas son arrojados al río Guayas. Desde entonces, el pueblo coloca cruces flotantes de caña para conmemorarlos.",
    hangmanWords: ["ALFREDO", "ALFONSO", "GUAYAQUIL", "MASACRE", "OBREROS", "BALDEON", "CRUCES"],
    wordSearchWords: ["ALFREDO", "ALFONSO", "GUAYAS", "CRUCES", "MASACRE", "NOVELA", "OBRERO"],
    quizQuestions: [
      QuizQuestion(
        question: "¿Qué acontecimiento histórico narra la novela?",
        options: ["La revolución alfarista", "La masacre obrera de 1922 en Guayaquil", "La independencia de Ecuador", "La huelga de los ferrocarriles"],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: "¿Quién es el protagonista de origen humilde que muere en el combate?",
        options: ["Alfonso Cortés", "Alfredo Baldeón", "Joaquín Lara", "Mano de Cabra"],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: "¿Qué significan las cruces en el río Guayas?",
        options: ["Accidentes de botes", "Tradición de pesca", "Tumbas de los obreros asesinados", "Señales de navegación"],
        correctOptionIndex: 2,
      ),
    ],
    matchingItems: [
      MatchingItem(description: "Joven panadero y combatiente ecuatoriano que lucha por los derechos obreros.", match: "Alfredo Baldeón"),
      MatchingItem(description: "Intelectual y amigo del protagonista que sobrevive y reflexiona sobre el sentido de la lucha.", match: "Alfonso Cortés"),
      MatchingItem(description: "Escenario principal donde ocurre la masacre y se arrojan los cuerpos.", match: "Río Guayas"),
    ],
  ),
  Book(
    title: "Cien Años de Soledad",
    author: "Gabriel García Márquez",
    genre: "Realismo Mágico",
    year: "1967",
    youtubeVideoId: "-mh6HZw0Zl0",
    imagePath: "assets/images/cien_anios.png",
    summary: "Esta obra maestra relata la historia de siete generaciones de la familia Buendía en el pueblo ficticio de Macondo, fundado por José Arcadio Buendía y Úrsula Iguarán. A través de la dinastía familiar, se cruzan la magia, las guerras civiles, la industrialización bananera, y una soledad profunda y trágica. El destino de la familia está predicho en unos pergaminos cifrados por el sabio gitano Melquíades, que solo son descifrados cuando el último Buendía es consumido por el viento.",
    hangmanWords: ["MACONDO", "BUENDIA", "URSULA", "AURELIANO", "MELQUIADES", "SOLEDAD", "ARCADIO"],
    wordSearchWords: ["MACONDO", "BUENDIA", "URSULA", "SOLEDAD", "MAGICO", "ESPEJOS", "GITANO"],
    quizQuestions: [
      QuizQuestion(
        question: "¿Quién es la matriarca que vive más de cien años regulando la casa Buendía?",
        options: ["Rebeca", "Amaranta", "Úrsula Iguarán", "Remedios la bella"],
        correctOptionIndex: 2,
      ),
      QuizQuestion(
        question: "¿Cómo se llama el pueblo fundado por José Arcadio Buendía?",
        options: ["Comala", "Macondo", "Luvina", "Sucre"],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: "¿Quién escribe los pergaminos con el destino final de la familia?",
        options: ["Pilar Ternera", "Aureliano Babilonia", "Melquíades", "José Arcadio"],
        correctOptionIndex: 2,
      ),
    ],
    matchingItems: [
      MatchingItem(description: "Coronel que promovió 32 guerras civiles y las perdió todas.", match: "Aureliano Buendía"),
      MatchingItem(description: "Sabio gitano que introduce los inventos del mundo en Macondo.", match: "Melquíades"),
      MatchingItem(description: "Ascendió en cuerpo y alma al cielo mientras doblaba sábanas.", match: "Remedios la Bella"),
    ],
  ),
  Book(
    title: "Eneida",
    author: "Virgilio",
    genre: "Epopeya Latina",
    year: "19 a.C.",
    youtubeVideoId: "kRyAvVRx2kg",
    imagePath: "assets/images/eneida.png",
    summary: "Escrita por encargo del emperador Augusto, la Eneida relata las aventuras del héroe troyano Eneas, quien sobrevive a la caída de Troya y viaja por el Mediterráneo buscando fundar una nueva patria en Italia (el origen del Imperio Romano). En su viaje, naufraga en Cartago, donde vive un trágico amor con la reina Dido. Tras descender al inframundo y recibir la profecía de la grandeza de Roma, llega al Lacio, donde debe entablar una guerra feroz contra Turno, rey de los rútulos, para asegurar el destino de su estirpe.",
    hangmanWords: ["ENEAS", "VIRGILIO", "DIDO", "TURNO", "LATINO", "ANCHISES", "ROMULO"],
    wordSearchWords: ["ENEAS", "VIRGILIO", "ROMA", "LATINO", "CARTAGO", "DIDO", "ITALIA"],
    quizQuestions: [
      QuizQuestion(
        question: "¿Quién es el autor de la Eneida?",
        options: ["Homero", "Ovidio", "Virgilio", "Horacio"],
        correctOptionIndex: 2,
      ),
      QuizQuestion(
        question: "¿Quién es la reina de Cartago que se enamora trágicamente de Eneas?",
        options: ["Dido", "Lavinia", "Creúsa", "Helena"],
        correctOptionIndex: 0,
      ),
      QuizQuestion(
        question: "¿A qué héroe debe enfrentar Eneas en el combate singular final?",
        options: ["Héctor", "Turno", "Aquiles", "Pallas"],
        correctOptionIndex: 1,
      ),
    ],
    matchingItems: [
      MatchingItem(description: "Héroe troyano hijo de la diosa Venus y fundador mítico de la estirpe romana.", match: "Eneas"),
      MatchingItem(description: "Reina fundadora de Cartago que se quita la vida cuando Eneas la abandona.", match: "Dido"),
      MatchingItem(description: "Poeta romano comisionado para escribir la epopeya nacional de Roma.", match: "Virgilio"),
    ],
  ),
];
