open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "ntt_core"
  let default_parameters = Parameter.[ "logn", { typ = Int 12; description = "log N" } ]

  module Make (P : Parameters.S) = struct
    let logn = Parameters.as_int_exn P.parameters "logn"

    module Config = struct
      let logn = logn
      let support_4step_twiddle = false
      let logcores = 0
      let logblocks = 0
    end

    module Ntt = Hardcaml_ntt.Single_core.Make (Config)
    module I = Ntt.I
    module O = Ntt.O

    let create scope i = Ntt.create scope i
    let testbench = None
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"ntt_core.bc.js" ()
