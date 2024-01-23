#import "../src/main.mligo" "Main"
#import "ligo-breathalyzer/lib/lib.mligo" "B"
#import "./helpers/common.mligo" "C"

let suite = B.Model.suite "Suite for permit" [
  B.Model.case
    "permit"
    "permit creation succeeds"
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
      ]);

  B.Model.case
    "permit"
    "multiple permits creation succeeds"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash1 = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit1 = C.make_permit(hash1, bob, contract.originated_address, 0n) in
      let transfer_request = ({
          from_=carol.address;
          txs=[{to_=bob.address;amount=2n;token_id=1n}]
      })
      in
      let hash2 = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit2 = C.make_permit(hash2, carol, contract.originated_address, 1n) in
      let permit_act1 = B.Context.call_as carol contract (Permit [permit1]) in
      let time1 = Tezos.get_now () in
      let permit_act2 = B.Context.call_as admin contract (Permit [permit2]) in
      B.Result.reduce [
        permit_act1;
        permit_act2;
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash1) storage.extension.permits)
          (time1);
        let storage = B.Contract.storage_of contract in
        B.Result.and_then
          (B.Assert.is_equal "permit has been registered"
            (Big_map.find (carol.address, hash2) storage.extension.permits)
            (Tezos.get_now ()))
          (B.Assert.is_equal "counter"
            storage.extension.counter
            2n)
      ]);

  B.Model.case
    "permit"
    "creating a list of permits succeeds"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash1 = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit1 = C.make_permit(hash1, bob, contract.originated_address, 0n) in
      let transfer_request = ({
          from_=carol.address;
          txs=[{to_=bob.address;amount=2n;token_id=1n}]
      })
      in
      let hash2 = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit2 = C.make_permit(hash2, carol, contract.originated_address, 1n) in
      let permit_action = B.Context.call_as carol contract (Permit [permit1; permit2]) in
      B.Result.reduce [
        permit_action;
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash1) storage.extension.permits)
          (Tezos.get_now());
        let storage = B.Contract.storage_of contract in
        B.Result.and_then
          (B.Assert.is_equal "permit has been registered"
            (Big_map.find (carol.address, hash2) storage.extension.permits)
            (Tezos.get_now ()))
          (B.Assert.is_equal "counter"
            storage.extension.counter
            2n)
      ]);

  B.Model.case
    "permit"
    "updating an expired permit succeeds"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit1 = C.make_permit(hash, bob, contract.originated_address, 0n) in
      let permit2 = C.make_permit(hash, bob, contract.originated_address, 1n) in
      B.Result.reduce [
        B.Context.call_as carol contract (Permit [permit1]);
        B.Context.wait_for 100n;
        B.Context.call_as carol contract (Permit [permit2]);
        let storage = B.Contract.storage_of contract in
        B.Assert.is_equal "permit has been registered"
          (Big_map.find (bob.address, hash) storage.extension.permits)
          (Tezos.get_now ())
      ]);

  B.Model.case
    "permit"
    "updating an expired permit succeeds"
    (fun level ->
      let (_, (admin, bob, carol)) = B.Context.init_default () in
      let contract = C.originate_with_storage (C.storage2 admin.address bob.address) level in
      let transfer_request = ({
          from_=bob.address;
          txs=[{to_=admin.address;amount=2n;token_id=1n}]
      })
      in
      let hash = Crypto.blake2b (Bytes.pack transfer_request) in
      let permit1 = C.make_permit(hash, bob, contract.originated_address, 0n) in
      let permit2 = C.make_permit(hash, bob, contract.originated_address, 1n) in
      B.Result.reduce [
        B.Context.call_as carol contract (Permit [permit1]);
        B.Expect.fail_with_value
          Main.Errors.dup_permit
          (B.Context.call_as carol contract (Permit [permit2]))
      ])
]
