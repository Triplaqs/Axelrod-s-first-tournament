open Random;;
open Sys;;
open Printf;;
open Array;;

(*============================================== PLATEAU TOURNOI ===================================================================*)

type coup = C | D;;
type plateau = coup array;; (*on implémentera par soucis de simplicité tab[2*k] = score J1 et tab[2*k + 1] = score J2*)
type strat = ALL_D | RANDOM | TIT_FOR_TAT | TESTER | JOSS | UNDECIDED | CHILD;; (*arbitrairement on définira dans cet ordre leurs indices ; 
respectivement : 0 | 1      |        2     |   3    |   4      *)
type score = int array;; (*score.(k) = score du joueur k*)

let nb_s = 7;; (*on initialise 5 stratégies + 2 nouvelles*)

(*============================================== PARAMÈTRAGE DES FONCTIONS DE TRANSFERT ===============================================================*)


(*renvoie l'id associé à chaque strat*)
let strat_to_int (j:strat) :int = 
  match j with
    ALL_D -> 0 | RANDOM -> 1 | TIT_FOR_TAT -> 2 | TESTER -> 3 | JOSS -> 4 | CHILD -> 5 | UNDECIDED -> 6;;

(*et inversement*)
let int_to_strat (i:int) :strat = 
  match i with
    0 -> ALL_D | 1 -> RANDOM | 2 -> TIT_FOR_TAT | 3 -> TESTER | 4 -> JOSS | 5 -> CHILD | 6 -> UNDECIDED | _ -> failwith "input insensé";;

(*renvoie un string de chaque strat*)
let strat_to_string (j:strat) :string = 
  match j with
    ALL_D -> "ALL_D" | RANDOM -> "RANDOM" | TIT_FOR_TAT -> "TIT_FOR_TAT" | TESTER -> "TESTER" | JOSS -> "JOSS" | CHILD -> "CHILD" | UNDECIDED -> "UNDECIDED";;


(*prend un int et renvoie un coup*)
let int_to_coup (i:int) :coup =
  match i with 
  | 0 -> C | 1 -> D | _ -> failwith "input insensé";;


(*Charte des scores selon les coups donnés par les joueurs*)
let tuple_score (res:coup * coup) :int*int =
  match res with 
    (C, C) -> (3, 3) | (C, D) -> (0, 5)| (D, C) -> (5, 0) | (D, D) -> (2, 2);;

(*============================================== PARAMÈTRAGE DES COUPS ===============================================================*)


(*AGENT RANDOM*)
let coup_random () :coup =
  let i = Random.int 2 in 
  int_to_coup i;;

(*AGENT TIT_FOR_TAT*)
let coup_TFT (p:plateau) (i:int) (cpt:int ref) :coup = 
  if !cpt = 0 then C else (
    p.(2*(!cpt -1) + (1-i))
  );;

(*AGENT TESTER*)
(*tester_state vaut -1 si la séquence CCD n'est pas lancée, et 0, 1 ou 2 sinon selon la position*)
(*let coup_tester (p:plateau) (i:int) (cpt:int ref) (tester_state:int ref) :coup = 
  if !cpt = 0 then D else (
    if p.(2*(!cpt -1) + (1-i)) = C then (coup_TFT p i cpt) else (
      match !tester_state with
      | -1 -> tester_state := 0; C 
      | 0 -> tester_state := 1; C
      | 1 -> tester_state :=-1; D
      (*| 2 -> tester_state := -1; coup_TFT p i cpt*)
      | _ -> failwith "input insensé";
    ) 
  );;*)


(*AGENT TESTER REMAKE*)
(*tester_state vaut -1 si le premier tour n'est pas encore arrivé, 0 si on part sur TFT et 1, 2, 3 si on enchaine les CCD*)

let rec coup_tester (p:plateau) (i:int) (cpt:int ref) (tester_state:int ref) :coup = 
  if !cpt = 0 then D else (
    match !tester_state with
    | -1 -> (match p.(1 - i) with | D -> tester_state :=0 | C -> tester_state :=1); coup_tester p i cpt tester_state
    | 0 -> coup_TFT p i cpt
    | 1 -> tester_state := 2; C 
    | 2 -> tester_state := 3; C 
    | 3 -> tester_state := 1; D
    | _ -> failwith "input insensé"
  );;

(*renvoie le coup opposé*)
let op_coup (c:coup) :coup = 
  match c with 
  | C -> D | D -> C;;

(*renvoie le string d'un coup*)
let coup_to_string (c:coup) :string = 
  match c with
  | C -> "C" | D -> "D";;

(*AGENT JOSS*)
let coup_joss (p:plateau) (i:int) (cpt:int ref) :coup = 
  let cj = coup_TFT p i cpt in
  if (!cpt mod 10) = 0 then D else cj;;

(*NOUVEAUX AGENTS*)

(*AGENT CHILD*)
let coup_child (p:plateau) (i:int) (cpt: int ref) : coup =
  if !cpt = 0 then coup_random () else (
    op_coup (p.(2*(!cpt -1) + (1-i)))  (*joue le coup opposé du précédent de son adversaire*)
  );;


(*AGENT UNDECIDED*)
let rec coup_undecided (p:plateau) (i:int) (cpt:int ref) (tester_state:int ref) (und_cpt:int ref) (und_strat:int ref):coup = 
  match  !und_cpt with
  | -1 -> (
      und_strat := Random.int 6;
      und_cpt := Random.int 20;
      joue_coup p (int_to_strat (!und_strat)) i cpt tester_state und_cpt und_strat);
  | k -> und_cpt := (k-1); joue_coup p (int_to_strat (!und_strat)) i cpt tester_state und_cpt und_strat


  
(*^ Mutuelles récursives v*)



(*i:int renvoie ici si le joueur est le premier indice du tableau des scores ou non et cpt indique le coup joué sur 200*)
and joue_coup (p:plateau) (j:strat) (i:int) (cpt:int ref) (tester_state:int ref) (und_cpt:int ref) (und_strat:int ref) :coup =
    match j with
      | ALL_D -> D 
      | RANDOM -> coup_random ()
      | TIT_FOR_TAT -> coup_TFT p i cpt
      | TESTER -> coup_tester p i cpt tester_state
      | JOSS -> coup_joss p i cpt
      | CHILD -> coup_child p i cpt
      | UNDECIDED -> coup_undecided p i cpt tester_state und_cpt und_strat
    ;;



(*========================================== DÉROULEMENT TOURNOI & PARTIES =======================================================*)


(*Fonction qui régit le déroulement d'une manche entre 2 joueurs*)
let partie (p:plateau) (s:score) (j1:strat) (j2:strat) (s1:int ref) (s2:int ref) (cpt:int ref) (tester_state:int ref) (und_cpt:int ref) (und_strat:int ref) :unit = 
    (*score.(strat_to_int j1) <- score.score.(strat_to_int j1);*)
    if !cpt >= 200 then (
        print_string ("\nscores : \n" ^ (strat_to_string j1) ^ " : "); print_int !s1;
        print_string ("\n" ^ (strat_to_string j2) ^ " : "); print_int !s2; print_string "\n";
        if !s1 > !s2 then 
            (print_string ("Victoire de " ^(strat_to_string j1) ^ " sur " ^ (strat_to_string j2)^"\n\n");
          ) else (
              if !s1 < !s2 then 
            (print_string ("Victoire de " ^(strat_to_string j2) ^ " sur " ^ (strat_to_string j1)^"\n\n");
          ) else (
            print_string ("Égalité entre " ^(strat_to_string j2) ^ " et " ^ (strat_to_string j1)^"\n\n");
          )
        ) 
    ) else(  
      let coup_J1 = joue_coup p j1 0 cpt tester_state und_cpt und_strat in
      let coup_J2 = joue_coup p j2 1 cpt tester_state und_cpt und_strat in (**)
      (*TEST
      if (!cpt <=14) then (
        print_string ("coup J1 ("^(strat_to_string j1)^") : "^(coup_to_string coup_J1)^"\n");
        print_string ("coup J2 ("^(strat_to_string j2)^") : "^(coup_to_string coup_J2)^"\n"););
      TEST*)
      
      let coups = (coup_J1, coup_J2) in
      let score_J1, score_J2 = tuple_score coups in 
      s1 := !s1 + score_J1; s2 := !s2 + score_J2;

      p.(!cpt*2)<-coup_J1; p.(!cpt*2+1)<-coup_J2;
    );;
  
(*AFFICHAGE SCORE DEBUG*)      
let affiche_score (s:score) :unit = 
  print_string "\nTEST :\n";
  for i= 0 to 4 do
    print_string ((strat_to_string (int_to_strat i))^" : "); print_int s.(i); print_string "\n";
  done;;

(*Lancement d'une partie entre 2 joueurs*)
let debut_partie (s:score) (j1:strat) (j2:strat) :unit = 
    let sc1 = ref 0 in 
    let sc2 = ref 0 in 
    let cpt= ref 0 in
    let test_st = ref (-1) in
    let undecided_cpt = ref (-1) in
    let undecided_strat = ref 0 in
    let p = Array.make 400 C in (**)
    while !cpt <= 200 do 
      partie p s j1 j2 sc1 sc2 cpt test_st undecided_cpt undecided_strat;
      cpt:= !cpt + 1
    done; 
    s.(strat_to_int j1)<- s.(strat_to_int j1) + !sc1;
    s.(strat_to_int j2)<- s.(strat_to_int j2) + !sc2;;


(*========================================== LANCEMENT & GESTION UTILISATEUR =======================================================*)


(*Lancement du tournoi qui va contenir toutes les parties entre chaque joueur*)
let tournoi () :unit = 
    let sco = Array.make nb_s 0 in (*on énumère tous les affrontements car le dénombrement est trop spécifique à généraliser*)
    (*avec ALL_D*)
    debut_partie sco ALL_D RANDOM;        (*affiche_score sco;*)
    debut_partie sco ALL_D TIT_FOR_TAT;   
    debut_partie sco ALL_D TESTER;        
    debut_partie sco ALL_D JOSS;        
    debut_partie sco ALL_D CHILD;        
    debut_partie sco ALL_D UNDECIDED;          
    (*avec RANDOM*)                       
    debut_partie sco RANDOM TIT_FOR_TAT;  
    debut_partie sco RANDOM TESTER;       
    debut_partie sco RANDOM JOSS;  
    debut_partie sco RANDOM CHILD; 
    debut_partie sco RANDOM UNDECIDED;         
    (*Avec TIT_FOR_TAT*)                  
    debut_partie sco TIT_FOR_TAT TESTER;  
    debut_partie sco TIT_FOR_TAT JOSS;    
    debut_partie sco TIT_FOR_TAT CHILD; 
    debut_partie sco TIT_FOR_TAT UNDECIDED;  
    (*avec TESTER*)                       
    debut_partie sco TESTER JOSS;    
    debut_partie sco TESTER CHILD; 
    debut_partie sco TESTER UNDECIDED;
    (*avec JOSS*)
    debut_partie sco JOSS CHILD; 
    debut_partie sco JOSS UNDECIDED;
    (*avec CHILD*)             
    debut_partie sco CHILD UNDECIDED;

    print_string "\n\nRÉSULTATS :\n";
    for i=0 to nb_s -1 do
      print_string ("Le joueur avec la stratégie " ^ (strat_to_string (int_to_strat i))^" termine le tournoi avec un score de "); print_int sco.(i); print_string "!!\n";
    done;;

let rec tournoi_perso () :unit = 
  print_string "Quelle stratégie voulez comme Joueur 1 ? Entrez le nombre adapté :\nALL_D       : 0\nRANDOM      : 1\nTIT_FOR_TAT : 2\nTESTER      : 3\nJOSS        : 4\nCHILD       : 5\nUNDECIDED   : 6\n";
  let rj1 = read_int () in
  print_string "Quelle stratégie voulez comme Joueur 2 ? Entrez le nombre adapté :\nALL_D       : 0\nRANDOM      : 1\nTIT_FOR_TAT : 2\nTESTER      : 3\nJOSS        : 4\nCHILD       : 5\nUNDECIDED   : 6\n";
  let rj2 = read_int () in
  print_string "\n... échange en cours...\n\n";
  let sco = Array.make nb_s 0 in
  debut_partie sco (int_to_strat rj1) (int_to_strat rj2);
  print_string "\n\nRÉSULTATS :\n";
    for i=0 to nb_s - 1 do
      print_string ("Le joueur avec la stratégie " ^ (strat_to_string (int_to_strat i))^" termine le tournoi avec un score de "); print_int sco.(i); print_string "!!\n";
    done;;


let rec main () :unit = 
  print_string "Que voulez vous faire ? Entrez le nombre adapté :\nJouer un échange particulier entre 2 joueurs/stratégies (1)\nJouer tout le tournoi (2)\n";
  let r = read_int () in
  match r with
  | 1 -> tournoi_perso ()
  | 2 -> tournoi()
  | _ -> print_string "numéro inconnu : réessayez\n"; main ();; 



Random.self_init ();
main ();;