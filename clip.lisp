#|
 This file is a part of Staple
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.tymoonnext.staple)

(defvar *current-packages* ())

(defun year ()
  (nth-value 5 (get-decoded-time)))

(defun month ()
  (nth-value 4 (get-decoded-time)))

(defun day ()
  (nth-value 3 (get-decoded-time)))

(defun licenselink (license)
  (format NIL "<a href=\"https://tldrlegal.com/search?q=~a\">~a</a>" license license))

(defun present-improper-list (list)
  (loop for (car . cdr) on list
        collect (present car) into result
        while (or (consp cdr) (null cdr))
        finally (when cdr
                  (setf (cdr (last result)) (present cdr)))
                (return result)))

(defun present (thing)
  (typecase thing
    ((or keyword string pathname) (prin1-to-string thing))
    #+sbcl (sb-impl::comma (format NIL ",~a" (present (sb-impl::comma-expr thing))))
    (list
     (case (first thing)
       (quote (format NIL "'~a" (present (second thing))))
       #+sbcl (sb-int:quasiquote (format NIL "`~a" (present (second thing))))
       (T (princ-to-string
           (present-improper-list thing)))))
    (vector (map 'vector #'present thing))
    (T (princ-to-string thing))))

(defun present-qualifiers (thing)
  (typecase thing
    (null "")
    (T (present thing))))

(defun present-arguments (thing &optional (lambda-list-parens T))
  (let ((string (typecase thing
                  (null "()")
                  (T (present thing)))))
    (if lambda-list-parens
        string
        (subseq string 1 (1- (length string))))))

(defun string-starts-with (string sub)
  (and (<= (length sub) (length string))
       (string-equal (subseq string 0 (length sub)) sub)))

(defun resolve-symbol-documentation (symbol)
  (let ((name) (package) (symbol (string-upcase symbol)))
    (let ((colonpos (position #\: symbol)))
      (if colonpos
          (if (= 0 colonpos)
              (return-from resolve-symbol-documentation NIL)
              (setf package (subseq symbol 0 colonpos)
                    name (subseq symbol (1+ colonpos))))
          (setf package "" name symbol)))
    (cond
      ((string-starts-with package "sb-")
       (format NIL "http://l1sp.org/sbcl/~a:~a" (string-downcase package) (string-downcase name)))
      ((string-equal package "mop")
       (format NIL "http://l1sp.org/mop/~a" (string-downcase name)))
      ((or (string-equal package "cl")
           (string-equal package "common-lisp"))
       (format NIL "http://l1sp.org/cl/~a" (string-downcase name)))
      ((find package *current-packages* :test #'string-equal)
       (format NIL "#~a:~a" (string-upcase package) name))
      (T
       (dolist (package *current-packages*)
         (multiple-value-bind (found scope) (find-symbol name (find-package (string-upcase package)))
           (when (and found (eql scope :external))
             (return-from resolve-symbol-documentation
               (format NIL "#~a:~a" (string-upcase package) name)))))
       (when (and (string= package "") (find-symbol name "CL"))
         (format NIL "http://l1sp.org/cl/~a" (string-downcase name)))))))

(defun anchor (object)
  (format NIL "#~a" object))

(defun stext (node object)
  (lquery-funcs:text node (princ-to-string (or object ""))))

(defun parse-block-symbols (html)
  (cl-ppcre:regex-replace-all
   "\\([^\\s)'`]+" html
   #'(lambda (target start end match-start match-end reg-starts reg-ends)
       (declare (ignore start end reg-starts reg-ends))
       (let* ((name (subseq target (1+ match-start) match-end))
              (href (resolve-symbol-documentation (plump:decode-entities name))))
         (if href
             (format NIL "(<a href=\"~a\">~a</a>" href name)
             (format NIL "(~a"  name))))))

(defun parse-lone-symbols (html)
  (cl-ppcre:regex-replace-all
   "^[^:][^\\s]+$" html
   #'(lambda (target &rest rest)
       (declare (ignore rest))
       (let* ((href (resolve-symbol-documentation (plump:decode-entities target))))
         (if href
             (format NIL "<a href=\"~a\">~a</a>" href target)
             (format NIL "~a"  target))))))

(define-tag-processor documentate (node)
  (process-attributes node)
  (process-children node)
  ($ node "code"
    (combine (node) (html))
    (map-apply #'(lambda (node html)
                   ($ node (html (parse-lone-symbols (parse-block-symbols html)))))))
  (process-tag "splice" node))

(defmethod clip ((component asdf:component) field)
  (unless (symbolp field)
    (setf field (find-symbol (string field) :STAPLE)))
  (case field
    (name (asdf:component-name component))
    (parent (asdf:component-parent component))
    (system (asdf:component-system component))
    (version (asdf:component-version component))
    (children (asdf:component-children component))
    (encoding (asdf:component-encoding component))
    (loaded-p (asdf:component-loaded-p component))
    (pathname (asdf:component-pathname component))
    (relative-pathname(asdf:component-relative-pathname component))
    (find-path (asdf:component-find-path component))
    (external-format (asdf:component-external-format component))
    (children-by-name (asdf:component-children-by-name component))
    (load-dependencies (asdf:component-sideway-dependencies component))
    (sideway-dependencies (asdf:component-sideway-dependencies component))
    (T (call-next-method))))

(defmethod clip ((system asdf:system) field)
  (unless (symbolp field)
    (setf field (find-symbol (string field) :STAPLE)))
  (case field
    (author (asdf:system-author system))
    (mailto (asdf:system-mailto system))
    (licence (asdf:system-licence system))
    (license (asdf:system-licence system))
    (homepage (asdf:system-homepage system))
    (long-name (asdf:system-long-name system))
    (maintainer (asdf:system-maintainer system))
    (bug-tracker (asdf:system-bug-tracker system))
    (description (asdf:system-description system))
    (source-file (asdf:system-source-file system))
    (registered-p T)
    (source-control (asdf:system-source-control system))
    (long-description (asdf:system-long-description system))
    (source-directory (asdf:system-source-directory system))
    (definition-pathname (asdf:system-source-file system))
    (T (call-next-method))))

(define-tag-processor asdf (node)
  (with-clipboard-bound ((asdf:find-system (resolve-attribute node "system")))
    (plump:remove-attribute node "system")
    (process-attributes node)
    (process-children node)))

(define-tag-processor package (node)
  (let ((name (resolve-attribute node "name")))
    (with-clipboard-bound ((or (find-package name)
                               (find-package (string-upcase name))))
      (plump:remove-attribute node "name")
      (process-attributes node)
      (process-children node))))

(defmethod clip ((symb symb-object) field)
  (case field
    (full-name (format NIL "~a:~a"
                       (package-name (symb-package symb)) (symb-true-symbol symb)))
    (symbol (symb-symbol symb))
    (name (symb-name symb))
    (type (string-downcase (symb-type symb)))
    (scope (symb-scope symb))
    (qualifiers (symb-qualifiers symb))
    (arguments (symb-arguments symb))
    (documentation (symb-documentation symb))))

(define-attribute-processor symbols (node value)
  (let ((package (parse-and-resolve value)))
    (setf (clipboard 'symbols)
          (package-symbol-objects package))
    (process-attribute node "iterate" "symbols"))
  (plump:remove-attribute node "symbols"))

(defun %is-excluded (symb exclude)
  (loop for ex in exclude thereis (symb-is symb (find-symbol (string-upcase ex) "KEYWORD"))))

(define-tag-processor do-symbols (node)
  (let ((package (plump:attribute node "package"))
        (sort (or (plump:attribute node "sort") "#'symb-type<"))
        (exclude (cl-ppcre:split "\\s+" (plump:attribute node "exclude"))))
    (plump:remove-attribute node "package")
    (plump:remove-attribute node "sort")
    (plump:remove-attribute node "exclude")
    (process-attributes node)
    (let ((package (resolve-value (read-from-string package))))
      (process-attribute
       node "iterate"
       (sort
        (remove-if #'(lambda (symb) (%is-excluded symb exclude))
                   (package-symbol-objects package))
        (resolve-value (read-from-string sort)))))))
