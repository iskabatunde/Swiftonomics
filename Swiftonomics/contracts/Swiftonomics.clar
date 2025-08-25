;; Swiftonomics Trading Protocol - Taylor Swift Economic Index
;; A simplified but complete trading system based on Swift's tour economic impact

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-invalid-amount (err u105))
(define-constant err-position-closed (err u106))
(define-constant err-city-inactive (err u107))

;; Swift Era multipliers
(define-constant era-fearless u11000)    ;; 1.1x
(define-constant era-red u12000)         ;; 1.2x
(define-constant era-1989 u13000)        ;; 1.3x
(define-constant era-reputation u10500)  ;; 1.05x
(define-constant era-lover u11500)       ;; 1.15x
(define-constant era-folklore u14000)    ;; 1.4x (pandemic boost)
(define-constant era-midnights u15000)   ;; 1.5x (current era)
(define-constant era-ttpd u13000)        ;; 1.3x

;; Data Variables
(define-data-var global-swift-index uint u10000)  ;; Base index 100.00
(define-data-var total-trading-volume uint u0)
(define-data-var current-era uint u7)             ;; Midnights era
(define-data-var oracle-address principal tx-sender)
(define-data-var next-position-id uint u1)
(define-data-var friendship-bracelet-multiplier uint u150)  ;; 1.5x for friendship bracelets

;; Fungible Tokens
(define-fungible-token swift-coin)
(define-fungible-token swiftie-points)

;; NFTs for achievements
(define-non-fungible-token era-badge uint)

;; Data Maps
(define-map city-economic-data
    (string-ascii 30)
    {
        base-economy: uint,
        swift-boost: uint,
        concert-count: uint,
        peak-impact: uint,
        active: bool
    }
)

(define-map trading-positions
    uint
    {
        trader: principal,
        city: (string-ascii 30),
        amount: uint,
        entry-price: uint,
        is-long: bool,
        timestamp: uint,
        active: bool
    }
)

(define-map trader-stats
    principal
    {
        total-trades: uint,
        successful-trades: uint,
        total-volume: uint,
        swiftie-level: uint,
        favorite-era: uint
    }
)

(define-map era-data
    uint
    {
        name: (string-ascii 20),
        multiplier: uint,
        total-concerts: uint,
        avg-attendance: uint
    }
)

;; Read-only functions
(define-read-only (get-swift-index)
    (var-get global-swift-index)
)

(define-read-only (get-city-data (city (string-ascii 30)))
    (map-get? city-economic-data city)
)

(define-read-only (get-position (position-id uint))
    (map-get? trading-positions position-id)
)

(define-read-only (get-trader-stats (trader principal))
    (map-get? trader-stats trader)
)

(define-read-only (get-era-multiplier (era uint))
    (if (is-eq era u1) era-fearless
        (if (is-eq era u2) era-red
            (if (is-eq era u3) era-1989
                (if (is-eq era u4) era-reputation
                    (if (is-eq era u5) era-lover
                        (if (is-eq era u6) era-folklore
                            (if (is-eq era u7) era-midnights
                                (if (is-eq era u8) era-ttpd
                                    u10000))))))))  ;; default 1.0x
)

(define-read-only (calculate-city-index (city (string-ascii 30)))
    (match (get-city-data city)
        city-info (let
                    (
                        (base (get base-economy city-info))
                        (boost (get swift-boost city-info))
                        (era-mult (get-era-multiplier (var-get current-era)))
                        (bracelet-mult (var-get friendship-bracelet-multiplier))
                    )
                    (ok (/ (* (+ base boost) era-mult bracelet-mult) u1000000))
                  )
        (err err-not-found)
    )
)

(define-read-only (get-lucky-thirteen-bonus)
    (if (is-eq (mod stacks-block-height u13) u0)
        u113  ;; 1.13x bonus on block heights divisible by 13
        u100  ;; 1.0x normal
    )
)

;; Private functions
(define-private (update-trader-stats (trader principal) (volume uint) (success bool))
    (let
        (
            (current-stats (default-to 
                            { total-trades: u0, successful-trades: u0, total-volume: u0, 
                              swiftie-level: u1, favorite-era: u7 }
                            (get-trader-stats trader)))
        )
        (map-set trader-stats trader {
            total-trades: (+ (get total-trades current-stats) u1),
            successful-trades: (if success 
                               (+ (get successful-trades current-stats) u1)
                               (get successful-trades current-stats)),
            total-volume: (+ (get total-volume current-stats) volume),
            swiftie-level: (if (> (+ (get total-trades current-stats) u1) u12)
                           (+ (get swiftie-level current-stats) u1)
                           (get swiftie-level current-stats)),
            favorite-era: (var-get current-era)
        })
        true
    )
)

;; Public functions

;; Initialize contract with era data
(define-public (initialize-eras)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (map-set era-data u1 { name: "fearless", multiplier: era-fearless, total-concerts: u87, avg-attendance: u35000 })
        (map-set era-data u2 { name: "red", multiplier: era-red, total-concerts: u66, avg-attendance: u42000 })
        (map-set era-data u3 { name: "1989", multiplier: era-1989, total-concerts: u85, avg-attendance: u50000 })
        (map-set era-data u4 { name: "reputation", multiplier: era-reputation, total-concerts: u53, avg-attendance: u58000 })
        (map-set era-data u5 { name: "lover", multiplier: era-lover, total-concerts: u0, avg-attendance: u0 })
        (map-set era-data u6 { name: "folklore", multiplier: era-folklore, total-concerts: u17, avg-attendance: u25000 })
        (map-set era-data u7 { name: "midnights", multiplier: era-midnights, total-concerts: u152, avg-attendance: u65000 })
        (map-set era-data u8 { name: "ttpd", multiplier: era-ttpd, total-concerts: u0, avg-attendance: u0 })
        
        (ok true)
    )
)

;; Add city to tracking
(define-public (add-city 
    (city-name (string-ascii 30))
    (base-economy uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-address)) err-unauthorized)
        (asserts! (is-none (get-city-data city-name)) err-already-exists)
        
        (map-set city-economic-data city-name {
            base-economy: base-economy,
            swift-boost: u0,
            concert-count: u0,
            peak-impact: base-economy,
            active: true
        })
        
        (ok true)
    )
)

;; Update city economic impact
(define-public (update-city-impact 
    (city-name (string-ascii 30))
    (new-boost uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-address)) err-unauthorized)
        
        (let
            (
                (city-data (unwrap! (get-city-data city-name) err-not-found))
            )
            (map-set city-economic-data city-name
                (merge city-data {
                    swift-boost: new-boost,
                    concert-count: (+ (get concert-count city-data) u1),
                    peak-impact: (if (> new-boost (get peak-impact city-data))
                                 new-boost
                                 (get peak-impact city-data))
                })
            )
            
            ;; Update global index
            (let
                (
                    (new-index (unwrap! (calculate-city-index city-name) err-not-found))
                )
                (var-set global-swift-index new-index)
                (ok new-index)
            )
        )
    )
)

;; Open trading position
(define-public (open-position
    (city (string-ascii 30))
    (amount uint)
    (is-long bool))
    (begin
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (is-some (get-city-data city)) err-not-found)
        (asserts! (>= (ft-get-balance swift-coin tx-sender) amount) err-insufficient-funds)
        
        ;; Transfer collateral
        (try! (ft-transfer? swift-coin amount tx-sender (as-contract tx-sender)))
        
        (let
            (
                (position-id (var-get next-position-id))
                (entry-price (unwrap! (calculate-city-index city) err-not-found))
            )
            ;; Create position
            (map-set trading-positions position-id {
                trader: tx-sender,
                city: city,
                amount: amount,
                entry-price: entry-price,
                is-long: is-long,
                timestamp: stacks-block-height,
                active: true
            })
            
            ;; Update counters
            (var-set next-position-id (+ position-id u1))
            (var-set total-trading-volume (+ (var-get total-trading-volume) amount))
            
            ;; Mint swiftie points
            (try! (ft-mint? swiftie-points (/ amount u100) tx-sender))
            
            (ok position-id)
        )
    )
)

;; Close trading position
(define-public (close-position (position-id uint))
    (let
        (
            (position (unwrap! (get-position position-id) err-not-found))
        )
        (asserts! (is-eq tx-sender (get trader position)) err-unauthorized)
        (asserts! (get active position) err-position-closed)
        
        (let
            (
                (exit-price (unwrap! (calculate-city-index (get city position)) err-not-found))
                (entry-price (get entry-price position))
                (amount (get amount position))
                (is-long (get is-long position))
            )
            ;; Calculate profit/loss
            (let
                (
                    (price-diff (if (> exit-price entry-price) 
                                (- exit-price entry-price) 
                                (- entry-price exit-price)))
                    (percentage-change (/ (* price-diff u10000) entry-price))
                    (profit-amount (/ (* amount percentage-change) u10000))
                    (is-profitable (if is-long 
                                   (> exit-price entry-price)
                                   (< exit-price entry-price)))
                    (lucky-bonus (get-lucky-thirteen-bonus))
                    (final-amount (if is-profitable
                                  (+ amount (/ (* profit-amount lucky-bonus) u100))
                                  (if (> amount profit-amount)
                                      (- amount profit-amount)
                                      u0)))
                )
                ;; Transfer final amount back
                (try! (as-contract (ft-transfer? swift-coin final-amount (as-contract tx-sender) tx-sender)))
                
                ;; Mark position as closed
                (map-set trading-positions position-id
                    (merge position { active: false })
                )
                
                ;; Update trader stats
                (update-trader-stats tx-sender amount is-profitable)
                
                ;; Bonus swiftie points for profitable trades
                (if is-profitable
                    (try! (ft-mint? swiftie-points (/ profit-amount u50) tx-sender))
                    true
                )
                
                (ok final-amount)
            )
        )
    )
)

;; Mint swift coins (faucet for testing)
(define-public (mint-swift-coins (amount uint))
    (begin
        (asserts! (<= amount u10000) err-invalid-amount)  ;; Max 10000 per mint
        (try! (ft-mint? swift-coin amount tx-sender))
        (ok amount)
    )
)

;; Change era (special event)
(define-public (change-era (new-era uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-address)) err-unauthorized)
        (asserts! (<= new-era u8) err-invalid-amount)
        
        (var-set current-era new-era)
        
        ;; Update global index with new era multiplier
        (var-set global-swift-index 
                 (/ (* (var-get global-swift-index) (get-era-multiplier new-era)) u10000))
        
        (ok new-era)
    )
)

;; Update friendship bracelet activity
(define-public (update-friendship-bracelets (new-multiplier uint))
    (begin
        (asserts! (is-eq tx-sender (var-get oracle-address)) err-unauthorized)
        (asserts! (<= new-multiplier u300) err-invalid-amount)  ;; Max 3x multiplier
        (asserts! (>= new-multiplier u100) err-invalid-amount)  ;; Min 1x multiplier
        
        (var-set friendship-bracelet-multiplier new-multiplier)
        (ok new-multiplier)
    )
)

;; Mint era achievement badge
(define-public (mint-era-badge (trader principal) (era-id uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (let
            (
                (stats (unwrap! (get-trader-stats trader) err-not-found))
                (nft-id (+ (* era-id u1000) (get total-trades stats)))
            )
            ;; Must have at least 13 successful trades (Taylor's lucky number)
            (asserts! (>= (get successful-trades stats) u13) err-unauthorized)
            
            (try! (nft-mint? era-badge nft-id trader))
            (ok nft-id)
        )
    )
)

;; Set oracle address
(define-public (set-oracle (new-oracle principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set oracle-address new-oracle)
        (ok true)
    )
)

;; Emergency functions
(define-public (pause-city (city-name (string-ascii 30)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (let
            (
                (city-data (unwrap! (get-city-data city-name) err-not-found))
            )
            (map-set city-economic-data city-name
                (merge city-data { active: false })
            )
            (ok true)
        )
    )
)

(define-public (resume-city (city-name (string-ascii 30)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (let
            (
                (city-data (unwrap! (get-city-data city-name) err-not-found))
            )
            (map-set city-economic-data city-name
                (merge city-data { active: true })
            )
            (ok true)
        )
    )
)