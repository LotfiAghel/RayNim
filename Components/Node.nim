import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import macros
import typeinfo
import std/typetraits
import constructor/constructor
import constructor/defaults
import macros
import ../../macroTools/ConstructorCreator/ConstructorCreator
import ../../macroTools/ConstructorCreator/Basic
type
  Person{.defaults.} = object
    name: string
    age: int


implDefaults(Person)








type
  RenderComp*{.defaults.} = ref object of RootObj
    position*: Vector2
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
    transform*: Matrix
    position*: Vector3
    childs*: seq[GNode]
    parent* : GNode
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
  AnimComp* = ref object of RootObj
    target*: GNode

  OnClick2 = proc(d:DragDataPtr) 
  DragData* = object
    globalStartPosition* :Vector2
    globalCurPosition* :Vector2
    globalEndPosition* :Vector2
    target*: DragArea
    
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
    var z=a.parent.childs.find(a)
    echo z,"/",a.parent.childs.len
    a.parent.childs.delete(z)
    discard
  except:
    echo "aaa"

method update*(a: AnimComp){.base.} =
  echo "AnimComp.update"

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
  ImageRenderer* = ref object of RenderComp
    texture*: Texture2D

  D3Renderer*{.defaults.} = ref object of RenderComp
    model*: Model
    shaderSet*: proc ()
    
  LabelRenderer* = ref object of RenderComp
    text*: string
    font* :Font

#implDefaults(D3Renderer)     


proc myProject(matrix: Matrix, inp: Vector3): Vector2 =
  #matrix.transform()
  var output = inp.transform(matrix)
  #getWorldToScreen
  result = (output.x.float, output.y.float)


method draw*(a: ImageRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  echo "I am ImageRenderer"
  drawTextureV(a.texture, a.position, White)


method draw*(a: D3Renderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  a.model.transform = gtransform
  if not isNil(a.shaderSet):
    a.shaderSet();
  drawModel(a.model, pos, 1.0, a.tint)


method draw*(a: LabelRenderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  var size=measureTextEx(a.font, a.text,(float)a.font.baseSize, 0.0)
  drawTextEx(a.font, a.text, Vector2(x:  -size.x/2,y:  0 ), (float)a.font.baseSize, 0.0, White)
  
  #drawTextPro(a.font, a.text, Vector2(x:  0,y:  0),Vector2(x:  0,y:  0),0, (float)a.font.baseSize, 0.0, White)


