import java.util.*;

public class Compilateur {
  private ArrayList<RegleGrammaire> regles;
  private HashMap<String, HashMap<String, Integer>> tableAnalyse;
  private ArrayList<String> pile;
  private ArrayList<String> entree;
  private int pointer;

  private final String[] TERMINAUX = {
    "debut", "fin", ";", "id", ":=", "+", "*", "(", ")", "nb", "$"
  };

  public Compilateur() {
    this.regles = new ArrayList<>();
    this.tableAnalyse = new HashMap<>();
    this.pile = new ArrayList<>();
    this.entree = new ArrayList<>();
    this.pointer = 0;

    initialiserGrammaire();
    construireTableAnalyse();
  }

  private void initialiserGrammaire() {
    regles.add(new RegleGrammaire(1, "P", "debut S fin"));
    regles.add(new RegleGrammaire(2, "S", "I R"));
    regles.add(new RegleGrammaire(3, "R", "; I R"));
    regles.add(new RegleGrammaire(4, "R", ""));
    regles.add(new RegleGrammaire(5, "I", "id := E"));
    regles.add(new RegleGrammaire(6, "I", ""));
    regles.add(new RegleGrammaire(7, "E", "T E'"));
    regles.add(new RegleGrammaire(8, "E'", "+ T E'"));
    regles.add(new RegleGrammaire(9, "E'", ""));
    regles.add(new RegleGrammaire(10, "T", "F T'"));
    regles.add(new RegleGrammaire(11, "T'", "* F T'"));
    regles.add(new RegleGrammaire(12, "T'", ""));
    regles.add(new RegleGrammaire(13, "F", "( E )"));
    regles.add(new RegleGrammaire(14, "F", "id"));
    regles.add(new RegleGrammaire(15, "F", "nb"));
  }

  private void construireTableAnalyse() {
    ajouterRegle("P", "debut", 1);
    ajouterRegle("S", "id", 2); ajouterRegle("S", ";", 2); ajouterRegle("S", "fin", 2);
    ajouterRegle("R", ";", 3); ajouterRegle("R", "fin", 4);
    ajouterRegle("I", "id", 5); ajouterRegle("I", ";", 6); ajouterRegle("I", "fin", 6);
    ajouterRegle("E", "(", 7); ajouterRegle("E", "id", 7); ajouterRegle("E", "nb", 7);
    ajouterRegle("E'", "+", 8); ajouterRegle("E'", ")", 9); ajouterRegle("E'", ";", 9); ajouterRegle("E'", "fin", 9);
    ajouterRegle("T", "(", 10); ajouterRegle("T", "id", 10); ajouterRegle("T", "nb", 10);
    ajouterRegle("T'", "*", 11); ajouterRegle("T'", "+", 12); ajouterRegle("T'", ")", 12);
    ajouterRegle("T'", ";", 12); ajouterRegle("T'", "fin", 12);
    ajouterRegle("F", "(", 13); ajouterRegle("F", "id", 14); ajouterRegle("F", "nb", 15);
  }

  private void ajouterRegle(String nonTerminal, String terminal, int numRegle) {
    tableAnalyse.computeIfAbsent(nonTerminal, k -> new HashMap<>()).put(terminal, numRegle);
  }

  public boolean estTerminal(String symbole) {
    return Arrays.asList(TERMINAUX).contains(symbole);
  }

  public ArrayList<String> getPile() { return new ArrayList<>(pile); }
  public ArrayList<String> getEntree() { return new ArrayList<>(entree); }
  public int getPointer() { return pointer; }

  public void chargerProgramme(ArrayList<String> tokens) {
    this.entree.clear();
    this.entree.addAll(tokens);
    this.entree.add("$");
    this.pointer = 0;
  }

  public void initialiserPile() {
    this.pile.clear();
    this.pile.add("$");
    this.pile.add("P");
  }

  public String analyserEtape() {
    if (pile.isEmpty()) return "FIN: Pile vide";

    String sommet = pile.remove(pile.size() - 1);
    String courant = pointer < entree.size() ? entree.get(pointer) : "$";

    if (estTerminal(sommet)) {
      if (sommet.equals(courant)) {
        pointer++;
        return "Terminal '" + sommet + "' reconnu";
      }
      return "ERREUR: Attendu '" + sommet + "' mais trouvé '" + courant + "'";
    }

    if (sommet.equals("$")) {
      return courant.equals("$") ? "ANALYSE RÉUSSIE" : "ERREUR: Fin attendue";
    }

    HashMap<String, Integer> regles = tableAnalyse.get(sommet);
    if (regles == null || !regles.containsKey(courant)) {
      return "ERREUR: Pas de règle pour " + sommet + " avec '" + courant + "'";
    }

    RegleGrammaire regle = this.regles.get(regles.get(courant) - 1);
    if (!regle.droite.isEmpty()) {
      String[] parties = regle.droite.split(" ");
      for (int i = parties.length - 1; i >= 0; i--) {
        if (!parties[i].isEmpty() && !parties[i].equals("ε")) {
          pile.add(parties[i]);
        }
      }
    }

    return "Règle " + regle.numero + ": " + regle.gauche + " → " +
           (regle.droite.isEmpty() ? "ε" : regle.droite);
  }
}
