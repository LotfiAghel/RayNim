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
import NimUseFullMacros/ConstructorCreator/[ConstructorCreator,Basic]
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool
import std/tables
import std/marshal
import std/strutils
import std/json
import serialization/object_serialization
import NSrilizer/Srilizer
import ../Basics/Geometry






type 

  PlistPart* = object
    name*:string
    img*:Image
    dstRect*:Rectangle

  PlistNode* = object
    name*:string
    rect*:Rectangle
    dstRect*:Rectangle  # distanation in animation

  Plist* = object
    fn*:string
    img*{.dontSerialize.}:Image
    texture*{.dontSerialize.}:Texture2D
    rect*:Rectangle
    rects*:seq[PlistNode]


  PlistAnimation* = ref object of AnimComp
    plist*:ptr Plist
    frameStep*:float 
    mesh*:ptr Mesh
    isClose*{. dfv(false) .}:bool 






defineToAllP(Rectangle)
defineToAllP(PlistNode)
defineToAllP(Plist)




method update*(self: PlistAnimation) =
  var t=globalTime.value
  var i=(t/self.frameStep).int mod self.plist.rects.len
  echo self.plist.rects[i]
  var rect=self.plist.rects[i]
  self.mesh[].updateRectMesh(
    [rect.dstRect.x.float ,rect.dstRect.y],[rect.dstRect.getX2(),rect.dstRect.getY2()],
    # [-100.0,-100.0],[100.0,100.0],
    [rect.rect.x.float,rect.rect.y],[rect.rect.getX2(),rect.rect.getY2()]
    )
  #[self.mesh[].updateRectMesh(
    [-100.0,-100.0],[100.0,100.0],
    [0.0,0.0],[1.0,1.0]
    )]#
  updateMeshBuffer(self.mesh[], 0, self.mesh.vertices, self.mesh.vertexCount * 3*sizeof(
  cfloat), 0)
  updateMeshBuffer(self.mesh[], 1, self.mesh.texcoords, self.mesh.vertexCount * 2*sizeof(
  cfloat), 0)
  


#[proc trimImg(img:ptr Image)=
  var rect= getImageAlphaBorder(img[],0.1)
  imageCrop(img,rect)]#


  
proc createPlist*(imgs:seq[PlistPart]):Plist=
  var
    h=0
    w=0

  for i in 0..<imgs.len:
    var img=imgs[i]
    echo i ,"w >",img.img.width
    if w < img.img.width:
      w = img.img.width
    h+=img.img.height
  echo w,h
  result.img = genImageColor(w,h,(0,0,0,0))
  #result.img.addr.

  var ih=0
  for img in imgs:
    var dstRect=Rectangle(
          x:0,
          y:ih.cfloat,
          width:img.img.width.cfloat,
          height:img.img.height.cfloat
        )
    result.rects.add PlistNode(
        name:img.name,
        rect:dstRect,
        dstRect:img.dstRect
      )
    ih+=img.img.height
    

  block  optimizeRects:
    discard

  for i in 0..<result.rects.len:
    result.img.addr.imageDraw(imgs[i].img,imgs[i].img.addr.getRect(),result.rects[i].rect,White)
    result.rects[i].rect /= Vector2(x:w.cfloat,y:h.cfloat)
    
    



proc readFromFile*(plist:var Plist,fn:string)=
  let f = open(fn)
  defer: f.close()
  let s = parseJson(f.readLine())

  
  fromJson(plist.addr,s)
