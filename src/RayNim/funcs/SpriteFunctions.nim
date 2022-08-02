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
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
from nimraylib_now/rlgl as rl import nil
import system
import asyncdispatch

proc isTwoPow(i:int):bool=
    return not bool(i and (i-1) )

proc loadTexture2*(fn:string):Texture2D=
  result=loadTexture(fn)
  genTextureMipmaps(result.addr)
  setTextureFilter(result, 2)
  if result.width.isTwoPow and result.height.isTwoPow:
    rl.textureParameters(result.id, rl.TEXTURE_WRAP_S, rl.TEXTURE_WRAP_REPEAT);
    rl.textureParameters(result.id, rl.TEXTURE_WRAP_T, rl.TEXTURE_WRAP_REPEAT);
  #rl.setTextureWrap()
  echo "genTextureMipmaps--------"


proc loadTextureAsync*(fn:string):Future[Texture2D] {.async.}=
  result=loadTexture(fn)
  genTextureMipmaps(result.addr)
  setTextureFilter(result, 2)
  if result.width.isTwoPow and result.height.isTwoPow:
    rl.textureParameters(result.id, rl.TEXTURE_WRAP_S, rl.TEXTURE_WRAP_REPEAT);
    rl.textureParameters(result.id, rl.TEXTURE_WRAP_T, rl.TEXTURE_WRAP_REPEAT);
  #rl.setTextureWrap()
  echo "genTextureMipmaps--------"
  #return   Future[Texture2D](result)

proc modelRendererCreate*(texture:Texture2D,scale:float=1.0,flipY=false):Model=
    #var mesh = loadModelFromMesh(makeMesh())
    var t=scale
    t*=0.5;
    var mint=[0.0,0.0]
    var maxt=[1.0,1.0]
    if flipY:
        mint[1] = 1.0
        maxt[1] = 0.0
    return loadModelFromMesh(makeRectMesh([-float(texture.width)*t,-float(texture.height)*t],[float(texture.width)*t,float(texture.height)*t],mint,maxt))
    
    
    

proc spriteRendererCreate*(texture:Texture2D,scale:float=1.0,flipY=false):D3Renderer=
    var model = modelRendererCreate(texture,scale,flipY)
    model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
    result = D3Renderer(model: model)
    result.tint=White




proc spriteNodeCreate*(texture:Texture2D,scale:float=1.0,flipY=false):GNode=
    
    result=GNode.Create(
                  position= (0.0,0.0, 0.0),
                  transform= scale(1.0, 1.0, 1.0),
                  drawComps= @[
                          spriteRendererCreate(texture,scale,flipY).RenderComp,
                          
                  ])



proc buttonNodeCreate*(texture:Texture2D,scale:float=1.0,flipY=false):GNode=
    
    result=Button(
                  position: (0.0,0.0, 0.0),
                  transform: scale(1.0, 1.0, 1.0),
                  contentSize:(texture.width.float,texture.height.float),
                  drawComps: @[
                          spriteRendererCreate(texture,scale,flipY).RenderComp,
                  ])
    result.visible=true;