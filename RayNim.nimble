# Package

version       = "0.1.1"
author        = "FTH"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir = "src"
backend             = "c"

requires "nim >= 1.4.2" 
requires  "nimraylib_now"
requires "NimUseFullMacros"


from os import `/`, parentDir


task hello, "This is a hello task":
  echo("Hello World!")

before hello:
  echo("About to call hello!")
