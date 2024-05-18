use dep::std;

struct NullifierPre {
    signature: [u8; 64], // signature by the delegator
    deleg_pubx: [u8; 32], // delegator public key's x coordinate
    deleg_puby: [u8; 32]  // delegator public key's x coordinate
}

struct Stamp {
    signature: [u8; 64], // signature by certificate issuer (gitcoin passport)
    hashed_message: [u8; 32],
    score: u8
}

fn check_nullifier(nullifier: [u8; 32], hashed_message: [u8; 32], preimage: NullifierPre) {
    let valid_signature = std::ecdsa_secp256k1::verify_signature(
        preimage.deleg_pubx,
        preimage.deleg_puby,
        preimage.signature,
        hashed_message
    );
    assert(valid_signature);

    let hash: [u8; 32] = std::hash::keccak256(preimage.signature, 64);
    assert(nullifier == hash);
}

fn check_stamp_sigs(stamps: [Stamp; 10], cert_pubx: [u8; 32], cert_puby: [u8; 32]) {
    for i in 0..10 {
        let stamp = stamps[i];
        let valid_signature = std::ecdsa_secp256k1::verify_signature(cert_pubx, cert_puby, stamp.signature, stamp.hashed_message);
        assert(valid_signature);
    }
}

fn check_stamp_reuse(stamps: [Stamp; 10]) {
    for i in 1..10 {
        // To prevent stamp re-use, check if signatures are strictly sorted.
        // (with actual Gitcoin Passport stamps sort by provider field instead)
        let prev = stamps[i - 1].signature;
        let cur = stamps[i].signature;
        assert(prev < cur);
    }
}

fn compute_score(stamps: [Stamp; 10]) -> u8 {
    let mut score: u8 = 0;
    for i in 0..10 {
        // sum of passport stamps === passport score
        // passport score value is in [0, 100] range
        let stamp = stamps[i];
        score = score + stamp.score;
    }
    score
}

fn main(
    cert_pubx: pub [u8; 32],
    cert_puby: pub [u8; 32],
    score: pub u8,
    nullifier: pub [u8; 32],
    hashed_message: pub [u8; 32],
    preimage: NullifierPre,
    stamps: [Stamp; 10]
) {
    check_nullifier(nullifier, hashed_message, preimage);
    check_stamp_reuse(stamps);
    check_stamp_sigs(stamps, cert_pubx, cert_puby);
    let actual_score = compute_score(stamps);
    assert(actual_score > score);
}
