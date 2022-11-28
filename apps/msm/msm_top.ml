open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "msm_top16"
  let default_parameters = []

  module Make (P : Parameters.S) = struct
    module Config = Msm_pippenger.Config.Bls12_377
    module Msm = Msm_pippenger.Kernel_for_vitis.Make (Config)
    module I = Msm.I
    module O = Msm.O

    let create scope i = Msm.hierarchical ~build_mode:Synthesis scope i
    let testbench = None
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"msm_top.bc.js" ()
