let req_recv fd =
  let clt_fd, _ = Unix.accept fd in
  let buf = Bytes.create 4 in
  match Unix.read clt_fd buf 0 4 with
  | 4 ->
    let msg_len = Bytes.get_int32_ne buf 0 |> Int32.to_int in
    let msg = Bytes.create msg_len in
    let _ = Unix.read clt_fd msg 0 msg_len in
    (match Bytes.get msg 0 with
     | 's' -> Request.TaskStart (Bytes.sub_string msg 1 (msg_len - 1))
     | 'e' -> Request.TaskEnd (Bytes.sub_string msg 1 (msg_len - 1))
     | 'q' -> Request.Quit
     | _ -> Request.Invalid "Invalid request type")
  | _ -> Request.Invalid "Failed to read msg len header"
;;

let server_clean_up fd =
  print_endline "[Server] > Exiting";
  Unix.close fd
;;

let rec process_req fd req_type =
  match req_type with
  | Request.Quit -> server_clean_up fd
  | Request.TaskStart task ->
    print_string "[Server] task_start :: ";
    print_endline task;
    req_recv fd |> process_req fd
  | Request.TaskEnd task ->
    print_string "[Server] task_end :: ";
    print_endline task;
    req_recv fd |> process_req fd
  | Request.Invalid err ->
    print_string "[Server] invalid_req :: ";
    print_endline err;
    req_recv fd |> process_req fd
;;

let server_init () =
  if Sys.file_exists "/tmp/patek" then Unix.unlink "/tmp/patek";
  let fd = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
  let unix_addr = Unix.ADDR_UNIX "/tmp/patek" in
  Unix.bind fd unix_addr;
  Unix.listen fd 0;
  fd
;;

let server_run () =
  let fd = server_init () in
  req_recv fd |> process_req fd
;;
