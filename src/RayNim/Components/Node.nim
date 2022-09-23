import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import macros
import typeinfo
import std/typetraits
import constructor/constructor
import constructor/defaults
import macros
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import NimUseFullMacros/ConstructorCreator/Basic
type
  Person{.defaults.} = object
    name: string
    age: int

when defined(emscripten) :
  const GLSL_VERSION* = 100
else:
  const GLSL_VERSION* = 330

implDefaults(Person)

proc removeVal*[T](self:var seq[T],item:T){.inline.}=
  var t=self.find(item)
  if t > -1:
    self.del t

proc addZ*(p:var Vector2,z:float):Vector3=
  return Vector3(x:p.x,y:p.y,z:z)

proc rmZ*(p:var Vector3):Vector2=
  return Vector2(x:p.x,y:p.y)




type
  RenderComp*{.defaults.} = ref object of RootObj
    position*{. dfv((0.0,0.0,0.0)) .}: Vector3
    tint* {. dfv((255,255,255,255)) .} :Color =White
    visible*{. dfv(true) .} : bool



createConstructor(RenderComp)

var z{.compileTime.}: NimNode



macro getBodySAve(class: typed) =
  echo class.getImpl().treeRepr
  z = class.getImpl()




var defaultCamera*: Camera

type OnClick = proc() 



  


type
  GNode*  = ref object of RootObj
    transform*{. dfv(scale(1.0,1.0,1.0)) .} : Matrix
    position*{. dfv((0.0,0.0,0.0)) .} : Vector3
    childs*: seq[GNode]
    parent*{. dfv(nil) .} : GNode
    drawComps*: seq[RenderComp]
    onUpdate*: seq[AnimComp]
    ccOnUpdate*: seq[CCAnim]
    visible*{. dfv(true) .}: bool
    
  GNode2D* = ref object of GNode
    contentSize*: Vector2

  Button* = ref object of GNode2D
    onClick* : OnClick
    btnRect* : BtnRect

  Dragable* = ref object of GNode2D
    onClick* : OnClick
    onDragMove* : OnClick
    onDragEnd* : OnClick
    btnRect* : BtnRect

  BtnRect* =ref object 
    rect* : Rectangle
    btn*   : Button

  DragArea* =ref object 
    rect* : Rectangle
    btn*   : GNode
    onStart* : OnClick2
    onMove* : OnClick2
    onEnd* : OnClick2

  DragPoint* =ref object 
    pos* : Vector3
    btn*   : GNode
    onStart* : OnClick2
    onMove* : OnClick2
    onEnd* : OnClick2

  AnimComp* = ref object of RootObj
    target*: GNode
    finished*{. dfv(false) .}:bool
    
  CCAnim* = ref object of AnimComp
    time* :float



  AnimCompTimed* = ref object of AnimComp
    discard

  OnClick2 = proc(d:DragDataPtr) 
  
  DragData* = object
    globalStartPosition* :Vector2
    globalCurPosition* :Vector2
    globalEndPosition* :Vector2
    target*: DragPoint
    
  DragDataPtr* = ref DragData
  

#implDefaults(GNode) 
#createConstructor(GNode)
#create_GNode()
#[proc init(T: typedesc[GNode], name: string, age: int): GNode {.constr.} =
  result]#


#[macro init(T: typedesc[GNode], name: string, age: int): NimNode  =
  let args = callsite()]#
#initGNode()

proc delete*[T](x: var seq[T], item: T) {.noSideEffect.} =
  var z=x.find(item)  
  if z != -1 :
    x.delete(z)

method removeFromParent*(a:GNode){.base.}=
  try:
    if a.parent.isNil:
      return;
    a.parent.childs.delete(a)
  except:
    echo "aaa"

method update*(a: AnimComp){.base.} =
  echo "AnimComp.update"


method update*(a: AnimCompTimed) =
  echo "AnimCompTimed.update"

method clone*(a: AnimComp): AnimComp =
  echo "nothing"

method setTarget*(self: AnimComp,target:GNode){.base.} =
  self.target=target;
  
proc addOnUpdate*(t: GNode, a: AnimComp): GNode{.discardable.}  =
  a.setTarget(t);
  t.onUpdate.add a
  return t

proc addChild*(t: GNode, a: GNode): GNode {.discardable.} =
  t.childs.add a
  a.parent=t
  return t





proc newGNode*(transform: Matrix = scale(1.0, 1.0, 1.0),
        position: Vector3 = (
        0.0, 0.0, 0.0), childs: seq[GNode] = @[], drawComps: seq[
        RenderComp] = @[],
        visible=true): GNode =
  GNode(transform: transform, position: position, childs: childs,
          drawComps: drawComps,visible:visible)

type
  LastNode* = ref object of GNode



method draw*(a: RenderComp, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  echo "RenderComp::draw"

type
    PathPoint* = object
        pos*: Vector2
        normal*: Vector2
    MyVec[T, N: static[int]] = array[N, int]

type
  ImageRenderer* = ref object of RenderComp
    texture*: Texture2D
    

  D3Renderer*{.defaults.} = ref object of RenderComp
    model*: Model
    disableDepth*:bool
    shaderSet*: proc ()

  MaskRenderer*{.defaults.} = ref object of D3Renderer
    content *:Texture2D 
    stencils *:Texture2D 
    maskSahder* :Shader
  

  MaskRenderer2*{.defaults.} = ref object of MaskRenderer
    fogDensityLoc* : cint
    threshold*: cfloat
    

  TextureCameraBuffer*{.defaults.} = ref object of D3Renderer
    content* : GNode 
    camera* :Camera3D
    texture* : RenderTexture2D
    drawEveryVisit*,dirty* :bool
    globalScaleMatrix* :Matrix
    
  LineRenderer0*{.defaults.} = ref object of D3Renderer
    path* :seq[PathPoint]

  LineRenderer*{.defaults.} = ref object of LineRenderer0
    discard

  IconRenderer*{.defaults.} = ref object of D3Renderer
    discard

  LabelRenderer* = ref object of RenderComp
    text*: string
    font* :Font

    size*{. dfv(1.0).}:float
    spacing*{. dfv(0.0).}:float



#implDefaults(D3Renderer)     
proc setTexture*(self:D3Renderer,texture:Texture2D):D3Renderer {. discardable.}=
  self.model.materials[0].maps[0].texture =  texture

proc getMesh*(self:D3Renderer):ptr Mesh {. discardable.}=
  return self.model.meshes[0].addr

proc myProject(matrix: Matrix, inp: Vector3): Vector2 =
  #matrix.transform()
  var output = inp.transform(matrix)
  #getWorldToScreen
  result = (output.x.float, output.y.float)


method draw*(a: ImageRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  drawTextureV(a.texture, a.position.rmZ(), White)







method draw*(a: LabelRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  var size=measureTextEx(a.font, a.text,(float)a.font.baseSize*a.size, 0.0)
  rl.disableDepthMask()   
  rl.disableDepthTest()
  drawTextEx(a.font, a.text, Vector2(x:  pos.x+a.position.x-size.x/2,y:  pos.y+a.position.y-size.y/2 ), (float)a.font.baseSize*a.size, a.spacing, a.tint) #a.tint
  
  #drawText3D(a.font, a.text, Vector2(x:  pos.x+a.position.x-size.x/2,y:  pos.y+a.position.y-size.y/2 ), (float)a.font.baseSize*a.size, a.spacing, 0.0, false, a.tint);
  #drawText(a.font, a.text,  pos.x+a.position.x-size.x/2,  pos.y+a.position.y-size.y/2 , (float)a.font.baseSize*a.size,  a.tint) #a.tint
  rl.enableDepthMask()   
  rl.enableDepthTest()
  #drawTextPro(a.font, a.text, Vector2(x:  0,y:  0),Vector2(x:  0,y:  0),0, (float)a.font.baseSize, 0.0, White)


template ForLoop*(time:untyped,l:float,r:float,dtTime:float,body:untyped)=
  block:
    var time=l
    
    var n:int=int(dtTime*60)
    for i in 0..n :
        body
        #yield 0
        time += (r-l)/n

    time=r;
    body

template ForLoopY*(time:untyped,l:float,r:float,dtTime:float,body:untyped)=
  block:
    var time=l
    
    var n:int=int(dtTime*60)
    for i in 0..n :
        body
        yield false
        time += (r-l)/n

    time=r;
    body
    yield false




template ForLoop11*(index:untyped,list:seq[typed],body:untyped)=
  block:
    var index=0
    
    var n:int=int(dtTime*60)
    for i in 0..n :
        body
        #yield 0
        time += (r-l)/n

    time=r;
    body



