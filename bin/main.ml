
open Lwt.Infix


exception Caqti_conn_error of string


module Q = struct
  open Caqti_type
  open Caqti_prereq

  let create_p tA tB mB f =
    Caqti_request.create_p tA tB mB (f % Caqti_driver_info.dialect_tag)

  let (-->!) tA (tR : unit t) f = create_p tA tR Caqti_mult.zero f
  let (-->) tA tR f = create_p tA tR Caqti_mult.one f 

  let create_tmp = (unit -->! unit) @@ function
   | `Mysql | `Pgsql ->
      "CREATE TEMPORARY TABLE test_sql \
        (id SERIAL NOT NULL, i INTEGER NOT NULL, s TEXT NOT NULL)"
   | `Sqlite ->
      "CREATE TABLE test_sql \
        (id INTEGER PRIMARY KEY, i INTEGER NOT NULL, s TEXT NOT NULL)"
   | _ -> failwith "Unimplemented."
  let drop_tmp = (unit -->! unit) @@ function
   | _ -> "DROP TABLE test_sql"
  let insert_into_tmp = Caqti_request.exec (tup2 int string)
    "INSERT INTO test_sql (i, s) VALUES (?, ?)"
end

let use_pool p f =
  let%lwt result = p |> Caqti_lwt.Pool.use begin fun dbc ->
    match%lwt f dbc with
    | exception exn -> Lwt.return @@ Ok (Error exn)
    | x -> Lwt.return @@ Ok (Ok x)
  end >>= Caqti_lwt.or_fail in

  match result with
  | Error exn -> raise exn
  | Ok x -> Lwt.return x


let main () =
  let db_uri = Uri.of_string "mariadb://root:abc123@db/goomba" in
  let pool = match Caqti_lwt.connect_pool db_uri with
    | Ok p -> p
    | Error e -> raise @@ Caqti_conn_error (Caqti_error.show e)
  in

  let test (module DB : Caqti_lwt.CONNECTION) =
    let or_fail = Caqti_lwt.or_fail in
    DB.exec Q.create_tmp () >>= or_fail >>= fun () ->
    DB.exec Q.insert_into_tmp (1, "one") >>= or_fail >>= fun () ->
    DB.exec Q.insert_into_tmp (2, "two") >>= or_fail >>= fun () ->
    DB.exec Q.drop_tmp () >>= or_fail
  in

  match%lwt use_pool pool test with
  | exception exn ->
    Lwt_io.printlf "Failed: %s" (Printexc.to_string exn) >>= fun () ->
    raise exn
  | _ ->
    Lwt_io.printl "Success?"

let () = 
  Lwt_main.run @@ main ()
