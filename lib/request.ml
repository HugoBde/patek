type req_type =
  | Quit
  | TaskStart of string
  | TaskEnd of string
  | Invalid of string
