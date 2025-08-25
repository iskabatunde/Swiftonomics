# Swiftonomics Trading Protocol 🎤💸

## Description

**Swiftonomics** is a **Taylor Swift–themed trading protocol** that models the **economic impact of her eras, tours, and concerts**.
Users can trade city-based indices, speculate on Swift’s eras, earn **Swiftie Points & Era Badges**, and benefit from **friendship bracelet multipliers** and **lucky number 13 bonuses**.

## Installation / Deployment

```sh
clarinet check
clarinet deploy
```

## Features

* **Swift Era Multipliers** → Each era (Fearless, Red, 1989, Reputation, Lover, Folklore, Midnights, TTPD) affects economic performance
* **City Economic Data** → Track concert boosts, base economy, and peak impact
* **Trading System** → Open long/short positions on cities with SwiftCoin collateral
* **Swiftie Points** → Earn fungible tokens for trading & profits
* **Era Badges (NFTs)** → Unlock collectibles for achieving 13+ successful trades
* **Friendship Bracelet Multiplier** → Boost indices with fan-driven activity
* **Lucky Thirteen Bonus** → Extra rewards on block heights divisible by 13
* **Oracle Governance** → Oracle updates cities, eras, and multipliers

## Usage

### Indices & Eras

* `get-swift-index()` → Global Swift Index
* `calculate-city-index(city)` → Compute a city’s index with multipliers
* `get-era-multiplier(era-id)` → Get multiplier for an era
* `change-era(new-era)` → Oracle updates active era

### Cities

* `add-city(city, base-economy)` → Add new tracked city
* `update-city-impact(city, new-boost)` → Update city concert impact
* `pause-city(city)` / `resume-city(city)` → Emergency city controls

### Trading

* `open-position(city, amount, is-long)` → Open long/short trade using SwiftCoin
* `close-position(position-id)` → Close trade, settle P/L, update stats
* Auto-mints Swiftie Points for trading & profitable outcomes

### Rewards

* `mint-era-badge(trader, era-id)` → Mint achievement NFT after 13 successful trades
* `update-friendship-bracelets(multiplier)` → Oracle sets fan activity multiplier

### Tokens

* `mint-swift-coins(amount)` → Faucet for SwiftCoin (test collateral)
* SwiftCoin → Trading collateral
* Swiftie Points → Rewards & achievements

### Oracle & Admin

* `set-oracle(principal)` → Set trusted oracle
* `initialize-eras()` → Load all era metadata

---

✨ **Swiftonomics: Trade the eras. Ride the concerts. Profit from Swift’s economy.**
