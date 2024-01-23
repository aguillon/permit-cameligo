#import "../src/main.mligo" "Main"
#import "ligo-breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for transfer" [
  B.Model.case
    "transfer"
    "succeeds when a valid permit has been signed"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash_ = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit = C.make_permit(hash_, bob, contract.originated_address, 0n) in
      B.Result.reduce [
        B.Context.call_as carol contract
          (Permit [permit]);
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash_) storage.extension.permits)
          (Tezos.get_now ());
        B.Context.call_as carol contract
          (Transfer [transfer_request]);
        let storage = B.Contract.storage_of contract in
        B.Result.and_then
          (B.Assert.is_equal "ledger for sender"
            (Big_map.find (bob.address, 1n) storage.ledger)
            8n)
          (B.Assert.is_equal "ledger for receivver"
            (Big_map.find (admin.address, 1n) storage.ledger)
            2n)
      ]);

  B.Model.case
    "transfer"
    "succeeds when a permit has expired but the sender is the owner"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash_ = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit = C.make_permit(hash_, bob, contract.originated_address, 0n) in
      B.Result.reduce [
        B.Context.call_as carol contract
          (Permit [permit]);
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash_) storage.extension.permits)
          (Tezos.get_now ());
        B.Context.wait_for 100n;
        B.Context.call_as bob contract
          (Transfer [transfer_request]);
        let storage = B.Contract.storage_of contract in
        B.Result.and_then
          (B.Assert.is_equal "ledger for sender"
            (Big_map.find (bob.address, 1n) storage.ledger)
            8n)
          (B.Assert.is_equal "ledger for receiver"
            (Big_map.find (admin.address, 1n) storage.ledger)
            2n)
      ]);

  B.Model.case
    "transfer"
    "fails when a permit has expired"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash_ = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit = C.make_permit(hash_, bob, contract.originated_address, 0n) in
      B.Result.reduce [
        B.Context.call_as admin contract
          (Permit [permit]);
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash_) storage.extension.permits)
          (Tezos.get_now ());
        B.Context.wait_for 100n;
        B.Expect.fail_with_message Main.FA2.Errors.not_operator
          (B.Context.call_as carol contract
            (Transfer [transfer_request]));
      ]);
]
