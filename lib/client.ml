let data_send fd data =
  let data_len = Bytes.length data in
  let data = Bytes.extend data 4 0 in
  Bytes.set_int32_ne data 0 (Int32.of_int data_len);
  let _ = Unix.write fd data 0 (data_len + 4) in
  ()
;;

let client_send_quit fd =
  let data = Bytes.of_string "q" in
  data_send fd data
;;

let client_send_task_start fd task =
  let task_len = String.length task in
  let data = Bytes.create (task_len + 1) in
  Bytes.set data 0 's';
  Bytes.blit_string task 0 data 1 task_len;
  data_send fd data
;;

let client_send_task_end fd task =
  let task_len = String.length task in
  let data = Bytes.create (task_len + 1) in
  Bytes.set data 0 'e';
  Bytes.blit_string task 0 data 1 task_len;
  data_send fd data
;;

let client_req_send req_type =
  let fd = Unix.socket Unix.PF_UNIX Unix.SOCK_STREAM 0 in
  let unix_addr = Unix.ADDR_UNIX "/tmp/patek" in
  (try Unix.connect fd unix_addr with
   | Unix.Unix_error (err, _, _) ->
     print_string "[Client] Failed to connect to daemon :: ";
     Unix.error_message err |> print_endline);
  match req_type with
  | Request.Quit -> client_send_quit fd
  | Request.TaskStart task -> client_send_task_start fd task
  | Request.TaskEnd task -> client_send_task_end fd task
  | _ -> ()
;;
