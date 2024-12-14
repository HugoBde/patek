let req_recv fd =
  let buf = Bytes.create 4 in
  match Unix.read fd buf 0 4 with
  | 4 ->
    let msg_len = Bytes.get_int32_ne buf 0 |> Int32.to_int in
    let msg = Bytes.create msg_len in
    let _ = Unix.read fd msg 0 msg_len in
    (match Bytes.get msg 0 with
     | 'm' -> Common.Message (Bytes.sub_string msg 1 (msg_len - 1))
     | 'q' -> Common.Quit
     | _ -> Common.Invalid msg)
  | _ ->
    print_endline "Failed to read msg len header";
    Common.Invalid Bytes.empty
;;

let server_clean_up fd =
  print_endline "srv > Exiting";
  Unix.close fd
;;

let rec process_req fd req_type =
  match req_type with
  | Common.Quit -> server_clean_up fd
  | Common.Message msg ->
    print_string "Server :: msg > ";
    print_endline msg;
    req_recv fd |> process_req fd
  | Common.Invalid data ->
    print_string "Server :: invalid > ";
    print_endline (Bytes.to_string data);
    req_recv fd |> process_req fd
;;

let server_run () =
  if Sys.file_exists "/tmp/patek" then Unix.unlink "/tmp/patek";
  let fd = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
  let unix_addr = Unix.ADDR_UNIX "/tmp/patek" in
  Unix.bind fd unix_addr;
  Unix.listen fd 0;
  let clt_fd, _ = Unix.accept fd in
  req_recv clt_fd |> process_req clt_fd
;;
