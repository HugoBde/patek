let req_send fd req =
  print_string "clt > sending msg :: ";
  print_endline req;
  let data_len = String.length req in
  let data = Bytes.create (data_len + 4) in
  Bytes.set_int32_ne data 0 (Int32.of_int data_len);
  Bytes.blit_string req 0 data 4 data_len;
  let _ = Unix.write fd data 0 (data_len + 4) in
  ()
;;

let rec reqs_send fd = function
  | [] -> ()
  | x :: xs ->
    req_send fd x;
    reqs_send fd xs
;;

let client_run () =
  let fd = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
  let unix_addr = Unix.ADDR_UNIX "/tmp/patek" in
  let rec client_connect () =
    try Unix.connect fd unix_addr with
    | Unix.Unix_error (err, _, _) ->
      print_string "clt > ";
      Unix.error_message err |> print_endline;
      Unix.sleep 1;
      client_connect ()
  in
  client_connect ();
  reqs_send fd [ "mMessage 1"; "mMessage 2"; "q" ]
;;
