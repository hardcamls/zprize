open! Base
open! Hardcaml
open! Hardcaml_waveterm
(* open Hardcaml_web *)

(* module Design = struct *)
(*   let top_level_name = "msm_barrett_reduction" *)
(*   let default_parameters = [] *)

(*   module Make (P : Parameters.S) = struct *)
(*     let bits = 377 *)
(*     let config = Field_ops_lib.Barrett_reduction.Config.for_bls12_377 *)
(*     let p = Field_ops_model.Modulus.m *)

(*     module Barrett_reduction = Field_ops_test.Test_barrett_reduction.Make (struct *)
(*       let bits = bits *)
(*       let output_bits = bits *)
(*     end) *)

(*     module Utils = Field_ops_test.Utils *)
(*     module I = Barrett_reduction.I *)
(*     module O = Barrett_reduction.O *)
(*     module Sim = Hardcaml.Cyclesim.With_interface (I) (O) *)

(*     let create scope ~build_mode:_ i = Barrett_reduction.create ~config ~p scope i *)
(*     let rand () = Utils.random_z ~lo_incl:Z.zero ~hi_incl:Z.(p - one) *)

(*     let testbench = *)
(*       Some *)
(*         (fun (sim : Sim.t) -> *)
(*           let waves, sim = Hardcaml_waveterm.Waveform.create sim in *)
(*           let () = *)
(*             Barrett_reduction.test *)
(*               ~debug:false *)
(*               ~sim *)
(*               ~config *)
(*               ~test_cases:(List.init 100 ~f:(fun _ -> rand ())) *)
(*           in *)
(*           { Testbench_result.waves = Some { waves; options = None; rules = None } *)
(*           ; result = None *)
(*           }) *)
(*     ;; *)
(*   end *)
(* end *)

(* module App = Hardcaml_web.App.Make (Design) *)

(* let () = App.run ~javascript:"msm_barrett_reduction.bc.js" () *)
