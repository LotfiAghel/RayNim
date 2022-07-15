import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import NodeP
import ../../NimUseFullMacros/macroTool
import std/random
#######################3
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
proc countTo(n: int): iterator(): int =
  return iterator(): int =
    var i = 0
    while i <= n:
      yield i
      inc i

let countTo20: iterator(): int = countTo(20)

echo countTo20()
######




type
  ValueProvider0 = ref object of RootObj
  ValueProvider*[T] = ref object of ValueProvider0
    value*: T
  CorutineHandler* = ref object of AnimComp
    provider*: iterator(): bool
  CoroutineListHandler* = ref object of AnimComp
    providers*: seq[iterator(): bool]

  MoveTo* = ref object of AnimComp
    provider*: ValueProvider[Vector3]

  SetTransformTo* = ref object of AnimComp
    scaleProvider*: ValueProvider[Vector3]
    rotateProvider*: ValueProvider[Vector3]

  SetTintTo* = ref object of AnimComp
    scaleProvider*: ValueProvider[Color]
    

  TimeProvider* = ref object of ValueProvider[float]
  TimeRange* = ref object of ValueProvider[float]
    zeroPoint*: float
    endPoint*: float
    valueSource*: ValueProvider[float]
  TimeShift* = ref object of ValueProvider[float]
    shiftValue*: float
    valueSource*: ValueProvider[float]
  SinEfect* = ref object of ValueProvider[float]
    valueSource*: ValueProvider[float]
  SinEfect2* = ref object of ValueProvider[float]
    valueSource*: ValueProvider[float]
    innerMult*: float
    outerMult*: float
    outerPlus*: float


  LinearProvider*[T] = ref object of ValueProvider[T]
    time*: ValueProvider[float]
    endPosition*: T
    start*: T
    

  ConstProvider*[T] = ref object of ValueProvider[T]
  CustomCall* = ref object of AnimComp
    funct*:proc()

  MeshProvider* = ref object of AnimComp
    path*: seq[PathPoint]
    mesh*: Mesh
    rProvider*: ValueProvider[float]
    lProvider*: ValueProvider[float]
    textRatio*: float


  FrameData = object
    time_end*: float
    mesh*: RenderComp
  FrameSequence* = ref object of AnimComp
    valueSource*: ValueProvider[float]
    startTime*: float
    activeMeshIdx*: int
    frames*: seq[FrameData]


var p_p: ValueProvider[float] = LinearProvider[float](time: ConstProvider[float](value: 0), endPosition: 0.0,
      start: 0.0)
var p_p2: ValueProvider[Vector3] = LinearProvider[Vector3](time: ConstProvider[float](value: 0), endPosition: (0.0, 0.0, PI/2),
      start: (0.0, 0.0, 0.0))


method update(a: ValueProvider0){.base.} =
  discard
  #echo "ValueProvider0.update"


method update*(a: ValueProvider[float]) =
  discard

method clone[T](a: ValueProvider[T]): AnimComp {.base.} =
  echo "nothing"

template AnimCompCreator(name, valueSeter, valueProvider) =
  type
    name* = ref object of AnimComp
      provide*: valueProvider
  method update*(a: name) =
    #a.time += dt;
    valueSeter(a.target, a.provide.value)






method update*(a: TimeRange) =
  var tt = a.valueSource.value
  a.value = (tt-a.zeroPoint)/(a.endPoint-a.zeroPoint)

method update*(a: TimeShift) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = tt+a.shiftValue
  
method update*(a: SinEfect) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*3.14*2/50)



method update*(a: SinEfect2) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*PI*2*a.innerMult)*a.outerMult+a.outerPlus


proc newVector3*(x,y,z:float):Vector3=
  return Vector3(x:x,y:y,z:z);

proc setPostion*(a: GNode, value: Vector3):GNode{.inline , discardable.} =
  result=a;
  a.position = value




proc setPostion*(a: GNode, value: array[3,float]):GNode{.inline , discardable.} =
  result=a;
  a.position = (value[0],value[1],value[2])

proc setPostion*(a: GNode, value: Vector2):GNode{.inline , discardable.} =
  result=a;
  a.position.x = value.x
  a.position.y = value.y
  


#AnimCompCreator(FastMoveTo, setPostion, LinearProvider)
#AnimCompCreator(FastRotateTo, setRotation, LinearProvider)
var logPrint* = false
#var logNumbers*[T]=0
template ForLoop22(time: NimNode, l: int, r: int, body: untyped) =
  block:
    for i in l..<r:
      body

import macros
var z{.compileTime.} = 0


template typeDeclPub(a: untyped, b): untyped =
  type a* = ref object of b
typeDeclPub(bb, RootObj)




macro SetNumber*(a: type): untyped =
  template createVar(ab: NimNode): untyped =
    var ab*: int

  var tt = "GetNumber__" & $$$(a)
  echo tt
  var z = getAst(createVar(newIdentNode(tt)))
  #echo z.treeRepr
  #z.child
  return z



macro GetNumber*(a: type): untyped =
  template getVar(ab: NimNode): untyped =
    ab
  var tt = "GetNumber__" & $$$(a)
  echo "get ", tt
  return getAst(getVar(newIdentNode(tt)))


SetNumber(LinearProvider[LinearProvider[Vector3]])

macro SetNumbers*(a: varargs[type]): seq[int] =
  echo "salam"




#SetNumbers(float,float)


#[method update*(a: LinearProvider[Vector3]) =
  a.time.update()
  var tt = a.time.value;
  a.value = a.start * (1-tt) + a.endPosition * tt
  GetNumber(Vector3) = GetNumber(Vector3) + 1

method update*(a: LinearProvider[float]) =
  a.time.update()
  var tt = a.time.value;
  a.value = a.start * (1-tt)+a.endPosition * tt
  #if logPrint:
  #  echo a.start,a.endPosition,a.value
  GetNumber(float) = GetNumber(float) + 1]#



template declUpdate(T: type) =
  SetNumber(T)
  method update*(a: LinearProvider[T]) =
    a.time.update()
    var tt = a.time.value;
    a.value = a.start * (1-tt) + a.endPosition * tt
    GetNumber(T) = GetNumber(T) + 1


declUpdate(float)
declUpdate(Vector3)

SetNumber(Color)
method update*(a: LinearProvider[Color]) =
  a.time.update()
  var tt = a.time.value;
  a.value.r = uint8(a.start.r * (1-tt) + a.endPosition.r * tt)
  a.value.g = uint8(a.start.g * (1-tt) + a.endPosition.g * tt)
  a.value.b = uint8(a.start.b * (1-tt) + a.endPosition.b * tt)
  a.value.a = uint8(a.start.r * (1-tt) + a.endPosition.r * tt)

  



method update*(a: ConstProvider[Vector3]) =
  #doNothing
  static:
    echo "do nothing"

proc myGlBindBuffer() =
  discard
proc myglBufferSubData() =
  discard
method update*(a: MeshProvider) =
  a.rProvider.update()
  var r = abs(a.rProvider.value)
  var l = abs(a.lProvider.value)
  updateMeshSpaceFromClosePath(a.mesh, a.path, @[-l, r],@[0.0,1], a.textRatio)
  updateMeshBuffer(a.mesh, 0, a.mesh.vertices, a.mesh.vertexCount * 3*sizeof(
      cfloat), 0)

method update*(a: CustomCall) =
  a.funct()

proc getRandomSeq*(rands:var seq[float],n:int,l,r:float)=
  rands.setLen n;
  for i in 0..<n :
    rands[i]= rand(r)






method update*(a: FrameSequence) =
  a.valueSource.update()
  var v = a.valueSource.value-a.startTime;

  var last = a.frames[a.frames.len-1].time_end
  v = v-(v/last).int * last
  var idx = 0;
  for i in 0 ..< a.frames.len:
    idx = i
    if v < a.frames[i].time_end:
      break;

  a.target.drawComps[0] = a.frames[idx].mesh





proc init*(a: FrameSequence, texture: Texture2D, rows, cols: int,
    time: float): FrameSequence{.discardable.} =
  a.frames = @[]

  for i in 0..<rows:
    for j in 0..<cols:
      var model = loadModelFromMesh(makeRectMesh([0.0, 0.0], [1.0, 1.0], [
          i*1.0/rows, j*1.0/cols], [(i+1)*1.0/rows, (j+1)*1.0/cols]))
      model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture
      var rr2 = D3Renderer(model: model)
      a.frames.add(
        FrameData(time_end: time*(i*cols+j+1)/(rows*cols), mesh: rr2)
      )
  return a






method update*(a: MoveTo) =
  a.provider.update()
  a.target.setPostion(a.provider.value)


method update*(a: CorutineHandler) =
  discard a.provider()
  
  #a.target.setPostion(a.provider.value)

method update*(a: CoroutineListHandler) =
  if a.providers.len<1 :
    return ;#TODO set done=true
  var done=a.providers[0]()
  if done :
    a.providers.del(0)
  #a.target.setPostion(a.provider.value)

method update*(a: SetTransformTo) =
  a.scaleProvider.update()
  a.rotateProvider.update();
  a.target.transform = scale(a.scaleProvider.value.x, a.scaleProvider.value.y,
      a.scaleProvider.value.z)*rotateXYZ(a.rotateProvider.value)



method update*(a: SetTintTo) =
  a.scaleProvider.update()
  var color=a.scaleProvider.value
  for i in a.target.drawComps:
    i.tint = color





proc myClone*[T](a: LinearProvider[T]): LinearProvider[T] =
  var res = new LinearProvider[T]
  res.time = a.time
  res.endPosition = a.endPosition
  res.start = a.start
  return res

logPrint = true
p_p.update()
p_p2.update()




echo "===================="
echo "float ", GetNumber(float)
echo "vec3 ", GetNumber(Vector3)

echo "===================="
