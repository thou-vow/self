(provide kv ls)

(define (kv . key-values) (apply hash (apply append key-values)))
(define ls list)
