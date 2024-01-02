#import "../breathalyzer/lib/lib.mligo" "B"
#import "./mint_token.test.mligo" "MintTest"
#import "./burn_token.test.mligo" "BurnTest"
#import "./transfer.test.mligo" "TransferTest"
#import "./permit.test.mligo" "PermitTest"
#import "./set_admin.test.mligo" "Set_adminTest"
#import "./set_expiry.test.mligo" "Set_expiryTest"
#import "./create_token.test.mligo" "Create_tokenTest"

let () =
  B.Model.run_suites Trace [
    MintTest.suite;
    BurnTest.suite;
    TransferTest.suite;
    PermitTest.suite;
    Set_adminTest.suite;
    Set_expiryTest.suite;
    Create_tokenTest.suite;
  ]
