;; Material Quality Verification Contract

(define-map material-certifications
  { certification-id: uint }
  {
    material-type: (string-ascii 50),
    quality-grade: (string-ascii 20),
    certifier: principal,
    expiration: uint
  }
)

(define-map material-batches
  { batch-id: uint }
  {
    certification-id: uint,
    quantity: uint,
    owner: principal
  }
)

(define-data-var certification-nonce uint u0)
(define-data-var batch-nonce uint u0)

(define-constant CERTIFIER_ADDRESS 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

(define-public (create-certification
  (material-type (string-ascii 50))
  (quality-grade (string-ascii 20))
  (expiration uint))
  (let
    ((new-id (+ (var-get certification-nonce) u1)))
    (asserts! (is-eq tx-sender CERTIFIER_ADDRESS) (err u403))
    (map-set material-certifications
      { certification-id: new-id }
      {
        material-type: material-type,
        quality-grade: quality-grade,
        certifier: tx-sender,
        expiration: expiration
      }
    )
    (var-set certification-nonce new-id)
    (ok new-id)
  )
)

(define-public (create-material-batch
  (certification-id uint)
  (quantity uint))
  (let
    ((new-id (+ (var-get batch-nonce) u1))
     (certification (unwrap! (map-get? material-certifications { certification-id: certification-id }) (err u404))))
    (asserts! (< block-height (get expiration certification)) (err u401))
    (map-set material-batches
      { batch-id: new-id }
      {
        certification-id: certification-id,
        quantity: quantity,
        owner: tx-sender
      }
    )
    (var-set batch-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-certification (certification-id uint))
  (map-get? material-certifications { certification-id: certification-id })
)

(define-read-only (get-material-batch (batch-id uint))
  (map-get? material-batches { batch-id: batch-id })
)
