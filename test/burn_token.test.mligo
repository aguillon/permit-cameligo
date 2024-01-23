#import "../src/main.mligo" "Main"
#import "ligo-breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for burn_token" [
  B.Model.case
    "burn_token"
    "succeeds when the admin is calling it"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      B.Result.reduce [
        B.Context.call_as admin contract (Burn_token [{
          owner = bob.address;
          token_id = 1n;
          amount_ = 5n
        }]);

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Balance for bob"
          (Big_map.find (bob.address, 1n) storage.ledger)
          5n
     ]);

  B.Model.case
    "burn_token"
    "fails when someone else than the admin is calling it"
    (fun level ->
     let (_, (admin, bob, _)) = B.Context.init_default () in
     let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
     B.Result.reduce [
       B.Expect.fail_with_message Main.Errors.requires_admin
         (B.Context.call_as bob contract (Burn_token [{
          owner = bob.address;
          token_id = 1n;
          amount_ = 5n
        }]));
     ]);
]
