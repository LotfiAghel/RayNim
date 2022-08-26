import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import std/sequtils
import std/sugar

import std/strformat
import std/tables
import RayNim/funcs/SpriteFunctions
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool
import std/tables
import std/marshal
import std/strutils
import std/json
import serialization/object_serialization
import NSerializer/Serializer



proc `/=`*(a:var cfloat,n: cint): cfloat{.discardable.}  =
  a = a / n
  return a


proc `/=`*(rect:var Rectangle,v: Vector2): Rectangle{.discardable.}  =
  rect.x/=v.x
  rect.y/=v.y
  rect.width/=v.x
  rect.height/=v.y
  result=rect


proc `-=`*(rect:var Rectangle,v: Vector2): Rectangle{.discardable.}  =
  rect.x-=v.x
  rect.y-=v.y
  result=rect



proc getX2*(r: Rectangle):float=
  return r.x+r.width

proc getY2*(r: Rectangle):float=
  return r.y+r.height

proc toJson*(t:ptr cfloat):JsonNode =
  return JsonNode(kind:JFloat,fnum:t[].float)

proc fromJson*(T:typedesc[cfloat];t:ptr cfloat,js:JsonNode) =
  t[]=js.fnum.cfloat

proc fromJson*(t:ptr cfloat,js:JsonNode) =
  t[]=js.fnum.cfloat




proc getRect*(img:ptr Image):Rectangle=
  result =  Rectangle(x:0.0,y:0.0,
          width:img.width.cfloat,
          height:img.height.cfloat)

