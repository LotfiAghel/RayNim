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
import RayNim/CameraTool
import std/tables
import std/marshal
import std/strutils
import std/json
import serialization/object_serialization
import NSerializer/Serializer
import RayNim/Components/SpriteSheet
import RayNim/Basics/Geometry
import RayNim/Components/CocoAnim as co

var gnode:GNode

#gnode.AddAction[Vector3,SetPostion](EseMasaln(LinearProvider[Vector3,float].Create()));



#gnode.AddAction(EaseIn(MoveTo(3.0,(0.0,0.0))))
#gnode.AddAction(3.0,postion, _ ,(0.0,0.0))
gnode.addAction(
    co.Timer(time:2,MoveTo(finish:(0.0,0.0,0.0)))
)

#[gnode.AddAction(
    seq(
        @[(
            onStart: node => node.
            Session:Liner[float,Vector3](
                sp:(0.0,0.0,0.0),
                ep:(10.0,10.0,0.0),
            ),
            timeProvider:EaseIn(startFromNow(10)),
            seter:postion
          ),
        ]
    )

)]#

#[gnode.AddAction(
    Session:Circle(
        reduis:10.0,
    ),
    timeProvider:EaseIn(startFromNow(10)),
)]#

#gnode.AddAction(Seq(EaseIn(MoveTo(3.0,(0.0,0.0))),ScaleTo(10,(2.0,2.0,2.0))))
