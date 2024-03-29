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
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool




var designResolution* = Vector2(x:1980.0,y:1080)
var screenWidth* = int(designResolution.x*0.9)
var screenHeight* = int(designResolution.y*0.9)


designResolution = Vector2(x:screenWidth.float,y:screenHeight.float)
var aspect* = (designResolution.y/designResolution.x).float
var globalScale* = screenHeight*1.0 / designResolution.y;
var globalScaleMatrix* =scale(globalScale,globalScale,globalScale)
var globalScreenPos* :Vector3 = Vector3(x: -screenWidth/2,y: -screenHeight/2,z:0.0) ;

globalScreenPos = Vector3(x: 0,y: 0,z:0.0) ;
#designResolution = Vector2(x:1280.0,y:720)

import fView



      













var clickListener* :seq[DragPoint]


















setConfigFlags(Msaa_4x_Hint)

##  Enable Multi Sampling Anti Aliasing 4x (if available)
var tmpZ=1#.5
initWindow(int(screenWidth*tmpZ), int(screenHeight*tmpZ), "raylib [shaders] example - fog")
##  Define the camera to look into our 3d world
var zarib=0.5;
var camera = Camera3D(
    position: (0.0, 0.0, -screenHeight*0.5),
    target: (0.0, 0.0, 0.0),
    up: (0.0, -1.0, 0.0),
    fovy: 90.0,
    projection: Perspective
  )
var camera2D = Camera3D(
    position: (0.0, 0.0, -screenHeight*zarib),
    target: (0.0, 0.0, 0.0),
    up: (0.0, -1.0, 0.0),
    fovy: 90.0,
    projection: PERSPECTIVE
  )


 
 

 
 














var swirlCenter: array[2, cfloat] 
var first:bool=true

import std/tables




var 
    time=0.0


var inited=false

var view=View.Create()

proc initAssets()=
  
  echo "initAssets"
  
  
  
  defaultCamera=camera

  ##  Load models and texture
  
  
  emptyWhite = loadTexture2("resources/w.png")
  circle = loadTexture2("resources/raysan.png")

  

  
  
  view.init()  
  
  



 



  
  ##  Using just 1 point lights
  setCameraMode(camera2D, FREE)
  setCameraMode(camera, FREE)
  camera.position = (0.0,0.0,-1.0)
  #discard camera.lookAt((0.0,0.0,-1.0),(0.0,0.0,0.0),(0.0,1.0,0.0))
  ##  Set an orbital camera mode
  setTargetFPS(60)
  ##  Set our game to run at 60 frames-per-second
  ## --------------------------------------------------------------------------------------
  ##  Main game loop




      

var ddata : DragDataPtr =nil

var zz=0.0#camera2D.target.z
var
    g0= Vector3(x: 1000000.0,y: 1000000.0,z:zz)
    g1= Vector3(x: 1000000.0,y: -1000000.0,z:zz)
    g2= Vector3(x: -1000000.0,y: -1000000.0,z:zz)
    g3= Vector3(x: -1000000.0,y: 1000000.0,z:zz)
proc getGroundPostion(pos:Vector2):Vector3=
  var ray = getMouseRay(pos, camera2D);
  var dz = ray.position.z/ray.direction.z 
  #var gp=ray.position-ray.direction*dz

  var groundHitInfo = getRayCollisionQuad(ray, g0, g1, g2, g3);
  result=groundHitInfo.point
var gorundPostion:Vector3
var matrix:Matrix
proc getScreenPostion(pos:Vector3):Vector2=
  discard


var allDrag=DragPoint(
        onStart: proc(d:DragDataPtr)=
          echo "allDrag.onStart"
          #cameraPoint=camera2D.target
          gorundPostion = d.globalCurPosition.addZ(0.0) #getGroundPostion(d.globalCurPosition)
          #matrix=camera2D.getCameraMatrix()
        ,
        onMove: proc(d:DragDataPtr)=
          #var gorundPostion = getGroundPostion(d.globalStartPosition)
          var gorundPostion2 = d.globalCurPosition.addZ(0.0)
          #var tmp=getScreenPostion(gorundPostion)

          #var cameraPoint = d.globalCurPosition

          camera2D.target -= gorundPostion2-gorundPostion
          camera2D.position -= gorundPostion2-gorundPostion

          
          
          #t.rect.y=d.globalCurPosition.y
      )

initAssets()

proc UpdateGameWindow() {.cdecl.} =
  echo "UpdateGameWindow"
  try:
 
    
    

   
    
    var mousePosition: Vector2 = getMousePosition()
    var mouseWheel=getMouseWheelMove()
    var moseGround=getGroundPostion(mousePosition)
    #moseGround=gp
    if camera2D.projection == Perspective:
      if(mouseWheel<0):
        

        #pZ = pZ*0.9
        
        
        camera2D.position = camera2D.position*0.9+moseGround*0.1
        camera2D.target = camera2D.target*0.9+moseGround*0.1
        #camera2D.position.z = camera2D.position.z*1.1
        

      if(mouseWheel>0):
        #pZ = pZ*1.1
        
        camera2D.position = camera2D.position*1.1+moseGround*(-0.1)
        camera2D.target = camera2D.target*1.1+moseGround*(-0.1)
        #camera2D.position.z = camera2D.position.z*0.9
        #camera.position = (0.0,0.0,-1.0)
        
    else:
      if(mouseWheel<0):
        camera2D.fovy = camera2D.fovy*0.9
        camera2D.target = camera2D.target*0.9+moseGround*(0.1)
      if(mouseWheel>0):
        camera2D.fovy = camera2D.fovy*1.1
        camera2D.target = camera2D.target*1.1+moseGround*(-0.1)

    swirlCenter[0] = mousePosition.x
    swirlCenter[1] = screenHeight.float - mousePosition.y
    ##  Send new value to the shader to be used on drawing


    globalTime.value+=0.017
    
    
    view.update()
    
    
    
    beginDrawing:
      clearBackground(Gray)
      
      
      var zdis= -camera2D.position.z
      
      if isMouseButtonDown(MouseButton.Left) and ddata.isNil:
        var minDis:cfloat=10000;
        var minDA:DragPoint=nil
        for  rect in clickListener:
          echo moseGround
          var dis= distance(moseGround,rect.pos)
          if dis < zdis*0.05 and dis<minDis:
              minDis = dis
              minDA=rect
        if not minDA.isNil:
          minDA.btn.transform=scale(1.05,1.05,1.0)
          ddata =  DragDataPtr(globalStartPosition:moseGround.rmZ(),globalCurPosition:moseGround.rmZ(),target:minDA)
          ddata.target.onStart(ddata)
        else:
          #discard
          ddata =  DragDataPtr(globalStartPosition:moseGround.rmZ(),globalCurPosition:moseGround.rmZ(),target:allDrag)
          ddata.target.onStart(ddata)

      
      if (isMouseButtonReleased(MouseButton.Left)):
        if not ddata.isNil:
          if not ddata.target.onEnd.isNil:
            ddata.target.onEnd(ddata)
          ddata = nil

      
      if not ddata.isNil and ddata.target != allDrag :
        ddata.globalCurPosition = moseGround.rmZ()
        ddata.target.onMove(ddata)

      if not ddata.isNil and ddata.target == allDrag :
        ddata.globalCurPosition = moseGround.rmZ()
        ddata.target.onMove(ddata)

      
      
      


      
      when true:  
        myBeginMode3D(camera2D,1.0/aspect,-camera2D.position.z*0.5,-camera2D.position.z*1.5): ##  Begin 3d mode drawing
          clearBackground((0,0,0,0))
         
          view.visit(globalScreenPos,globalScaleMatrix,camera2D)  
         
 
      


      
      
      
      #drawTextEx(font, "[3 Parrots font drawing]", Vector2(x:  20, y:  20 + 280), (float)font.baseSize, 0.0, White)
  except : 
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg
    echo "I Got Error"
  echo "</UpdateGameWindow>"


proc main0*() =


  
  while not windowShouldClose():
      UpdateGameWindow()
 
  closeWindow()
  

when isMainModule: main0()




