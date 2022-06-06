import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import macros
import typeinfo
import std/typetraits

import macros
import ../../macroTools/ConstructorCreator/ConstructorCreator
import ../../macroTools/ConstructorCreator/Basic
type
  Person = object
    name: string
    age: int











type
  RenderComp* = ref object of RootObj
    position*: Vector2
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

type onClick = proc() 

  


type
  GNode* = ref object of RootObj
    transform*: Matrix
    position*: Vector3
    childs*: seq[GNode]
    parent* : GNode
    drawComps*: seq[RenderComp]
    onUpdate*: seq[AnimComp]
    visible*: bool
  GNode2D* = ref object of GNode
    contentSize*: Vector2
  Button* = ref object of GNode2D
    onClick* : onClick
    btnRect* : BtnRect
  BtnRect* =ref object 
    rect* : Rectangle
    btn*   : Button
  AnimComp* = ref object of RootObj
    target*: GNode

method update*(a: AnimComp){.base.} =
  echo "AnimComp.update"

method clone*(a: AnimComp): AnimComp =
  echo "nothing"

proc addOnUpdate*(t: GNode, a: AnimComp): GNode =
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
        RenderComp] = @[]): GNode =
  GNode(transform: transform, position: position, childs: childs,
          drawComps: drawComps)

type
  LastNode* = ref object of GNode



method draw*(a: RenderComp, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  echo "RenderComp::draw"


type
  ImageRenderer* = ref object of RenderComp
    texture*: Texture2D

  D3Renderer* = ref object of RenderComp
    model*: Model
    shaderSet*: proc ()


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
  drawModel(a.model, pos, 1.0, White)






