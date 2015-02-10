(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: QCDQiQBarjToQiQBarjTree                                          *)

(*
   This software is covered by the GNU Lesser General Public License 3.
   Copyright (C) 1990-2015 Rolf Mertig
   Copyright (C) 1997-2015 Frederik Orellana
   Copyright (C) 2014-2015 Vladyslav Shtabovenko
*)

(* :Summary:  Computation of the matrix element squared for the
              q_i qbar_j -> q_i qbar_j scattering in QCD at tree level      *)

(* ------------------------------------------------------------------------ *)



(* ::Section:: *)
(*Load FeynCalc, FeynArts and PHI*)


If[ $FrontEnd === Null,
    $FeynCalcStartupMessages = False;
    Print["Computation of the matrix element squared for the q_i qbar_j -> q_i qbar_j scattering in QCD at tree level"];
];
If[$Notebooks === False, $FeynCalcStartupMessages = False];
$LoadTARCER = False;
$LoadPhi =$LoadFeynArts= True;
<<HighEnergyPhysics`FeynCalc`
$FAVerbose = 0;


(* ::Section:: *)
(*Generate Feynman diagrams*)


topQiQBarjToQiQBarj = CreateTopologies[0, 2 -> 2];
diagsQiQBarjToQiQBarj = InsertFields[topQiQBarjToQiQBarj, {F[3, {1}], -F[3, {2}]} -> {F[3, {1}],
    -F[3, {2}]}, InsertionLevel -> {Classes}, Model -> "SMQCD", ExcludeParticles -> {S[1], S[2], V[1],V[2]}];
Paint[diagsQiQBarjToQiQBarj, ColumnsXRows -> {2, 1}, Numbering -> None];


(* ::Section:: *)
(*Obtain corresponding amplitudes*)


ampQiQBarjToQiQBarj =
 Map[ReplaceAll[#, FeynAmp[_, _, amp_, ___] :> amp] &,
    Apply[List, FCPrepareFAAmp[CreateFeynAmp[diagsQiQBarjToQiQBarj,
    Truncated -> False],UndoChiralSplittings->True]]]/.{SumOver[__]:>1}/.{InMom1->p1,InMom2->p2,OutMom1->p3,OutMom2->p4};


(* ::Section:: *)
(*Unpolarized process  q_i qbar_j -> q_i qbar_j *)


SetMandelstam[s, t, u, p1, p2, -p3, -p4, MU, MC, MU, MC];
sqAmpQiQBarjToQiQBarj =(1/3^2)*(Total[ampQiQBarjToQiQBarj] Total[(ComplexConjugate[ampQiQBarjToQiQBarj]//
    FCRenameDummyIndices)])//PropagatorDenominatorExplicit//Contract//
    FermionSpinSum[#, ExtraFactor -> 1/2^2]&//ReplaceAll[#,{DiracTrace->Tr,SUNN->3}]&//Contract//SUNSimplify[#,
    Explicit->True,SUNNToCACF->False]&//ReplaceAll[#,{SUNN->3}]&//Simplify


masslesssqAmpQiQBarjToQiQBarj = (sqAmpQiQBarjToQiQBarj /. {MU -> 0,MC->0})//Simplify


masslesssqAmpQiQBarjToQiQBarjEllis=((4/9)Gstrong^4 (s^2+u^2)/t^2);
Print["Check with Ellis, Stirling and Weber, Table 7.1: ",
      If[(masslesssqAmpQiQBarjToQiQBarjEllis-masslesssqAmpQiQBarjToQiQBarj)===0, "Correct.", "Mistake!"]];
