#|
 This file is a part of Staple
 (c) 2014 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:cl-user)
(defpackage #:staple
  (:nicknames #:org.tymoonnext.staple)
  (:use #:cl #:lquery #:alexandria #:closer-mop #:split-sequence)
  (:shadowing-import-from
   #:cl #:defmethod #:defgeneric #:standard-generic-function)
  ;; symbols.lisp
  (:export
   #:*symbol-object-transformers
   #:define-symbol-transformer
   #:define-easy-symbol-transformer
   
   #:symb-object
   #:symb-symbol
   #:symb-type
   #:symb-variable
   #:symb-function
   #:symb-macro
   #:symb-generic
   #:symb-method
   #:symb-class
   #:symb-special
   #:symb-constant
   
   #:symb-type
   #:symb-scope
   #:symb-qualifiers
   #:symb-argslist
   #:symb-docstring
   
   #:symbol-function-p
   #:smybol-macro-p
   #:symbol-generic-p
   #:symbol-constant-p
   #:smybol-special-p
   #:symbol-class-p

   #:symbol-objects
   #:package-symbols)

  ;; templating.lisp
  (:export
   #:*recognized-blocks*
   #:process-block
   #:define-block-processor
   #:generate
   #:process-symbol-object))
