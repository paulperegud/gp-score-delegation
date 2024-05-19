# Private delegation of Gitcoin Passport score

> [!IMPORTANT]
> This project is a work in progress. Among its drawbacks are stub stamps instead of actual Gitoin Passport stamps and at least one unpatched vulnerability in the circuit.

Due to lack of privacy on Ethereum, people keep money separate from their public accounts (with ENS names and social) to have some modecum of financial privacy. This works requires discipline and produces problems in some circumstances. One of them is situation when you need both money and gitcoin passport score (e.g. quadratic voting/funding).

To make this delegation secure and privacy preserving following is true:
* act of delegation produces a nullifier which is a function of private key of delegator and selected domain ("I delegate my Gitcoin Passport score for Gitcoin Rounds #24")
* nullifier can't be traced back to the delegator (as long as delegator's private key remains private and hash is a 'one-way-function')
* nullifier can't be chosen by the delegator (as long as protocol is bug-free)
* act of accepting a delegation published the nullifier for the world (e.g. marked as spent in a smart contract), so it can't be reused
* stamp information isn't visible to the world
* stamps are checked for validity and can't be forged
* procedure doesn't reveal exact value of delegated score, it only proves that score is greater than some chosen threshold

If delegation is not taking place, score owner needs to produce a signature so nullifier can be marked as spent. Otherwise they would be able to use score twice.

This software is a PoC of such delegation.

Missing pieces:
* working with actual Gitcoin Passport stamps instead of stub stamps (needs EIP712 implementation, needs stamp data availability)
* let user pass variable number of stamps
* check if dummy stamp score is legitimate
* nullifier for situation when no delegation is happening

## Usage

```
nargo prove
nargo verify
```
