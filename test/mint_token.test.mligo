#import "../src/main.mligo" "Main"
#import "ligo-breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for mint_token" [
  B.Model.case
    "mint_token"
    "succeeds when the admin is calling it"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Context.call_as admin contract (Mint_token [{
          owner = bob.address;
          token_id = 1n;
          amount_ = 10n
        }]);

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Supply for the minted token"
          (Big_map.find 1n storage.extension.extension)
          10n;

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Balance for bob"
          (Big_map.find (bob.address, 1n) storage.ledger)
          10n
     ]);

  B.Model.case
    "mint_token"
    "fails when someone else than the admin is calling it"
    (fun level ->
     let (_, (admin, bob, _)) = B.Context.init_default () in
     let contract = C.originate level admin.address in
     B.Result.reduce [
       B.Expect.fail_with_message Main.Errors.requires_admin
         (B.Context.call_as bob contract (Mint_token [{
           owner = bob.address;
           token_id = 1n;
           amount_ = 1n
           }]));
     ]);

  B.Model.case
    "mint_token"
    "fails when the token is not in token_metadata"
    (fun level ->
     let (_, (admin, bob, _)) = B.Context.init_default () in
     let storage = C.normal_storage admin.address in
     let storage =
       { storage with token_metadata = Big_map.remove 1n storage.token_metadata }
     in
     let contract = C.originate_with_storage storage level in
     B.Result.reduce [
       B.Expect.fail_with_message Main.FA2.Errors.undefined_token
         (B.Context.call_as admin contract (Mint_token [{
           owner = bob.address;
           token_id = 1n;
           amount_ = 1n
           }]));
     ]);

  B.Model.case
    "mint_token"
    "fails when the token is not in token_total_supply"
    (fun level ->
     let (_, (admin, bob, _)) = B.Context.init_default () in
     let storage = C.normal_storage admin.address in
     let storage =
       { storage with extension =
         { storage.extension with extension = Big_map.remove 1n storage.extension.extension }
       }
     in
     let contract = C.originate_with_storage storage level in
     B.Result.reduce [
       B.Expect.fail_with_message Main.FA2.Errors.undefined_token
         (B.Context.call_as admin contract (Mint_token [{
           owner = bob.address;
           token_id = 1n;
           amount_ = 1n
           }]));
     ]);

]

