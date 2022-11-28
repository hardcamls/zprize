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
      ; "twiddle", { typ = Flag false; description = "support 4 step twiddle" }
      ]
  ;;

  module Make (P : Parameters.S) = struct
    let logn = Parameters.as_int_exn P.parameters "logn"
    let logcores = Parameters.as_int_exn P.parameters "logcores"
    let logblocks = Parameters.as_int_exn P.parameters "logblocks"
    let support_4step_twiddle = Parameters.as_flag_exn P.parameters "twiddle"

    module Config = struct
      let logn = logn / 2
      let support_4step_twiddle = support_4step_twiddle
      let logcores = logcores
      let logblocks = logblocks
    end

    module Ntt = Hardcaml_ntt.Multi_parallel_cores.Make (Config)
    module I = Ntt.I
    module O = Ntt.O

    let create scope ~build_mode i = Ntt.create ~build_mode scope i
    let testbench = None
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"ntt_parallel.bc.js" ()
