import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import NodeP
import ../../NimUseFullMacros/macroTool
import std/random

import Anim
type  
  MeshElectirc* = ref object of AnimComp
    time*: ValueProvider[float]
    path*: seq[PathPoint]
    path0*: seq[PathPoint]
    position:seq[float]
    vel:seq[float]
    left*,right*:float
    mesh*: ptr Mesh
    radiusPoints*: seq[float]
    txtRadiusPoints*: seq[float]
    textRatio*: float



proc getRandomSeq*(rands:var seq[float],n:int,l,r:float,rate:int)=
  rands.setLen n;
  for i in 0..<n :
    if(rand(rate)==1):
      rands[i]= rand(r)

proc randRange(l,r:float):float=
  return l+rand(r-l)

proc getRandomSeq2*(rands:var seq[float],pos:var seq[float],n:int,rate:int,l,r:float)=
  rands.setLen n;
  for i in 0..<n :
    if pos[i]<l :
        pos[i] = l
        rands[i] = 10.0
    if(rand(rate)==0):
      #pos[i]-l --  r-pos[i]
      var t=randRange(l,r)
      rands[i]= (t-pos[i])*0.3
      
      #[if t<pos[i]:
        rands[i]= -randRange(t,pos[i])
      else:
        rands[i]= randRange(pos[i],t)]#
        
method update*(a: MeshElectirc) =
  a.time.update()
  var t = a.time.value
  
  var n=a.path.len;
  a.path0.setLen(n)
  a.position.setLen(n)
  #if(t<0.1):
  a.vel.getRandomSeq2(a.position,n,1,a.left,a.right)
  for i in 0..<n:
    a.position[i] += a.vel[i]
    a.path0[i].pos = a.path[i].pos + a.path[i].normal*a.position[i]#*sin(t) #*(1-t);
    a.path0[i].normal = a.path[i].normal
    
  #for i in 0..<n:
  #  a.path[i].pos = a.path[i].pos + a.path[i].normal*((rand(2.0)-1.0)*10);

  updateMeshPointFromPath(a.mesh[], a.path0, a.radiusPoints,a.txtRadiusPoints, a.textRatio)
  updateMeshBuffer(a.mesh[], 0, a.mesh.vertices, a.mesh.vertexCount * 3*sizeof(
      cfloat), 0)
      