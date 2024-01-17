#import "../ligo-fa2/lib/main.mligo" "FA2"
#import "./errors.mligo" "Errors"
#import "./extension.mligo" "Extension"

module FA2 = FA2.MultiAssetExtendable
type storage = FA2.storage
type extension = Extension.t
type 'a t = 'a extension storage

let make_storage (type a) (admins : address set) (extension : a) : a t =
  let extension = Extension.make_extension admins extension in
  FA2.make_storage extension

let get_token_metadata (type a) (s:a t) = s.token_metadata
let set_token_metadata (type a) (s:a t) (token_metadata:FA2.TZIP12.tokenMetadata) =
    {s with token_metadata = token_metadata}

let add_new_token (md:FA2.TZIP12.tokenMetadata) (token_id : nat) (data:FA2.TZIP12.tokenMetadataData) =
    let () = assert_with_error (not (Big_map.mem token_id md)) Errors.token_exist in
    let md = Big_map.add token_id data md in
    md
