use dep::std;

struct NullifierPre {
    signature: [u8; 64], // signature by the delegator
    deleg_pubx: [u8; 32], // delegator public key's x coordinate
    deleg_puby: [u8; 32]  // delegator public key's x coordinate
}

struct Stamp {
    signature: [u8; 64], // signature by certificate issuer (gitcoin passport)
    hashed_message: [u8; 32],
    score: u8,
    score_string: [u8; 3]
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
        let hashed_message = encode_defunct(stamp.score_string);
        let valid_signature = std::ecdsa_secp256k1::verify_signature(cert_pubx, cert_puby, stamp.signature, hashed_message);
        assert(valid_signature);
    }
}

fn encode_defunct(score_string: [u8;3]) -> [u8;32] {
    let score_len: u8 = get_len(score_string);
    let eip191E_postfix: str<25> = "Ethereum Signed Message:\n"; // len 25
    let eip191E_postfix_bytes: [u8; 25] = eip191E_postfix.as_bytes();
    let with_length = eip191E_postfix_bytes.as_slice().push_back(score_len); // len 25 + 1
    let eip191E = &[19].append(with_length); // len 1 + 25 + 1
    let preimage = eip191E.append(score_string.as_slice()); // len 1 + 25 + 1 + score_len
    let preimage_array: [u8;29] = preimage.as_array();
    println(preimage_array);
    std::hash::keccak256(preimage_array, 1 + 25 + 1 + score_len as u32)
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

fn check_stamp_score_encoding(stamps: [Stamp; 10]) {
    for i in 0..10 {
        check_encoding(stamps[i].score, stamps[i].score_string)
    }
}

fn check_encoding(score: u8, score_string: [u8;3]) {
    let len: u8 = get_len(score_string);
    if len == 1 {
        assert(score == score_string[0]);
    }
    if len == 2 {
        assert(score == score_string[0] * 10 + score_string[1]);
    }
    if len == 3 {
        assert(score == score_string[0] * 10 + score_string[1]);
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

// return length of null-terminated string
fn get_len(str_t: [u8; 3]) -> u8 {
    let mut len: u8 = 0;
    let mut done: u8 = 0;
    for i in 0..3 {
        if ((str_t[i] != 0) & (done == 0)) {
            len = i;
        };
    }
    len + 1
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

#[test]
fn test_get_len() {
    assert(2 == get_len([1, 1, 0]));
    assert(3 == get_len([1, 1, 1]));
}
