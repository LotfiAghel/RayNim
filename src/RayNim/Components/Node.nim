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



proc addZ*(p:var Vector2,z:float):Vector3=
  return Vector3(x:p.x,y:p.y,z:z)

proc rmZ*(p:var Vector3):Vector2=
  return Vector2(x:p.x,y:p.y)




type
  RenderComp*{.defaults.} = ref object of RootObj
    position*: Vector3
    tint* :Color =White
    #visible*{. dfv(true) .} : bool



createConstructor(RenderComp)

var z{.compileTime.}: NimNode



macro getBodySAve(class: typed) =
  echo class.getImpl().treeRepr
  z = class.getImpl()


proc someProcThatMayRunInCompileTime(): bool =
  when nimvm:
    # This branch is taken at compile time.
    result = true
  else:
    # This branch is taken in the executable.
    result = false

getBodySAve(RenderComp)

#[proc MyNew_RenderComp(visible:bool=true):RenderComp=
  return RenderComp(visible:visible)]#

#[
macro getImp2(t:type):NimNode=
  return t.getImpl()
static:
  var class = z
  echo class.treeRepr
  echo "----"
  when someProcThatMayRunInCompileTime():
    echo "aaa"
  template getFunc(T:NimNode): untyped=
    proc MyNew_RenderComp2():T=
      discard

    template getFuncParm(T:NimNode): untyped=
      x:T

    var x = getAst(getFunc(RenderComp))

    for i in getReclist(class):
      echo "......."

      echo i.treeRepr
      if(i[0].kind == nnkPragmaExpr):
        echo "======="
        echo i[0][1][0][1].treeRepr
        x[3].add(getAst(getFuncParm(RenderComp)))
      echo x.treeRepr
      echo getAst(getImp2(MyNew_RenderComp)).treeRepr

    ]#
proc aaa() =
  echo "aaa"



var zz: NimNode = z


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

method removeFromParent*(a:GNode){.base.}=
  try:
    if a.parent.isNil:
      return;
    var z=a.parent.childs.find(a)
    echo z,"/",a.parent.childs.len
    
    a.parent.childs.delete(z)
  except:
    echo "aaa"

method update*(a: AnimComp){.base.} =
  echo "AnimComp.update"


method update*(a: AnimCompTimed) =
  echo "AnimCompTimed.update"

method clone*(a: AnimComp): AnimComp =
  echo "nothing"

proc addOnUpdate*(t: GNode, a: AnimComp): GNode{.discardable.}  =
  a.target = t;
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

#implDefaults(D3Renderer)     
proc setTexture*(self:D3Renderer,texture:Texture2D):D3Renderer {. discardable.}=
  self.model.materials[0].maps[0].texture =  texture

proc myProject(matrix: Matrix, inp: Vector3): Vector2 =
  #matrix.transform()
  var output = inp.transform(matrix)
  #getWorldToScreen
  result = (output.x.float, output.y.float)


method draw*(a: ImageRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  echo "I am ImageRenderer"
  drawTextureV(a.texture, a.position.rmZ(), White)







method draw*(a: LabelRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  var size=measureTextEx(a.font, a.text,(float)a.font.baseSize*a.size, 0.0)
  drawTextEx(a.font, a.text, Vector2(x:  -size.x/2,y:  -size.y/2 ), (float)a.font.baseSize*a.size, 0.0, White) #a.tint
  
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



