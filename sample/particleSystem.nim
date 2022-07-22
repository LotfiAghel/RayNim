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
import RayNim/funcs/createSprite
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/createSprite
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool


type
 PartNode* = object
  path*: seq[PathPoint]
  time*: seq[float]
  
 LineRendererR2* = ref object of D3Renderer
    discard
proc updateMeshPointFromPath2*(result: var Mesh, path: PartNode, r:seq[float],textR:seq[float], textRatio: float) =


    var d = 0.float
    for i in 0..<path.path.len:

        var vrtxH = (i*r.len).cushort
        for j in 0..<r.len:
            var p = path.path[i].pos+path.path[i].normal*r[j]*sin(d)
            addT[3, cfloat](result.vertices, vrtxH+cushort(j), [p.x, p.y, 0])
            addT[3, cfloat](result.normals, vrtxH+cushort(j), [cfloat(0), 0, 1])
            addT[2, cfloat](result.texcoords, vrtxH+cushort(j), [d.cfloat, textR[j]])

       
        d = d+(3)*textRatio
        #vrtxH = vrtxH+cushort(r.len)*2

