#import "../src/main.mligo" "Main"
#import "../breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for create_token" [
  B.Model.case
    "create_token"
    "succeeds when the admin calls it with a fresh token_id"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let new_token_id = 4n in
      let token_metadata = C.dummy_token_data new_token_id in
      B.Result.reduce [
        B.Context.call_as admin contract
          (Create_token (token_metadata, bob.address, 10n));

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Balance for new token"
          (Big_map.find (bob.address, new_token_id) storage.ledger)
          10n;
      ]);

  B.Model.case
    "create_token"
    "fails when a non-admin user calls it"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let new_token_id = 4n in
      let token_metadata = C.dummy_token_data new_token_id in
      B.Result.reduce [
        B.Expect.fail_with_value
          Main.Errors.requires_admin
          (B.Context.call_as bob contract
            (Create_token (token_metadata, bob.address, 10n)));
      ]);

  B.Model.case
    "create_token"
    "fails when the token already exists"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let token_metadata = C.dummy_token_data 1n in
      B.Result.reduce [
        B.Expect.fail_with_value
          Main.Errors.token_exist
          (B.Context.call_as admin contract
            (Create_token (token_metadata, bob.address, 10n)));
      ]);
]
