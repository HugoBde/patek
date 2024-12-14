open Patek

let start_daemon () =
  match Unix.fork () with
  | 0 -> Server.server_run ()
  | _ -> print_endline "Started patek daemon"
;;

let stop_daemon () = print_endline "stopping daemon..."
let start_task () = print_endline "starting task ..."
let end_task () = print_endline "ending task ..."

let print_help () =
  print_endline "Usage: ./patek <command>";
  print_endline "commands:";
  print_endline " - daemon-start";
  print_endline " - daemon-stop";
  print_endline " - start";
  print_endline " - end";
  print_endline " - help"
;;

let () =
  try
    match Array.get Sys.argv 1 with
    | "daemon-start" -> start_daemon ()
    | "daemon-stop" -> stop_daemon ()
    | "start" -> start_task ()
    | "end" -> end_task ()
    | "help" | _ -> print_help ()
  with
  | Invalid_argument _ -> print_help ()
;;
