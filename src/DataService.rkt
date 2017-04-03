#lang racket

(require net/url)
(require json)

(define (retrieveData url)
  (define in (get-pure-port url))
  (define response-string (port->string in))
  (close-input-port in)
  (if (jsexpr? response-string) (string->jsexpr response-string) (error (string-append "Invalid query: " response-string))))

(provide retrieveData)