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

let nb_s = 5;; (*on initialise 5 stratégies*)


(*========================================== DÉROULEMENT TOURNOI & PARTIES =======================================================*)

(*i:int renvoie ici si le joueur est le premier indice du tableau des scores ou non et cpt indique le coup joué sur 200*)
let joue_coup (p:plateau) (j:strat) (i:int) (cpt:int ref):coup =
    C;;

(*Charte des scores selon les coups donnés par les joueurs*)
let tuple_score (res:coup * coup) :int*int =
  match res with 
    (C, C) -> (3, 3) | (C, D) -> (0, 5)| (D, C) -> (5, 0) | (D, D) -> (2, 2);;

(*renvoie l'id associé à chaque strat*)
let strat_to_int (j:strat) :int = 
  match j with
    ALL_D -> 0 | RANDOM -> 1 | TIT_FOR_TAT -> 2 | TESTER -> 3 | JOSS -> 4;;

(*et inversement*)
let int_to_strat (i:int) :strat = 
  match i with
    0 -> ALL_D | 1 -> RANDOM | 2 -> TIT_FOR_TAT | 3 -> TESTER | _ -> JOSS;;

(*renvoie un string de chaque strat*)
let strat_to_string (j:strat) :string = 
  match j with
    ALL_D -> "ALL_D" | RANDOM -> "RANDOM" | TIT_FOR_TAT -> "TIT_FOR_TAT" | TESTER -> "TESTER" | JOSS -> "JOSS";;

(*Fonction qui régit le déroulement d'une manche entre 2 joueurs*)
let partie (p:plateau) (s:score) (j1:strat) (j2:strat) (s1:int ref) (s2:int ref) (cpt:int ref):unit = 
    let coup_J1 = joue_coup p j1 0 cpt in
    let coup_J2 = joue_coup p j2 1 cpt in
    let coups = (coup_J1, coup_J2) in
    let score_J1, score_J2 = tuple_score coups in 
    s1 := !s1 + score_J1; s2 := !s2 + score_J2;
    (*score.(strat_to_int j1) <- score.score.(strat_to_int j1);*)
    if !cpt = 200 then (
        print_string ("scores : \n" ^ (strat_to_string j1) ^ " : "); print_int score_J1;
        print_string ("\n" ^ (strat_to_string j2) ^ " : "); print_int score_J2; print_string "\n";
        if score_J1 > score_J2 then 
            (print_string ("Victoire de " ^(strat_to_string j1) ^ " sur " ^ (strat_to_string j2)^"\n");
          ) else (
              if score_J1 < score_J2 then 
            (print_string ("Victoire de " ^(strat_to_string j2) ^ " sur " ^ (strat_to_string j1)^"\n");
          ) else (
            print_string ("Égalité entre " ^(strat_to_string j2) ^ " et " ^ (strat_to_string j1)^"\n");
          )
          )
    ) else  p.(!cpt*2)<-coup_J1; p.(!cpt*2+1)<-coup_J2; cpt := !cpt+1;;
    

(*Lancement d'une partie entre 2 joueurs*)
let debut_partie (s:score) (j1:strat) (j2:strat) :unit = 
    let sc1 = ref 0 in 
    let sc2 = ref 0 in 
    let cpt= ref 0 in
    let p = Array.make 400 C in
    while !cpt < 200 do 
      partie p s j1 j2 sc1 sc2 cpt;
    done; 
    s.(strat_to_int j1)<- s.(strat_to_int j1) + !sc1;
    s.(strat_to_int j2)<- s.(strat_to_int j2) + !sc2;;
      

(*Lancement du tournoi qui va contenir toutes les parties entre chaque joueur*)
let tournoi () :unit = 
  let sco = Array.make nb_s 0 in (*on énumère tous les affrontements car le dénombrement est trop spécifique à généraliser*)
  (*avec ALL_D*)
  debut_partie sco ALL_D RANDOM;
  debut_partie sco ALL_D TIT_FOR_TAT;
  debut_partie sco ALL_D TESTER;
  debut_partie sco ALL_D JOSS;
  (*avec RANDOM*)
  debut_partie sco RANDOM TIT_FOR_TAT;
  debut_partie sco RANDOM TESTER;
  debut_partie sco RANDOM JOSS;
  (*Avec TIT_FOR_THAT*)
  debut_partie sco TIT_FOR_TAT TESTER;
  debut_partie sco TIT_FOR_TAT JOSS;
  (*avec TESTER*)
  debut_partie sco TESTER JOSS;
  print_string "RÉSULTATS :\n";
  for i=0 to 4 do
    print_string ("Le joueur avec la stratégie " ^ (strat_to_string (int_to_strat i))^" termine le tournoi avec un score de "); print_int sco.(i); print_string "!!\n";
  done;;


  tournoi ();;