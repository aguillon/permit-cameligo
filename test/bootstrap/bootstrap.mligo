#import "../helpers/token.mligo" "Token_helper"
#import "../helpers/fa2.mligo" "FA2_helper"
#import "../../src/main.mligo" "Token"

(* Some dummy value when they don't matter for a given test *)
let dummy_genesis_ts = ("2000-01-01t10:10:10Z" : timestamp)

(*
    Boostrapping of the test environment,
    init_ts is the initial timestamp of the genesis block
*)
let boot_state (init_ts : timestamp) =
    let () = Test.reset_state_at init_ts 7n ([10000000tez] : tez list) in

    (* don't use 0 because it the baking account and may run out of tez *)
    let admin = Test.nth_bootstrap_account 6 in

    let owners =
        Test.nth_bootstrap_account 0,
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2
    in

    let owners_with_keys =
        Test.get_bootstrap_account 0n,
        Test.get_bootstrap_account 1n,
        Test.get_bootstrap_account 2n
    in

    let ops =
        Test.nth_bootstrap_account 3,
        Test.nth_bootstrap_account 4,
        Test.nth_bootstrap_account 5
    in

    (admin, owners, owners_with_keys, ops)

(*
    Bootstrapping of the contract under test,
    init_tok_amount is the amount of token allocated to every
    bootstrapped accounts
*)

let boot_token (owners, ops, init_tok_amount, init_extended_storage
: (address * address * address) * (address * address * address) * nat * Token.extension) =
    let initial_fa2_storage = FA2_helper.get_initial_storage(
        owners, ops, init_tok_amount
    ) in

    (* supply matching initial ledger *)
    let supply = (Big_map.literal [
       (1n, init_tok_amount); 
       (2n, (init_tok_amount * 2n)); 
       (3n, init_tok_amount); 
    ] : Token.TokenTotalSupply.t) in

    let init_storage = {
        metadata = Big_map.literal [
            ("", Bytes.pack("tezos-storage:contents"));
            ("contents", ("": bytes))
        ];
        ledger         = initial_fa2_storage.ledger;
        token_metadata = initial_fa2_storage.token_metadata;
        operators      = initial_fa2_storage.operators;
        extension      = { init_extended_storage with extension = supply };
    } in

    Token_helper.originate(init_storage)
