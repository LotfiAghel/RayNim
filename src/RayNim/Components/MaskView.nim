import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros
import std/random
import ../funcs/SpriteFunctions
import NodeP
import Anim

#[method draw*(a: TextureCameraBuffer, pos: Vector3, gtransform: Matrix,
  camera: Camera) {.inline.} =
a.model.transform = gtransform
if a.dirty or a.drawEveryVisit:
  beginDrawing:
    beginMode3D(a.camera):
      beginTextureMode(a.texture):
        clearBackground((0, 0, 0, 0)) ##  Clear texture background
        a.content.visit((0.0, 0.0, 0.0), a.globalScaleMatrix, a.camera)

      procCall a.D3Renderer.draw(pos, gtransform, camera)]#
proc draw2*(a: TextureCameraBuffer) {.inline.} =
  if a.dirty or a.drawEveryVisit:
    beginMode3D(a.camera):
      beginTextureMode(a.texture):
        clearBackground((0, 0, 255, 255)) ##  Clear texture background
        a.content.visit((0.0, 0.0, 0.0), a.globalScaleMatrix, a.camera)


proc initBuffer*(a: TextureCameraBuffer, cW, cH: int) =
  a.texture = loadRenderTexture(cW, cH)
  a.model = modelRendererCreate(a.texture.texture, 1.0,false) 
  a.model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = a.texture.texture

proc init0*(self: MaskRenderer, content: Texture2D, stencils: Texture2D,shader:Shader) =
  self.content = content
  self.stencils = stencils
  echo "---------load mesh------------"


  var tmp = modelRendererCreate(self.content, 1.0,
      false) # spriteNodeCreate(mask.texture,1.0,true)

            #var target = loadRenderTexture(self.cW , self.cH)
            #var mask = loadRenderTexture(self.cW, self.cH)
  tmp.materials[0].maps[MaterialMapIndex.Albedo.int].texture = content # MATERIAL_MAP_DIFFUSE is now ALBEDO
  self.tint=White
  self.model=tmp
  
  self.maskSahder = shader

  tmp.materials[0].maps[0].texture = self.content # MATERIAL_MAP_DIFFUSE is now ALBEDO
  tmp.materials[0].maps[1].texture = self.stencils;


  #echo texMask.width
  echo MaterialMapIndex.Albedo.int
  echo MaterialMapIndex.EMISSION.int

  echo self.maskSahder.getShaderLocation("texture1")
  echo self.maskSahder.getShaderLocation("texture0")
  self.maskSahder.locs[0] = self.maskSahder.getShaderLocation("texture0");
  self.maskSahder.locs[1] = self.maskSahder.getShaderLocation("texture1");


  tmp.materials[0].shader = self.maskSahder;


  self.model = tmp
  #tmp2.position = calcFigmaPostion(nil,mask.texture,(0.0,0.0,-10.1),1.0)

proc init*(self: MaskRenderer, content: Texture2D, stencils: Texture2D) =
  self.init0( content,stencils,loadShader(nil, textFormat(
      "resources/shaders/glsl%i/mask2.fs", GLSL_VERSION)))
  



proc init*(self: MaskRenderer2, content: Texture2D, stencils: Texture2D,maskSahder:Shader) =

  procCall self.MaskRenderer.init0(content,stencils,maskSahder)
  
  self.fogDensityLoc = getShaderLocation(maskSahder, "fogDensity")
  self.threshold=0.9
  setShaderValue(maskSahder, self.fogDensityLoc, addr(self.threshold), Float)

type
  SetThreshold* = ref object of AnimComp
    valueProvider*: ValueProvider[float]
    renderer*:MaskRenderer2



method update(a :SetThreshold)=
  a.valueProvider.update()
  a.renderer.MaskRenderer2.threshold=a.valueProvider.value
  setShaderValue(a.renderer.maskSahder, a.renderer.fogDensityLoc, addr(a.renderer.threshold), Float)