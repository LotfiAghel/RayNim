import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import std/sequtils
import std/sugar
import std/times
import std/strformat
from os import existsFile
import ../Components/NodeP
import ../Components/Node


proc spriteRendererCreate*(texture:Texture2D,scale:float=1.0):D3Renderer=
    #var mesh = loadModelFromMesh(makeMesh())
    var t=scale
    t*=0.5;
    var mesh = loadModelFromMesh(makeRectMesh([-float(texture.width)*t,-float(texture.height)*t],[float(texture.width)*t,float(texture.height)*t],[0.0,0.0],[1.0,1.0]))
    #var mesh = loadModelFromMesh(makeRectMesh([0.0,0],[1.0,1.0],[0.0,0.0],[1.0,1.0]))
    mesh.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
    result = D3Renderer(model: mesh)




proc spriteNodeCreate*(texture:Texture2D,scale:float=1.0):GNode=
    
    result=GNode(
                  position: (0.0,0.0, 0.0),
                  transform: scale(1.0, 1.0, 1.0),
                  drawComps: @[
                          spriteRendererCreate(texture,scale).RenderComp,
                          
                  ])