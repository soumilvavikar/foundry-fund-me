# Foundry Steps Performed

## Project Creation
#### Folder Creation
```shell
mkdir foundry-fund-me
```
#### Opening VS Code 
```shell
code foundry-fund-me
```
#### Creating the empty Foundry Project
```shell
forge init --force
```

## Running JUnit Tests
This command will compile the contract and run the tests in the test folder 
```shell
forge test

forge test -mt <method name>

forge test -mt testPriceFeedVersionIsAccurate

forge test --mt testPriceFeedVersionIsAccurate --fork-url $SEPOLIA_RPC_URL

forge coverage --fork-url $SEPOLIA_RPC_URL
```
NOTE: 
- Do `forge test --help` for more options
- Pass -vv or -vvv to see stacetrace and console logs
- `coverage` command tells how many lines of the code inside the contract are covered
- --fork-url command helps let foundry know that we need to use the following chain URL instead of spinning a blank chain
    - downside to this is that a lot of API calls will be made to the chain which will increase the cost 
- Once we have setup the HelperConfig contract which helps setup Network configurations, with just anvil local chain started, we can run the Unit tests without passing the rpc_url for sepolia testnet or ethereum mainnet
- Unit testing best practices - https://twitter.com/PaulRBerg/status/1624763320539525121

## Check how much gas would a test cost
Use `forge snapshot` command 
```shell
forge snapshot 
forge snapshot --mt testWithdrawFromMultipleFunders
```
This command creates the .gas-snapshot file which contains the exact gas costs.  

## Inspecting the Storage of Variables
### Option 1
```shell
forge inspect FundMe storageLayout
```
This will give us the storage layout in the JSON format

### Option 2
```shell
cast storage <contract address> <storage slot> <index>
```

NOTE: 
- The immutable variables or constants are not stored in the storage, they are included in the bytecode of the contract
- Marking variables private in the contract, doesn't mean they are private. They are on the blockchain and anybody can read it. 

## Enable Imports for External Contracts
### Installing dependencies in Foundry to be used as imports
Without installing dependencies in the foundry we would not be able to use the external contracts like "AggregatorV3Interface.sol"
```shell
forge install <github repo name>@<release-version> --no-commit
```
NOTE: 
 - You can pass the release version if you want. Without release version, it will take the latest code and intall 
 - --no-commit is needed for <TBD>

Example
```shell
forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit
```

### Update the foundry.toml
After the forge install is complete, we need to tell foundry to point the `@chainlink/contracts` to the `lib` folder's `chainlink-brownie-contracts`.

```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts/"]
```

## Build the Contracts using Foundry
Once have enabled external imports, we can use the `forge build` command to build the contracts
```shell
forge build
```

## Compile and Deploy Script Using Foundry 
### Compile
```shell
forge script script/DeployFundMe.s.sol
```

NOTE: Pass the rpc key and secret for deploying on the blockchain. 

### Deploy
```shell
forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## MakeFile
Tutorial: [MakeFile](https://makefiletutorial.com/)

### Install Make
```shell
sudo apt install make
```