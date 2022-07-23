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
import std/tables
import std/marshal
import std/strutils
import std/json
import serialization/object_serialization
import NSrilizer/Srilizer

var designResolution* = Vector2(x:1980.0,y:1080)
var screenWidth* = int(designResolution.x*0.9)
var screenHeight* = int(designResolution.y*0.9)

var circle*:Texture2D

var emptyWhite*:Texture2D



var clickListener* :seq[DragPoint]


designResolution = Vector2(x:screenWidth.float,y:screenHeight.float)
var aspect* = (designResolution.y/designResolution.x).float
var globalScale* = screenHeight*1.0 / designResolution.y;
var globalScaleMatrix* =scale(globalScale,globalScale,globalScale)
var globalScreenPos* :Vector3 = Vector3(x: -screenWidth/2,y: -screenHeight/2,z:0.0) ;

globalScreenPos = Vector3(x: 0,y: 0,z:0.0) ;
#designResolution = Vector2(x:1280.0,y:720)













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

var
 
 backGroundNode:GNode

 
 














var swirlCenter: array[2, cfloat] 
var first:bool=true




proc `/=`(a:var cfloat,n: cint): cfloat{.discardable.}  =
  a = a / n
  return a


proc `/=`(rect:var Rectangle,v: Vector2): Rectangle{.discardable.}  =
  rect.x/=v.x
  rect.y/=v.y
  rect.width/=v.x
  rect.height/=v.y
  result=rect


proc `-=`(rect:var Rectangle,v: Vector2): Rectangle{.discardable.}  =
  rect.x-=v.x
  rect.y-=v.y
  result=rect

var inited=false


type 
  Rectangle2* {.bycopy.} = object
    x* {.importc: "x".}: cfloat  ##  NmrlbNow_Rectangle top-left corner position x
    y* {.importc: "y".}: cfloat  ##  NmrlbNow_Rectangle top-left corner position y
    width* {.importc: "width".}: cfloat ##  NmrlbNow_Rectangle width
    height* {.importc: "height".}: cfloat ##  NmrlbNow_Rectangle height

  MR{.bycopy.}=object
    x*:cfloat

  PlistPart* = object
    name*:string
    img*:Image
    dstRect*:Rectangle

  PlistNode* = object
    name*:string
    mr*:Rectangle2
    rect*:Rectangle
    dstRect*:Rectangle  # distanation in animation

  Plist* = object
    fn*:string
    img*{.dontSerialize.}:Image
    rect*:Rectangle
    rects*:seq[PlistNode]

  PlistAnimation* = ref object of AnimComp
    plist*:Plist
    frameStep*:float 
    mesh*:ptr Mesh
when false:

  var a   = Plist(rects: @[PlistNode(name:"aa",rect:Rectangle(x:11),mr:Rectangle2(x:25))])

  var b=a
  echo a
  echo b

  echo "--"

proc toJson*(t:ptr cfloat):JsonNode =
  return JsonNode(kind:JFloat,fnum:t[].float)

defineToAllP(MR)
defineToAllP(Rectangle2)

defineToAllP(Rectangle)
defineToAllP(PlistNode)
defineToAllP(Plist)


proc getX2(r: Rectangle):float=
  return r.x+r.width

proc getY2(r: Rectangle):float=
  return r.y+r.height

method update*(self: PlistAnimation) =
  var t=globalTime.value
  var i=(t*10).int mod self.plist.rects.len
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
  


proc trimImg(img:ptr Image)=
  var rect= getImageAlphaBorder(img[],0.1)
  imageCrop(img,rect)

proc getRect(img:ptr Image):Rectangle=
  result =  Rectangle(x:0.0,y:0.0,
          width:img.width.cfloat,
          height:img.height.cfloat)
  
proc createPlist(imgs:seq[PlistPart]):Plist=
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
    #discar exportImage(imgs[i].img,fmt"/home/lotfi/programing/nim/RayNim/r/{i}.png")
    result.img.addr.imageDraw(imgs[i].img,imgs[i].img.addr.getRect(),result.rects[i].rect,White)
    result.rects[i].rect /= Vector2(x:w.cfloat,y:h.cfloat)
    echo result.rects[i].rect
    


var plist:Plist
var anim:PlistAnimation
proc initAssets()=
  
  echo "initAssets"
  
  
  
  defaultCamera=camera

  ##  Load models and texture
  
  var winImgs:seq[PlistPart]
  for i in 0..<58:
    var s=intToStr(i,5)
    var part=PlistPart()
    part.name=s
    var tmp=loadImage(fmt"resources/seq/5 _ 1Win/5 _ 1Win_{s}.png")
    #tmp.addr.imageResizeNN(int(tmp.width/2),int(tmp.height/2))
    part.img=tmp
    
    #trimImg(part.img.addr)
    part.dstRect= getImageAlphaBorder(part.img,0.05)
    #loadImageColors(part.img);
    
    #part.dstRect -= Vector2(x:100,y:100)
    echo part.dstRect
    if part.dstRect.width == 0 :
      continue;
    #part.dstRect.x /= part.img.width
    #part.dstRect.y /= part.img.height


    #part.dstRect.width/=part.img.width
    #part.dstRect.height/=part.img.height
    var pos=Vector2(x:part.img.width*0.5,y:part.img.height*0.5)
    part.img.addr.imageCrop(part.dstRect)
    part.dstRect -= pos
    
    echo s
    echo part.img.width , " <> ",part.img.height
    winImgs.add part
      

  plist=createPlist(winImgs) 
  echo exportImage(plist.img,"/home/lotfi/programing/nim/RayNim/p.png")

  circle=loadTextureFromImage(plist.img)

  #circle = loadTexture2("resources/raysan.png")

  

  echo plist
  var z=spriteRendererCreate(circle,1.0,false)

  backGroundNode = GNode.Create(
                  position= (0.0,0.0, 0.0),
                  transform= scale(1.0, 1.0, 1.0),
                  drawComps= @[
                          z.RenderComp,
                          
                  ]).setPostion((0.0,0.0,0.0))

  #z.tint=Blue
  echo toJson(plist.addr)
  anim=PlistAnimation(
    plist:plist,
    frameStep:0.1,
    mesh:z.model.meshes[0].addr
  )
  for i in 0..<plist.rects.len:
    anim.plist.rects[i].rect=plist.rects[i].rect
    anim.plist.rects[i].dstRect=plist.rects[i].dstRect
  echo plist
  echo anim.plist
  backGroundNode.addOnUpdate anim
  #backGroundNode.addChild spriteNodeCreate(circle,0.1).setPostion((100.0,0.0,0.0))


 

 



 



  
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




import macros
dumpTree:
  now().utc



      

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
    
    
    backGroundNode.update()
    
    
    
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
          #allOfGame.visit((0.0,0.0,0.0),scale(1.0,1.0,1.0),camera2D)
          #cardRects.visit(globalScreenPos,globalScaleMatrix,camera2D)  
          backGroundNode.visit(globalScreenPos,globalScaleMatrix,camera2D)  
          #drawTextEx(font, fmt"[{rand(10)} Parrots font drawing]", Vector2(x:  20,y:  20 + 280), (float)font.baseSize, 0.0, White)
 
      


      
      
      
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




