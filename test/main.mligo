#import "../breathalyzer/lib/lib.mligo" "B"
#import "./mint_token.test.mligo" "MintTest"
#import "./burn_token.test.mligo" "BurnTest"
#import "./transfer.test.mligo" "TransferTest"

let () =
  B.Model.run_suites Trace [
    MintTest.suite;
    BurnTest.suite;
    TransferTest.suite;
  ]
