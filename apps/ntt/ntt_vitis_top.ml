open! Base
open! Hardcaml
open! Hardcaml_waveterm
open Hardcaml_web

module Design = struct
  let top_level_name = "ntt_parallel"

  let default_parameters =
    Parameter.
      [ ( "n"
        , { typ =
              Symbol
                { options =
                    [ "256"
                    ; "1024"
                    ; "4096"
                    ; "16384"
                    ; "65536"
                    ; "262,144"
                    ; "1,048,576"
                    ; "4,194,304"
                    ; "16,777,216"
                    ]
                ; value = 0
                }
          ; description = "transform size"
          } )
      ; "logblocks", { typ = Int 0; description = "log blocks" }
      ]
  ;;

  module Make (P : Parameters.S) = struct
    let index = (Parameters.as_symbol_exn P.parameters "n").value
    let logn = (index * 2) + 8
    let logblocks = Parameters.as_int_exn P.parameters "logblocks"

    (* Clamp logblocks to supported values *)
    let logblocks = min (1 + index) logblocks
    let () = Stdio.printf "%i %i\n" logn logblocks

    module Config = struct
      let logn = logn / 2
      let support_4step_twiddle = true
      let logcores = 3
      let logblocks = logblocks
      let memory_layout = Zprize_ntt.Memory_layout.Normal_layout_single_port
    end

    module Test = Zprize_ntt_test.Test_kernel_for_vitis.Make (Config)
    module Ntt = Zprize_ntt.For_vitis.Make (Config)
    module I = Ntt.I
    module O = Ntt.O

    let create scope ~build_mode i = Ntt.create ~build_mode scope i

    let testbench sim =
      let waves, sim = Waveform.create sim in
      let inputs = Test.random_input_coef_matrix () in
      Test.run_with_sim sim (Cyclesim.inputs sim) (Cyclesim.outputs sim) inputs;
      Testbench_result.of_waves waves
    ;;

    let testbench = Some testbench
  end
end

module App = Hardcaml_web.App.Make (Design)

let () = App.run ~javascript:"ntt_vitis_top.bc.js" ()
