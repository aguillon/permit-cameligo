#import "../src/main.mligo" "Main"
#import "ligo-breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for remove_admin" [
  B.Model.case
    "remove_admin"
    "succeeds when it is called by an admin"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Context.call_as admin contract
          (Remove_admin admin.address)
      ]);

  B.Model.case
    "remove_admin"
    "fails when it is called by a non-admin address"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Expect.fail_with_value
          Main.Errors.requires_admin
          (B.Context.call_as bob contract
            (Remove_admin bob.address))
      ]);

  B.Model.case
    "remove_admin"
    "fails when the removed address is not in the set of admins"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Expect.fail_with_value
          Main.Errors.requires_admin
          (B.Context.call_as admin contract
            (Remove_admin bob.address))
      ])
]
