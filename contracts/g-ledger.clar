;; Green-Ledger Environmental Impact Monitoring Contract
;; Environmental Impact Monitoring Smart Contract
;; A platform for tracking and rewarding eco-friendly actions

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-ACTION (err u101))
(define-constant ERR-ALREADY-VERIFIED (err u102))
(define-constant ERR-ACTION-NOT-FOUND (err u103))
(define-constant ERR-INVALID-REWARD (err u104))

;; Data Variables
(define-data-var total-actions uint u0)
(define-data-var total-impact-score uint u0)

;; Define action types map for valid actions
(define-map action-types 
    { action-type: (string-ascii 32) }
    { 
        base-score: uint,
        multiplier: uint,
        active: bool
    }
)

;; Define eco actions map
(define-map eco-actions
    { action-id: uint }
    {
        creator: principal,
        action-type: (string-ascii 32),
        location: (string-ascii 64),
        timestamp: uint,
        impact-score: uint,
        evidence-url: (string-utf8 256),
        verified: bool,
        verifier: (optional principal)
    }
)

;; Define user stats map
(define-map user-stats
    principal
    {
        total-actions: uint,
        total-score: uint,
        reputation: uint
    }
)

;; Read-only functions

(define-read-only (get-action-details (action-id uint))
    (map-get? eco-actions { action-id: action-id })
)

(define-read-only (get-user-stats (user principal))
    (default-to 
        { total-actions: u0, total-score: u0, reputation: u0 }
        (map-get? user-stats user)
    )
)

(define-read-only (get-action-type-details (action-type (string-ascii 32)))
    (map-get? action-types { action-type: action-type })
)

(define-read-only (get-total-impact)
    (var-get total-impact-score)
)

;; Internal helper functions

(define-private (calculate-impact-score (action-type (string-ascii 32)))
    (let (
        (type-info (unwrap! (map-get? action-types { action-type: action-type }) u0))
    )
    (* (get base-score type-info) (get multiplier type-info)))
)

(define-private (update-user-stats (user principal) (score uint))
    (let (
        (current-stats (get-user-stats user))
    )
    (map-set user-stats 
        user
        {
            total-actions: (+ (get total-actions current-stats) u1),
            total-score: (+ (get total-score current-stats) score),
            reputation: (+ (get reputation current-stats) u1)
        }
    ))
)

;; Public functions

(define-public (register-action-type 
    (action-type (string-ascii 32)) 
    (base-score uint)
    (multiplier uint)
)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (ok (map-set action-types
            { action-type: action-type }
            {
                base-score: base-score,
                multiplier: multiplier,
                active: true
            }
        ))
    )
)

(define-public (log-eco-action
    (action-type (string-ascii 32))
    (location (string-ascii 64))
    (evidence-url (string-utf8 256))
)
    (let (
        (action-id (var-get total-actions))
        (type-info (unwrap! (map-get? action-types { action-type: action-type }) ERR-INVALID-ACTION))
    )
    (asserts! (get active type-info) ERR-INVALID-ACTION)
    (let (
        (impact-score (calculate-impact-score action-type))
    )
    (begin
        (map-set eco-actions
            { action-id: action-id }
            {
                creator: tx-sender,
                action-type: action-type,
                location: location,
                timestamp: block-height,
                impact-score: impact-score,
                evidence-url: evidence-url,
                verified: false,
                verifier: none
            }
        )
        (var-set total-actions (+ action-id u1))
        (ok action-id)
    )))
)

(define-public (verify-action (action-id uint))
    (let (
        (action (unwrap! (map-get? eco-actions { action-id: action-id }) ERR-ACTION-NOT-FOUND))
    )
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (not (get verified action)) ERR-ALREADY-VERIFIED)
        (map-set eco-actions
            { action-id: action-id }
            (merge action { 
                verified: true,
                verifier: (some tx-sender)
            })
        )
        (var-set total-impact-score (+ (var-get total-impact-score) (get impact-score action)))
        (update-user-stats (get creator action) (get impact-score action))
        (ok true)
    ))
)

;; Initialize supported action types
(begin
    (try! (register-action-type "TREE_PLANTING" u10 u2))
    (try! (register-action-type "CARBON_OFFSET" u15 u2))
    (try! (register-action-type "WASTE_RECYCLING" u5 u1))
    (try! (register-action-type "RENEWABLE_ENERGY" u20 u3))
)