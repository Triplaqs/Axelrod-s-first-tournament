# Axelrod-s-first-tournament
Axelrod’s first tournament agent implementation in OCaml.

The code with all the tournament can be compiled with ```ocamlc tournoi.ml -o ./out/lancer``` and launched with ```./out/lancer```

Then enter the numbers according to what tournament you want to run. All the information will be displayed in the terminal.

If you want to see the list of playable agents, here it is :

```
ALL_D : 0
RANDOM : 1 
TIT_FOR_TAT : 2
TESTER : 3
JOSS : 4 
UNDECIDED : 5
```

And here are the tournament features :

```
?  :  0
?  : 1
```

## Journal de bord du projet

### Prévisions

d'après le tableau des scores suivant :

![Tableau des scores donné](./imgs/tab_sco.png)

Si on joue D à un tour on a au pire 2, au mieux 5 ; donc 3.5 points de score de moyenne par tour (si dans un modèle de départ on considère qu'on a une chance sur deux que la personne en face joue C ou D).
Tandis que si on joue C, on a au mieux 3 et au pire 0, donc 1.5 points de moyenne par tour (toujours dans le même modèle).
Déjà jouer D semble très avantageux, on peut donc déceler une potentielle première place pour ```ALL_D```.

### Départ du projet

On choisit d’implémenter notre projet en OCaml : on esquisse nos premières structures et fonctions typées suivant notre idée de départ de direction d’implémentation ; on affinera avec les contraintes concrètes plus tard.

![Départ du projet](./imgs/depart.png)

On créait donc notre structure d'énumération **OCaml** pour un pattern matching efficace, et on créait des fonctions pour qu'elles soient transverses en terme de type (string, int).

![Système de manipulation de l'énumération OCaml](./imgs/enum_manip.png)

### Organisation du tournoi

On découpe le fonctionnement du tournoi en plusieurs sous-parties :

- Une fonction ```partie``` qui se chargera d'éffectuer le déroulement d'une énonciation de coups entre 2 joueurs (=stratégies).


- Une fonction ```debut_partie``` qui va préparer le terrain et les paramètres de ```partie``` en la lançant le nombre de fois nécessaires au tournoi (200 fois).


- Une fonction ```tournoi``` qui vient préparer les paramètres pour ```debut_partie``` et lancer les 10 affrontements dénombrés lors du tournoi (chaque IA affronte chaque IA sans s'affronter elle-même ; ainsi $nb_{affrontements} = \frac{5 \times 4}{2} = 10$)

- Une fonction ```joue_coup``` qui vient, avec l'information de la stratégie utilisée ainsi que l'historique des coups de la partie, calculer le coup qu'elle va jouer (et le renvoie au sein de ```partie```).

### Implémentation de chaque partie de l'organisation du tournoi

Concernant les 2 premières fonctions sur les parties ; voici l'implémentation proposée :

![Fonctions liées aux parties](./imgs/parties_fini.png)

À ce stade, ce n'est pas difficile : on manipule et on se repose sur des fonctions et bouts de code que l'on a pas encore implémenté et que l'on fera plus tard. Par exemple mon ```joue_coup``` renvoie pour l'instant toujours C (comme on peut le constater en bas de la première image de la partie Départ") et les paramètres seront définis plus tard.

Quant à la fonction tournoi (ci-dessous) on l'a achevée et après quelques petits problèmes (```Fatal error: exception Invalid_argument("index out of bounds")```) notre tournoi renvoie ses résultats !

![L'implémentation de tournoi fonctionne !](./imgs/tournoi.png)

Ici on constate que les scores sont tous identiques car nous n'avons toujours pas implémenté ```joue_coup``` : elle renvoie toujours C.

Implémentation des coups :

![Fonctions stratégies](./imgs/coups_param1.png)

![Fonctions stratégies bis](./imgs/coups_param2.png)

On a du rajouter la variable ```tester_state``` en paramètre dans les appels de fonciton en cascade afin de retenir l'état de la séquence CCD de la stratégie.


### Résultats, tests et cohérence

Voici 3 résultats obtenus à 3 lancers de programme différents ! Ils diffèrent à cause de la stratégie random, grossièrement le classement reste le même.


![Résultats 1](./imgs/res1.png)


![Réslutats 2](./imgs/res2.png)


![Résultats 3](./imgs/res3.png)

on regarde un échantillon du déroulé d'un tour d'un échange pour voir si on a une certaine cohérence globale :

![Introspection d'un tour](./imgs/inspection_coups.png)

Sans rentrer dans les détails des coups, j'ai voulu inspecter les 14 premiers coups dans 3 tournois représentatifs des 5 stratégies (= une stratégie apparait dans au moins l'un des 3 tournois). Et de cette manière j'ai réalisé que j'avais mal compris (et donc implémenté ```TESTER``` et ```JOSS```. Respectivement j'avais compris pour le premier qu'à chaque coup il devait regarder le coup précédent de l'autre et soit jouer comme ```TIT_FOR_THAT``` soit lancer une séquence de C,C,D et re-sonder juste après. Tandis que pour le deuxième j'avais compris qu'il devait immiter le coup précédent de son adversaire sauf une fois sur 10, dans quel cas il l'inversait (et non pas juste jouer D peu importe).

On rectifie donc ces erreurs puis on resonde les 14 premiers coups des 3 tournois qui couvrent nos 5 stratégies/joueurs :

*3 photos*

Désormais nos 5 stratégies semblent correctent, on décide de ré(analyser les résultats :

*3 photos*

Concernant les résultats, avec l'étude assez grossière de la situation faites dans la rubrique ```Prévisions```, on comprend pourquoi ```ALL_D``` est premier (et largement) ; en effet, comme dit précedemment : si l'on joue tout le temps D, on a au pire 2 points, au plus 5 points, on a donc en moyenne 3.5 points par tour. Tandis que si l'on joue systématiquement C, on a au pire 0 et au mieux 3, donc en moyenne 1.5 points par tour. On comprend alors l'hégémonie du D et donc du ```ALL_D```.

Dans les faits, si ```ALL_D``` joue avec lui même (ce qu'on a pas implémenté ici), il ferait $200 \times 2 = 400$ points lors de l'échange, et si (il existait) la stratégie ```ALL_C``` qui joue uniquement C, et que cette dernière jouait avec elle même, elle aurait $200 \times 3 = 6OO$ points lors de l'échange, soit 1.5 fois le score de ```ALL_D``` dans son tournoi contre lui même. Sauf que dans notre tournoi à nous, toutes les stratégies affrontent toutes les autres. Donc ```ALL_D``` devrait affronter ```ALL_C``` et là on aurait 1000 points pour ```ALL_D``` et 0 pour ```ALL_C``` transformant l'issu du tournoi de 400 à 600 en 1400 à toujours 600.

Malheureusement les règles du jeu vont favoriser la trahison quand celui en face essayent de coopérer. 

*stats*

### Nouvelles stratégies

### Nouvelles règles


