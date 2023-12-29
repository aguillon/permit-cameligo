#import "../../src/main.mligo" "Main"
#import "../../breathalyzer/lib/lib.mligo" "B"

let empty_storage (admin : address) = Main.empty_storage admin

let dummy_token_data (token_id : nat) : Main.FA2.TZIP12.tokenMetadataData =
  let dummy_token_info = (Map.empty : (string, bytes) map) in
  {token_id=token_id; token_info=dummy_token_info}

let normal_storage (admin : address) =
  let empty = empty_storage admin in
  let token_total_supply = Big_map.literal [
      (0n, 0n);
      (1n, 0n)
  ]
  in
  let token_metadata = Big_map.literal [
      (1n, dummy_token_data(1n));
      (2n, dummy_token_data(2n));
      (3n, dummy_token_data(3n));
  ]
  in
  { empty with
      extension = { empty.extension with extension = token_total_supply; default_expiry = 60n };
      token_metadata = token_metadata
  }

let storage2 (admin : address) (owner : address) =
  let storage = normal_storage admin in
  {
    storage with
    ledger = Big_map.add (owner, 1n) 10n storage.ledger;
    extension =
    {
      storage.extension with extension = Big_map.add 1n 10n storage.extension.extension
    }
  }

let originate_with_storage (storage : Main.storage) (level : B.Logger.level) =
  B.Contract.originate
    level
    "permit"
    (contract_of Main)
    storage
    (0tez)

let originate (level : B.Logger.level) (admin : address) =
  originate_with_storage (normal_storage admin) level
