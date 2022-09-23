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
import NimUseFullMacros/ConstructorCreator/Basic
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool


type
  LineRendererR2* = ref object of D3Renderer
    reduce*: proc(idx:int,j:int,dis:float):float
    mesh* : Mesh

  FlameMovement* = ref object of GNode
    lineRender*:LineRendererR2

  GridPostion = object  
    i*,j*:int
    dis*:float

  #MyLinearProvider* = ref object of LinearProvider[float]  

  ReduceProvider* = ref object of ProviderConvertor[float,float]
    
  ReduceProvider2* = ref object of ReduceProvider

  GridMeshAnimator*  =ref object of AnimCompFloatSource
    line*: LineRendererR2
    reduce2*:ReduceProvider
    path*:seq[PathPoint]
    textR* {. dfv(@[0.0,1.0]) .}:seq[float]


method update(a:ReduceProvider)=
    a.valueSource.update()

method getValue(a:ReduceProvider,idx:GridPostion):float{.base.}=
    return 0.0

method getValue(a:ReduceProvider2,idx:GridPostion):float=
    var tt= -idx.dis*0.01+a.valueSource.value
    if tt<0.001:
      tt=1.0
    
    var t=sin(sqrt(tt*10))
    t*=t
    return t * 20 * (@[-1.0,1.0])[idx.j]*(idx.dis/1000+1)*0.5


proc updateMeshPointFromPath2*(result: var Mesh, path: seq[PathPoint],r2:ReduceProvider,textR:seq[float], textRatio: float) =


    var d = 0.float
    echo path.len
    var prv=path[0].pos
    for i in 0..<path.len:

        
        var vrtxH = (i*textR.len).cushort
        for j in 0..<textR.len:
            var p = path[i].pos+path[i].normal*r2.getValue(GridPostion(i:i,j:j,dis:d))
            addT[3, cfloat](result.vertices, vrtxH+cushort(j), [p.x, p.y, 0])
            addT[3, cfloat](result.normals, vrtxH+cushort(j), [cfloat(0), 0, 1])
            addT[2, cfloat](result.texcoords, vrtxH+cushort(j), [d.cfloat, textR[j]])

        var z=(prv-path[i].pos).length
        prv=path[i].pos
        d = d+textRatio*z
        #vrtxH = vrtxH+cushort(r.len)*2


method update(self:GridMeshAnimator)=
    #var time=self.time.value
    self.reduce2.update()
    updateMeshPointFromPath2(
        self.line.mesh,
        self.path,
        self.reduce2
    ,self.textR,1.0)
    updateMeshBuffer(self.line.model.meshes[0], 0, self.line.model.meshes[0].vertices, self.line.model.meshes[0].vertexCount * 3*sizeof(
      cfloat), 0)








proc init2*(self:LineRendererR2,n,m:int,textRatio:float,isClose=true):bool{. discardable .}=
    #self.path=path
    
    

    makeMeshSpaceFromClosePath(self.mesh,n,m,isClose);


    updateMeshFacesFromClosePath(self.mesh,n,m,isClose)
    echo self.mesh

    uploadMesh(self.mesh.addr, false)

    self.model= loadModelFromMesh(self.mesh)
    
    
    return true


