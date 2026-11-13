# Axelrod-s-first-tournament
Axelrod’s first tournament agent implementation in OCaml.


## Journal de bord du projet

### Départ

On choisit d’implémenter notre projet en OCaml : on esquisse nos premières structures et fonctions typées suivant l’idée de départ de direction d’implémentation ; on affinera avec les contraintes concrètes plus tard.


![Départ du projet](./imgs/depart.png)

On créait donc notre structure d'énumération OCaml pour un pattern matching efficace, et on créait des fonctions pour qu'elles soient transverses en terme de type (string, int).

![Système de manipulation de l'énumération OCaml](./imgs/enum_manip.png)

### Organisation du tournoi

On découpe le fonctionnement du tournoi en plusieurs sous parties :

- Une fonction ```partie``` qui se chargera d'éffectuer le déroulement d'une énonciation de coups entre 2 joueurs (=stratégies).

- Une fonction lancement de parties qui
