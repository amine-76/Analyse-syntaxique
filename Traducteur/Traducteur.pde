Compilateur compilateur;
String message = "";
boolean analyseTerminee = false;

void setup() {
  size(900, 600);
  textSize(16);
  compilateur = new Compilateur();

  String[] lignes = loadStrings("programme.txt");
  ArrayList<String> tokens = tokenizer(lignes);

  compilateur.chargerProgramme(tokens);
  compilateur.initialiserPile();
}

void draw() {
  background(255);

  fill(0);
  text("PILE :", 50, 40);
  for (int i = 0; i < compilateur.getPile().size(); i++) {
    text(compilateur.getPile().get(i), 50, 70 + i * 20);
  }

  text("ENTRÉE :", 250, 40);
  for (int i = 0; i < compilateur.getEntree().size(); i++) {
    if (i == compilateur.getPointer()) fill(255, 0, 0);
    else fill(0);
    text(compilateur.getEntree().get(i), 250, 70 + i * 20);
  }

  fill(0);
  text("MESSAGE :", 500, 40);
  text(message, 500, 70, 380, 300);

  fill(200);
  rect(650, 500, 200, 40);
  fill(0);
  text("ÉTAPE SUIVANTE", 675, 525);
}

void mousePressed() {
  if (mouseX >= 650 && mouseX <= 850 && mouseY >= 500 && mouseY <= 540 && !analyseTerminee) {
    message = compilateur.analyserEtape();
    if (message.contains("RÉUSSIE") || message.startsWith("ERREUR") || message.startsWith("FIN")) {
      analyseTerminee = true;
    }
  }
}

ArrayList<String> tokenizer(String[] lignes) {
  ArrayList<String> tokens = new ArrayList<String>();
  for (String ligne : lignes) {
    ligne = ligne.trim();
    if (ligne.isEmpty()) continue;
    String[] mots = ligne.split("\\s+");
    for (String mot : mots) {
      if (mot.equals("debut") || mot.equals("fin") || mot.equals(";") || mot.equals("+") ||
          mot.equals("*") || mot.equals("(") || mot.equals(")") || mot.equals(":=")) {
        tokens.add(mot);
      } else if (mot.matches("[0-9]+")) {
        tokens.add("nb");
      } else if (mot.matches("[a-zA-Z_][a-zA-Z0-9_]*")) {
        tokens.add("id");
      } else {
        println("⚠️ Token inconnu : " + mot);
      }
    }
  }
  return tokens;
}
