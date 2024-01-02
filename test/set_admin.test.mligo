#import "../src/main.mligo" "Main"
#import "../breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for set_admin" [
  B.Model.case
    "set_admin"
    "succeeds when it is called by the admin"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Context.call_as admin contract
          (Set_admin bob.address)
      ]);

  B.Model.case
    "set_admin"
    "succeeds when it is called by the admin"
    (fun level ->
      let (_, (admin, bob, _)) = B.Context.init_default () in
      let contract = C.originate level admin.address in
      B.Result.reduce [
        B.Expect.fail_with_value
          Main.Errors.requires_admin
          (B.Context.call_as bob contract
            (Set_admin bob.address))
      ])
]
