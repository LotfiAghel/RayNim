import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import std/sequtils
import std/sugar
import std/times
import std/strformat
from os import existsFile
import asyncdispatch
import std/tables
import RayNim/funcs/SpriteFunctions
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]



type
 SplinePoint* = object
  pos*: Vector2
  speed*: array[2, Vector2]


proc getPt(p0,p1,p2,p3: Vector2, t: float): Vector2 =
 var tn1 = 1-t
 result = p0*tn1*tn1*tn1 +
     p1*3*t*tn1*tn1 +
     p2*3*t*t*tn1 +
     p3*t*t*t*t

proc getPath(a: seq[SplinePoint], part: int): seq[Vector2] =
 for i in 1..<a.len:
  for j in 0..part:
   var t = j.float/part
   result.add getPt(a[i-1].pos, a[i-1].pos+a[i-1].speed[1], a[i].pos+a[i].speed[0], a[i].pos, t)


  
  
  

