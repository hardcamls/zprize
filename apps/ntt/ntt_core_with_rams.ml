open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "ntt_core_with_rams"
  let default_parameters = Parameter.[ "logn", { typ = Int 12; description = "log N" } ]

  module Make (P : Parameters.S) = struct
    let logn = Parameters.as_int_exn P.parameters "logn"

    module Config = struct
      let logn = logn
      let support_4step_twiddle = false
      let logcores = 0
      let logblocks = 0
    end

    module Ntt = Hardcaml_ntt.Single_core.With_rams (Config)
    module I = Ntt.I
    module O = Ntt.O

    let create scope ~build_mode i = Ntt.create ~build_mode scope i
    let testbench = None
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"ntt_core_with_rams.bc.js" ()
