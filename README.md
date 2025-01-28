# Green-Ledger Environmental Impact Monitoring App

## Overview
Green-Ledger is a blockchain-based platform that tracks and rewards eco-friendly actions while promoting environmental sustainability. Built on the Stacks blockchain using Clarity smart contracts, the platform enables transparent logging of environmental activities and community participation in green initiatives.

## Features
- **Eco-Action Tracking**: Record and verify environmental activities such as tree planting, carbon offsetting, and waste recycling
- **Token Rewards**: Earn GREEN tokens for verified environmental contributions
- **Community Governance**: Participate in voting on environmental projects using earned tokens
- **Transparent Logging**: All activities are recorded on-chain for complete transparency

## Smart Contract Architecture

### Core Components
1. **Token System**
   - Implementation of SIP-010 fungible token standard
   - GREEN (GRN) token for rewards
   - Built-in balance tracking

2. **Action Tracking System**
   - Logging of environmental actions
   - Verification mechanism
   - Impact score calculation

3. **Project Management**
   - Community project creation
   - Token-based voting
   - Project status tracking

## Getting Started

### Prerequisites
- Stacks blockchain wallet
- Clarity CLI tools
- Node.js and npm (for frontend development)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/nonsodominic/green-ledger.git
cd green-ledger
```

2. Install dependencies:
```bash
npm install
```

3. Deploy the smart contract:
```bash
clarinet contract deploy
```

### Contract Deployment
1. Update the contract constants in `contracts/green-ledger.clar`
2. Deploy using Clarinet:
```bash
clarinet deploy --network mainnet
```

## Usage

### Logging Eco-Actions
```clarity
(contract-call? .green-ledger log-eco-action "TREE_PLANTING" u10)
```

### Creating Environmental Projects
```clarity
(contract-call? .green-ledger create-project "Forest Restoration" "Restore 100 acres of forest" u1000000)
```

### Voting on Projects
```clarity
(contract-call? .green-ledger vote-on-project u1)
```

## Smart Contract Functions

### Public Functions
- `log-eco-action`: Record new environmental actions
- `verify-action`: Verify reported actions and distribute rewards
- `create-project`: Create new community projects
- `vote-on-project`: Vote on environmental projects

### Read-Only Functions
- `get-action-details`: Retrieve details of specific actions
- `get-balance`: Check token balance
- `get-name`: Get token name
- `get-symbol`: Get token symbol

## Security Considerations
- Only contract owner can verify actions
- Token rewards are distributed only for verified actions
- Voting requires token ownership
- Impact scores are validated before action logging

## Development

### Local Testing
1. Run local tests:
```bash
clarinet test
```

2. Start local development chain:
```bash
clarinet console
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to the branch
5. Create a Pull Request

## Future Enhancements
- [ ] Implementation of different impact calculation algorithms
- [ ] Integration with external carbon offset verification systems
- [ ] Enhanced governance mechanisms
- [ ] Mobile app development
- [ ] Integration with environmental IoT devices

## Acknowledgments
- Stacks Foundation
- Environmental Conservation Partners
- Community Contributors
