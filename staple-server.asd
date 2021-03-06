#|
 This file is a part of Staple
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:cl-user)
(asdf:defsystem staple-server
  :name "Staple Documentation Server"
  :version "0.0.1"
  :license "Artistic"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "A web server serving documentation generated by Staple."
  :homepage "https://github.com/Shinmera/staple"
  :serial T
  :components ((:file "server"))
  :depends-on (:staple
               :hunchentoot))
