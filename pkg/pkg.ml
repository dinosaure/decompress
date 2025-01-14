#!/usr/bin/env ocaml
#use       "topfind";;
#require   "topkg";;

open Topkg

let unix = Conf.with_pkg "unix"
let cmdliner = Conf.with_pkg ~default:false "cmdliner"

let () =
  Pkg.describe "decompress" @@ fun c ->

  let unix = Conf.value c unix in
  let cmdliner = Conf.value c cmdliner in
  let test = unix in

  Ok [ Pkg.lib "pkg/META"
     ; Pkg.doc "README.md"
     ; Pkg.doc "CHANGES.md"
     ; Pkg.lib ~exts:Exts.module_library "lib/decompress"
     ; Pkg.bin  ~cond:(unix && cmdliner) "bin/dpipe" ~dst:"dpipe"
     ; Pkg.test ~cond:test "test/test" ]
