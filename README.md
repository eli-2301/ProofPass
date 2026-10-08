# ProofPass

A decentralized proof-of-participation system built with Solidity and Foundry.

ProofPass allows an organizer to create events, register participants, manage participant records, and update event statuses through a smart contract deployed on the Ethereum Sepolia test network.

## Live Deployment

**Network:** Ethereum Sepolia Testnet

**Contract Address:**

`0xFBb42a493E50BD3153CBF5C4740831da9c7abd51`

**Verified Contract:**

[View ProofPass on Sepolia Etherscan](https://sepolia.etherscan.io/address/0xFBb42a493E50BD3153CBF5C4740831da9c7abd51)

**Deployment Transaction:**

[View Deployment Transaction](https://sepolia.etherscan.io/tx/0xe0afcd5a5e2c44c0838141c8d610116dd4d1879e2ac621dad1825a4fae464c2f)

---

## Project Overview

ProofPass is a blockchain-based event participation system designed to provide a transparent and tamper-resistant way to manage event participation records.

The project demonstrates how Solidity smart contracts can be used to manage participants and events while enforcing access control and validating user input directly on-chain.

The current version focuses on the core smart contract architecture and does not yet include a frontend application.

---

## Features

### Event Management

- Create events with:
  - Event ID
  - Name
  - Description
  - Start time
  - End time
  - Location
  - Status
- Automatically assign unique event IDs.
- Update event status.
- Prevent invalid event times.
- Prevent empty event names, descriptions, and statuses.

### Participant Management

- Register participants.
- Prevent duplicate participant registration.
- Prevent zero-address registration.
- Update participant addresses.
- Remove participants.
- Retrieve the complete participant list.
- Check whether an address is registered.

### Access Control

The contract uses the deployer as the event organizer.

Organizer-only functions include:

- Creating events
- Registering participants
- Updating participants
- Removing participants
- Updating event status

Unauthorized users are rejected by the smart contract.

### Events

The contract emits events for important state changes:

- `ParticipantRegistered`
- `ParticipantUpdated`
- `ParticipantRemoved`
- `EventStatusUpdated`
- `EventCreated`

---

## Smart Contract Architecture

The project currently consists of one main smart contract:

```text
src/
└── proofpass.sol
