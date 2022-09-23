import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import NodeP
import NimUseFullMacros/macroTool
import NimUseFullMacros/ConstructorCreator/Basic
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
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
    finished* {.dfv(false).}: bool

  ValueProvider*[T] = ref object of ValueProvider0
    value*: T
    

  TimeProvider* = ref object of ValueProvider[float]

  ProviderConvertor*[TIN,TOUT] = ref object of ValueProvider[TOUT]
    valueSource* {.dfv(startFromNow()).}: ValueProvider[TIN]

  TimeRange* = ref object of ProviderConvertor[float,float]
    zeroPoint*: float
    endPoint*: float

  TimeShift* = ref object of ProviderConvertor[float,float]
    shiftValue*: float

  SinEfect* = ref object of ProviderConvertor[float,float]

  SinEfect2* = ref object of ProviderConvertor[float,float]
    innerMult*: float
    outerMult*: float
    outerPlus*: float

  LinearProvider*[T] = ref object of ProviderConvertor[float,T]
    endPosition*: T
    start*: T
  
  LinearProviderInRange*[T] = ref object of ProviderConvertor[float,T]
    endPosition*: T
    start*: T

  ProceduralProvider*[T] = ref object of ProviderConvertor[float,T]
    procedure*: proc(t:float):T

  ConstProvider*[T] = ref object of ValueProvider[T]
  
  CustomCall* = ref object of AnimComp
    funct*:proc()


type
  
  CorutineHandler* = ref object of AnimComp
    provider*: iterator(): bool
  CoroutineListHandler* = ref object of AnimComp
    providers*: seq[iterator(): bool]
    h*{. dfv(0).}:int

  MoveTo* = ref object of AnimComp
    provider*: ValueProvider[Vector3]

  SetTransformTo* = ref object of AnimComp
    scaleProvider*{. dfv( ConstProvider[Vector3](value:(1.0,1.0,1.0) ) ) .}: ValueProvider[Vector3]
    rotateProvider*{. dfv( ConstProvider[Vector3](value:(0.0,0.0,0.0) ) ) .}: ValueProvider[Vector3]

  
  SetTintTo* = ref object of AnimComp
    scaleProvider*: ValueProvider[Color]
    

  
  AnimCompFloatSource* = ref object of AnimComp
     time*{. dfv(startFromNow()) .}: ValueProvider[float]

  CustomCall2* = ref object of AnimCompFloatSource
    funct*:proc(t:float)

  MeshProvider* = ref object of AnimComp
    path*: seq[PathPoint]
    mesh*: Mesh
    rProvider*: ValueProvider[float]
    lProvider*: ValueProvider[float]
    textRatio*: float




  SeqAnimation* = ref object of AnimComp
    anims*:seq[AnimComp] 





var p_p: ValueProvider[float] = LinearProvider[float](valueSource: ConstProvider[float](value: 0), endPosition: 0.0,
      start: 0.0)
var p_p2: ValueProvider[Vector3] = LinearProvider[Vector3](valueSource: ConstProvider[float](value: 0), endPosition: (0.0, 0.0, PI/2),
      start: (0.0, 0.0, 0.0))


method update(a: ValueProvider0){.base.} =
  discard
  #echo "ValueProvider0.update"

method update2(a: ValueProvider0,t:float){.base.} =
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

method update2*(a: TimeRange,t:float) =
  a.value = (t-a.zeroPoint)/(a.endPoint-a.zeroPoint)

method update*(a: TimeShift) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = tt+a.shiftValue
  
method update*(a: SinEfect) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*3.14*2/50)

method update2*(a: SinEfect,t:float) =
  var t = a.valueSource.value
  a.value = sin(t*3.14*2/50)





method update*(a: SinEfect2) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*PI*2*a.innerMult)*a.outerMult+a.outerPlus


proc newVector3*(x,y,z:float):Vector3=
  return Vector3(x:x,y:y,z:z);

proc setPostion*(a: GNode, value: Vector3):GNode{.inline , discardable.} =
  result=a;
  a.position = value

proc setPostion*(a: RenderComp, value: Vector3):RenderComp{.inline , discardable.} =
  result=a;
  a.position = value


proc setPostion*(a: GNode, value: array[3,float]):GNode{.inline , discardable.} =
  result=a;
  a.position = (value[0],value[1],value[2])

proc setPostion*(a: GNode, value: Vector2):GNode{.inline , discardable.} =
  result=a;
  a.position.x = value.x
  a.position.y = value.y
  

proc setPostion*(a: RenderComp, value: Vector2):RenderComp{.inline , discardable.} =
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
    a.valueSource.update()
    var tt = a.valueSource.value;
    a.value = a.start * (1-tt) + a.endPosition * tt
    GetNumber(T) = GetNumber(T) + 1

  method update2*(a: LinearProvider[T],t:float) =
    a.value = a.start * (1-t) + a.endPosition * t
    GetNumber(T) = GetNumber(T) + 1
  

  method update*(a: LinearProviderInRange[T]) =
    a.valueSource.update()
    var tt = a.valueSource.value;
    if tt>1.0:
      a.finished = true
    a.value = a.start * (1-tt) + a.endPosition * tt
    GetNumber(T) = GetNumber(T) + 1

  method update2*(a: LinearProviderInRange[T],t:float) =
    a.value = a.start * (1-t) + a.endPosition * t
    GetNumber(T) = GetNumber(T) + 1


declUpdate(float)
declUpdate(Vector2)
declUpdate(Vector3)



template declProceduralProviderUpdate(T: type) =
  method update*(a: ProceduralProvider[T]) =
    a.valueSource.update()
    a.value=a.procedure(a.valueSource.value);


declProceduralProviderUpdate(float)
declProceduralProviderUpdate(Vector2)
declProceduralProviderUpdate(Vector3)


SetNumber(Color)
method update*(a: LinearProvider[Color]) =
  a.valueSource.update()
  var tt = a.valueSource.value;
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
  updateMeshPointFromPath(a.mesh, a.path, @[-l, r],@[0.0,1], a.textRatio)
  updateMeshBuffer(a.mesh, 0, a.mesh.vertices, a.mesh.vertexCount * 3*sizeof(
      cfloat), 0)

method update*(a: CustomCall) =
  if not a.finished :
    a.funct()
  a.finished=true


method update*(a: CustomCall2) =
  a.time.update()
  a.funct(a.time.value)



proc getRandomSeq*(rands:var seq[float],n:int,l,r:float)=
  rands.setLen n;
  for i in 0..<n :
    rands[i]= rand(r)











method update*(a: MoveTo) =
  a.provider.update()
  if a.provider.finished:
    a.finished=true;

  a.target.setPostion(a.provider.value)

method update2*(a: MoveTo,t:float) =
    a.provider.update2(t)
    a.target.setPostion(a.provider.value)
    

method update*(a: CorutineHandler) =
  discard a.provider()
  
  #a.target.setPostion(a.provider.value)

method update*(a: CoroutineListHandler) =
  if a.h>=a.providers.len :
    return ;#TODO set done=true
  var done=a.providers[a.h]()
  if done :
    a.h+=1
    #a.providers.del(0)
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

proc removeIterator*(z:GNode): iterator(): bool =
  return iterator (): bool  =
    yield false
    z.visible=false
    z.removeFromParent()
    yield true



proc hideIterator*(z:GNode): iterator(): bool =
  return iterator (): bool  =
    yield false
    z.visible=false
    yield true

proc delay*(t:float): iterator(): bool =
  return iterator (): bool  =
    ForLoop time,0.0,0.0,t:
      yield false
    yield true

proc callProc*(z:proc()): iterator(): bool =
  return iterator (): bool  =
    yield false
    yield false
    yield false
    z()
    yield true


echo "===================="
echo "float ", GetNumber(float)
echo "vec3 ", GetNumber(Vector3)

echo "===================="


proc createWithProviders*(ps:seq[iterator(): bool]):CoroutineListHandler=
  return CoroutineListHandler(providers:ps)

proc addIter*(c:CoroutineListHandler,ps:iterator(): bool ):CoroutineListHandler{.discardable.}=
  c.providers.add ps
  return c

proc addProc*(c:CoroutineListHandler,ps:proc() ):CoroutineListHandler{.discardable.}=
  c.providers.add callProc(ps)
  return c

var globalTime* = new TimeProvider
globalTime.value=0;

proc startFromNow*(t:ValueProvider[float]):TimeShift=
  return TimeShift(shiftValue: - t.value,valueSource:t)

proc startFromNow*():TimeShift=
  return TimeShift(shiftValue: -globalTime.value,valueSource:globalTime)

#proc startFromNow*[T](time:float ,endValue:T):LinearProviderInRange[T]=
#  return LinearProviderInRange[T].Create( =endValue );

#[method setTarget*(self: SeqAnimation,target:GNode){.base.} =
  procCall self.AnimComp.setTarget(target);
  if self.anims.len<1:
    self.anims[0].setTarget(self.target)]#

method update*(self: SeqAnimation) =
  var x=self.anims.removeFirstIfFinished()
  if self.anims.len<1:
    self.finished = true
    return;
  if self.anims[0].target != self.target:
    self.anims[0].setTarget(self.target)
  self.anims[0].update()
  

