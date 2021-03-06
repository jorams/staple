#|
 This file is a part of Staple
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.tymoonnext.staple)

(defvar *documentation-names* (list "DOCUMENTATION" "documentation"
                                    "README" "readme"))

(defvar *documentation-types* (list "md" "txt" "html" "htm" "xhtml" ""))

(defvar *logo-names* (list "logo" "-logo" ""))

(defvar *logo-types* (list "svg" "png" "jpg" "jpeg" "gif" "bmp"))

(defgeneric parse-documentation-file (type stream))

(defmethod parse-documentation-file (type stream)
  (plump:slurp-stream stream))

(defmethod parse-documentation-file ((type (eql :md)) stream)
  (let ((3bmd-code-blocks:*code-blocks* T))
    (with-output-to-string (string)
      (3bmd:parse-string-and-print-to-stream
       (parse-documentation-file T stream) string))))

(defun find-documentation-file (asdf)
  (let ((dir (asdf:system-source-directory asdf)))
    (when dir
      (dolist (type *documentation-types*)
        (dolist (name *documentation-names*)
          (let ((pathname (make-pathname :name name :type type :defaults dir)))
            (when (probe-file pathname)
              (return-from find-documentation-file pathname))))))))

(defun prepare-documentation (system doc)
  (let ((doc (or doc (find-documentation-file system))))
    (etypecase doc
      (string doc)
      (pathname
       (with-open-file (stream doc :direction :input :if-does-not-exist :error)
         (parse-documentation-file
          (intern (string-upcase (pathname-type doc)) "KEYWORD") stream)))
      (null ""))))

(defun find-logo-file (asdf)
  (let ((dir (asdf:system-source-directory asdf))
        (logo-names (append *logo-names*
                            (mapcar (lambda (name) (concatenate 'string (asdf:component-name asdf) name)) *logo-names*)
                            (mapcar (lambda (name) (concatenate 'string name (asdf:component-name asdf))) *logo-names*))))
    (when dir
      (dolist (type *logo-types*)
        (dolist (name logo-names)
          (let ((pathname (make-pathname :name name :type type :defaults dir)))
            (when (probe-file pathname)
              (return-from find-logo-file pathname))))))))
