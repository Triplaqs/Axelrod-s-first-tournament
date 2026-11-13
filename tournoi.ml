open Random;;
open Sys;;
open Printf;;
open Array;;


(*============================================== PLATEAU TOURNOI ===================================================================*)

type coup = C | D;;
type plateau = coup array;; (*on implémentera par soucis de simplicité tab[2*k] = score J1 et tab[2*k+1 + 1] = score J2*)
type strat = ALL_D | RANDOM | TIT_FOR_TAT | TESTER | JOSS;; (*arbitrairement on définira dans cet ordre leurs indices ; 
respectivement : 0 | 1      |        2     |   3    |   4      *)
type score = int array;; (*score.(k) = score du joueur k*)


(*========================================== DÉROULEMENT TOURNOI & PARTIES =======================================================*)

(*i:int renvoie ici si le joueur est le premier indice du tableau des scores ou non*)
let joue_coup (p:plateau) (j:strat) (i:int) :coup =
    C;;

(*Charte des scores selon les coups donnés par les joueurs*)
let tuple_score (res:coup * coup) :int*int =
  match res with 
    (C, C) -> (3, 3) | (C, D) -> (0, 5)| (D, C) -> (5, 0) | (D, D) -> (2, 2);;

(*renvoie l'id associé à chaque strat*)
let strat_to_int (j:strat) :int = 
  match j with
    ALL_D -> 0 | RANDOM -> 1 | TIT_FOR_TAT -> 2 | TESTER -> 3 | JOSS -> 4;;

(*renvoie un string de chaque strat*)
let strat_to_int (j:strat) :string = 
  match j with
    ALL_D -> "ALL_D" | RANDOM -> "RANDOM" | TIT_FOR_TAT -> "TIT_FOR_THAT" | TESTER -> "TESTER" | JOSS -> "JOSS";;

(*Fonction qui régit le déroulement d'une manche entre 2 joueurs*)
let partie (p:plateau) (s:score) (j1:strat) (j2:strat) (s1:int) (s2:int) (cpt:int):unit = 
    let coup_J1 = joue_coup p j1 0 in
    let coup_J2 = joue_coup p j2 1 in
    let coups = (coup_J1, coup_J2) in
    let score_J1, score_J2 = tuple_score coups in 
    (*score.(strat_to_int j1) <- score.score.(strat_to_int j1);*)
    if cpt = 200 then (print_string "") 
      else  p.(cpt*2)<-coup_J1; p.(cpt*2+1)<-coup_J2; cpt = cpt+1; ()
    ;;

(*Lancement d'une partie entre 2 joueurs*)
let debut_partie (s:score) (j1:strat) (j2:strat) :unit = 
    let sc1 = 0 in 
    let sc2 = 0 in 
    let cpt=0 in
    ();;

(*Lancement du tournoi qui va contenir toutes les parties entre chaque joueur*)
let tournoi () :unit = 
    ();;

