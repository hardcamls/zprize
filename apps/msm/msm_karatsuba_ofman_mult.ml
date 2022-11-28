open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "msm_karatsuba_ofman_mult"
  let default_parameters = []

  module Make (P : Parameters.S) = struct
    let bits = 377

    let config =
      Elliptic_curve_lib.Config_presets.For_bls12_377.karatsuba_ofman_mult_config
    ;;

    module Karatsuba_ofman_mult = Field_ops_test.Test_karatsuba_ofman_mult.Make (struct
      let bits = bits
    end)

    module Utils = Field_ops_test.Utils
    module I = Karatsuba_ofman_mult.I
    module O = Karatsuba_ofman_mult.O
    module Sim = Hardcaml.Cyclesim.With_interface (I) (O)

    let create scope ~build_mode:_ i = Karatsuba_ofman_mult.create ~config scope i
    let rand () = Utils.random_z ~lo_incl:Z.zero ~hi_incl:Z.((one lsl bits) - one)

    let testbench =
      Some
        (fun (sim : Sim.t) ->
          let waves, sim = Hardcaml_waveterm.Waveform.create sim in
          Karatsuba_ofman_mult.test
            ~sim
            ~config
            ~test_cases:
              (List.init 100 ~f:(fun _ ->
                 { Field_ops_test.Test_karatsuba_ofman_mult.a = rand (); b = rand () }));
          { Testbench_result.waves = Some { waves; options = None; rules = None }
          ; result = None
          })
    ;;
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"msm_karatsuba_ofman_mult.bc.js" ()
