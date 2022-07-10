import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros
import std/random
import ../funcs/createSprite
import NodeP

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

proc init*(self: MaskRenderer, content: Texture2D, stencils: Texture2D) =
  self.content = content
  self.stencils = stencils
  echo "---------load mesh------------"


  var tmp = modelRendererCreate(self.content, 1.0,
      true) # spriteNodeCreate(mask.texture,1.0,true)

            #var target = loadRenderTexture(self.cW , self.cH)
            #var mask = loadRenderTexture(self.cW, self.cH)

  var mask_shader = loadShader(nil, textFormat(
      "resources/shaders/glsl%i/mask2.fs", GLSL_VERSION))

  tmp.materials[0].maps[0].texture = self.content # MATERIAL_MAP_DIFFUSE is now ALBEDO
  tmp.materials[0].maps[1].texture = self.stencils;


  #echo texMask.width
  echo MaterialMapIndex.Albedo.int
  echo MaterialMapIndex.EMISSION.int

  echo mask_shader.getShaderLocation("texture1")
  echo mask_shader.getShaderLocation("texture0")
  mask_shader.locs[0] = mask_shader.getShaderLocation("texture0");
  mask_shader.locs[1] = mask_shader.getShaderLocation("texture1");


  tmp.materials[0].shader = mask_shader;


  self.model = tmp
  #tmp2.position = calcFigmaPostion(nil,mask.texture,(0.0,0.0,-10.1),1.0)


