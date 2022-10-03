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
import PathTool

var circle*:Texture2D
var emptyWhite*:Texture2D

type
    View* = ref object of GNode
        backGroundNode:GNode



proc init*(self:View)=
  self.backGroundNode = spriteNodeCreate(circle).setPostion((0.0,0.0,0.0))
 
  self.backGroundNode.addChild spriteNodeCreate(circle,0.1).setPostion((100.0,0.0,0.0))



 
 
  


  self.addChild self.backGroundNode


  var rectPoint:seq[Vector2] = @[Vector2(x: -1.0,y: -1.0),(-1.0,+1.0),(+1.0,+1.0),(+1.0,-1.0),]

  var rectPath=getPathPoints(rectPoint)

  var line = D3Renderer.Create()
  self.backGroundNode.drawComps.add line
  
  when true :
    line.addOnUpdate (
      MeshProvider(
          LineMesh.Create(
            path=PathSlicer.Create(
              path=RoundPath.Create(
                path=RectPath.Create(width=startFromNow(),hight=startFromNow()),
                radius=startFromNow(),
              ),
              start =startFromNow(),
              finish = startFromNow()
            ),
            radius=  @[-10.0,10.0]
          )
      )

    )
    

