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



proc updateMeshPointFromPath2*(result: var Mesh, path: seq[PathPoint],r2:seq[float], r:seq[float],textR:seq[float], textRatio: float) =


    var d = 0.float
    var prv=path[0].pos
    for i in 0..<path.len:

        var z=(prv-path[i].pos).length
        prv=path[i].pos
        var vrtxH = (i*r.len).cushort
        for j in 0..<r.len:
            var p = path[i].pos+path[i].normal*r[j]*r2[i]
            addT[3, cfloat](result.vertices, vrtxH+cushort(j), [p.x, p.y, 0])
            addT[3, cfloat](result.normals, vrtxH+cushort(j), [cfloat(0), 0, 1])
            addT[2, cfloat](result.texcoords, vrtxH+cushort(j), [d.cfloat, textR[j]])

       
        d = d+textRatio*z
        #vrtxH = vrtxH+cushort(r.len)*2


type
  LineRendererR2* = ref object of LineRenderer0
    reduce*: seq[float]  
    mesh* : Mesh
proc checkMesh*(mesh: ptr Mesh) =
    echo "hi"
proc init2*(self:LineRendererR2,path :seq[PathPoint],reduce,r,txt:seq[float],textRatio:float,texture:Texture2D,isClose=true):bool{. discardable .}=
    self.path=path
    self.reduce=reduce
    

    makeMeshSpaceFromClosePath(self.mesh, path.len,r.len,isClose);

    updateMeshPointFromPath2(self.mesh,path,reduce,r,txt,textRatio)

    updateMeshFacesFromClosePath(self.mesh, path.len, r.len,isClose)
    echo self.mesh
    checkMesh(self.mesh.addr)
    uploadMesh(self.mesh.addr, false)

    self.model= loadModelFromMesh(self.mesh)
    
    self.model.materials[0].maps[0].texture =  texture
    self.tint = White
    return true


