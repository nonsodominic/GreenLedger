;; Green-Ledger Environmental Impact Monitoring Contract
;; Tracks eco-friendly actions and rewards participants with tokens

;; Define constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-ACTION (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-PROJECT-NOT-FOUND (err u103))

;; Define data variables
(define-data-var token-name (string-ascii 32) "GREEN")
(define-data-var token-symbol (string-ascii 10) "GRN")
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Define data maps
(define-map eco-actions
    { action-id: uint }
    {
        creator: principal,
        action-type: (string-ascii 64),
        impact-score: uint,
        timestamp: uint,
        verified: bool
    }
)

(define-map user-balances principal uint)

(define-map environmental-projects
    { project-id: uint }
    {
        name: (string-ascii 64),
        description: (string-utf8 256),
        target-amount: uint,
        current-votes: uint,
        status: (string-ascii 32)
    }
)

;; Define fungible token
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token green-token)

;; Read-only functions
(define-read-only (get-name)
    (ok (var-get token-name))
)

(define-read-only (get-symbol)
    (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (account principal))
    (ok (default-to u0 (map-get? user-balances account)))
)

(define-read-only (get-action-details (action-id uint))
    (map-get? eco-actions { action-id: action-id })
)

;; Public functions
(define-public (log-eco-action (action-type (string-ascii 64)) (impact-score uint))
    (let
        (
            (action-id (+ (var-get next-action-id) u1))
        )
        (if (is-valid-action action-type)
            (begin
                (map-set eco-actions
                    { action-id: action-id }
                    {
                        creator: tx-sender,
                        action-type: action-type,
                        impact-score: impact-score,
                        timestamp: block-height,
                        verified: false
                    }
                )
                (var-set next-action-id action-id)
                (ok action-id)
            )
            ERR-INVALID-ACTION
        )
    )
)

(define-public (verify-action (action-id uint))
    (let
        (
            (action (unwrap! (map-get? eco-actions { action-id: action-id }) ERR-INVALID-ACTION))
        )
        (if (is-eq tx-sender CONTRACT-OWNER)
            (begin
                (map-set eco-actions
                    { action-id: action-id }
                    (merge action { verified: true })
                )
                (reward-user (get creator action) (get impact-score action))
                (ok true)
            )
            ERR-NOT-AUTHORIZED
        )
    )
)

(define-public (create-project 
    (name (string-ascii 64))
    (description (string-utf8 256))
    (target-amount uint)
)
    (let
        (
            (project-id (+ (var-get next-project-id) u1))
        )
        (begin
            (map-set environmental-projects
                { project-id: project-id }
                {
                    name: name,
                    description: description,
                    target-amount: target-amount,
                    current-votes: u0,
                    status: "active"
                }
            )
            (var-set next-project-id project-id)
            (ok project-id)
        )
    )
)

(define-public (vote-on-project (project-id uint))
    (let
        (
            (project (unwrap! (map-get? environmental-projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
            (user-balance (unwrap! (get-balance tx-sender) ERR-INVALID-AMOUNT))
        )
        (if (>= user-balance u1)
            (begin
                (map-set environmental-projects
                    { project-id: project-id }
                    (merge project { current-votes: (+ (get current-votes project) u1) })
                )
                (ok true)
            )
            ERR-INVALID-AMOUNT
        )
    )
)

;; Private functions
(define-private (is-valid-action (action-type (string-ascii 64)))
    (or
        (is-eq action-type "TREE_PLANTING")
        (is-eq action-type "CARBON_OFFSET")
        (is-eq action-type "WASTE_RECYCLING")
        (is-eq action-type "RENEWABLE_ENERGY")
    )
)

(define-private (reward-user (user principal) (impact-score uint))
    (let
        (
            (reward-amount (* impact-score u1000000)) ;; 1 token per impact point
            (current-balance (default-to u0 (map-get? user-balances user)))
        )
        (begin
            (ft-mint? green-token reward-amount user)
            (map-set user-balances user (+ current-balance reward-amount))
            (ok reward-amount)
        )
    )
)

;; Initialize contract data
(define-data-var next-action-id uint u0)
(define-data-var next-project-id uint u0)