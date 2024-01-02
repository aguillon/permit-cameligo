#import "../src/main.mligo" "Main"
#import "../breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for set_expiry" [
  B.Model.case
    "set_expiry"
    "succeeds when setting a user expiry"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Context.call_as bob contract (Set_expiry (bob.address, (80n, None)));

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "User expiry for bob"
          (Big_map.find bob.address storage.extension.user_expiries)
          (Some 80n)
     ]);

  B.Model.case
    "set_expiry"
    "succeeds when setting a permit expiry"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let hash = 0x01 in
      B.Result.reduce [
        B.Context.call_as bob contract (Set_expiry (bob.address, (80n, Some hash)));

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Permit expiry for bob"
          (Big_map.find (bob.address, hash) storage.extension.permit_expiries)
          (Some 80n)
     ]);

  B.Model.case
    "set_expiry"
    "succeeds when setting a permit expiry"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let hash = 0x01 in
      B.Result.reduce [
        B.Context.call_as bob contract (Set_expiry (bob.address, (80n, Some hash)));

        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "Permit expiry for bob"
          (Big_map.find (bob.address, hash) storage.extension.permit_expiries)
          (Some 80n)
     ]);

  B.Model.case
    "set_expiry"
    "fails when setting a user expiry for someone else"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Expect.fail_with_message
          Main.Errors.forbidden_expiry_update
          (B.Context.call_as carol contract (Set_expiry (bob.address, (80n, None))));
     ]);

  B.Model.case
    "set_expiry"
    "fails when setting a permit expiry for someone else"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      let hash = 0x01 in
      B.Result.reduce [
        B.Expect.fail_with_message
          Main.Errors.forbidden_expiry_update
          (B.Context.call_as carol contract (Set_expiry (bob.address, (80n, Some hash))));
     ]);

  B.Model.case
    "set_expiry"
    "fails when setting an expiry exceeding max_expiry"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Expect.fail_with_message
          Main.Errors.max_seconds_exceeded
          (B.Context.call_as bob contract (Set_expiry (bob.address, (120n, None))));
     ]);
]
