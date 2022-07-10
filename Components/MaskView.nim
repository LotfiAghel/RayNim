import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros
import std/random
import ../funcs/createSprite
proc init*(self:MaskRenderer,content:Texture2D,stencils:Texture2D) =
  self.content=content
  self.stencils=stencils      
  echo "---------load mesh------------"
  

  var tmp= modelRendererCreate(self.content,1.0,true) # spriteNodeCreate(mask.texture,1.0,true)
  
  #var target = loadRenderTexture(self.cW , self.cH)
  #var mask = loadRenderTexture(self.cW, self.cH)

  var mask_shader = loadShader(nil, textFormat("resources/shaders/glsl%i/mask2.fs", GLSL_VERSION))
  
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


  self.model=tmp
  #tmp2.position = calcFigmaPostion(nil,mask.texture,(0.0,0.0,-10.1),1.0)              
  

