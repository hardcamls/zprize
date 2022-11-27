open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "ntt_parallel"

  let default_parameters =
    Parameter.
      [ "logn", { typ = Int 24; description = "log N" }
      ; "logcores", { typ = Int 3; description = "log cores" }
      ; "logblocks", { typ = Int 2; description = "log blocks" }
      ]
  ;;

  module Make (P : Parameters.S) = struct
    let logn = Parameters.as_int_exn P.parameters "logn"
    let logcores = Parameters.as_int_exn P.parameters "logcores"
    let logblocks = Parameters.as_int_exn P.parameters "logblocks"

    module Config = struct
      let logn = logn / 2
      let support_4step_twiddle = true
      let logcores = logcores
      let logblocks = logblocks
      let memory_layout = Zprize_ntt.Memory_layout.Normal_layout_single_port
    end

    module Ntt = Zprize_ntt.For_vitis.Make (Config)
    module I = Ntt.I
    module O = Ntt.O

    let create scope i = Ntt.create ~build_mode:Synthesis scope i
    let testbench = None
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"ntt_vitis_top.bc.js" ()
