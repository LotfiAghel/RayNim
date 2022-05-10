import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import NodeP

#######################3
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
import macros

template badNodeKind(n, f) =
  error("Invalid node kind " & $n.kind & " for macros.`" & $f & "`", n)

proc `$$$`*(node: NimNode): string =
  ## Get the string of an identifier node.
  case node.kind
  of nnkPostfix:
    result = node.basename.strVal & "*"
  of nnkStrLit..nnkTripleStrLit, nnkCommentStmt, nnkSym, nnkIdent:
    result = node.strVal
  of nnkOpenSymChoice, nnkClosedSymChoice:
    result = $node[0]
  of nnkAccQuoted:
    result = $node[0]
  of nnkBracketExpr:
    echo node.treeRepr
    result = "__braketOpen__"
    
    for i in node:
      result=result  & $$$i & "_sp_"
    result=result & "__close__"
  else:
    badNodeKind node, "$$$"

import macros
var z{.compileTime}=0


template typeDeclPub(a:untyped, b): untyped =
    type a* = ref object of b
typeDeclPub(bb,RootObj)


macro SetNumber*(a:type):untyped=
  template createVar(ab:NimNode): untyped=
    var ab*:int 
  
  var tt="GetNumber__" & $$$(a)
  echo tt
  var z= getAst(createVar(newIdentNode(tt)))
  #echo z.treeRepr
  #z.child
  return z
  
  

macro GetNumber*(a:type):untyped=
  template getVar(ab:NimNode): untyped=
    ab 
  var tt="GetNumber__" & $$$(a)
  echo "get " , tt
  return getAst(getVar(newIdentNode(tt)))



type
  ValueProvider0 = ref object of RootObj
  ValueProvider*[T] = ref object of ValueProvider0
    value*: T
  CorutineHandler* = ref object of AnimComp
    provider*: iterator(): int

  MoveTo* = ref object of AnimComp
    provider*: ValueProvider[Vector3]

  

  TimeProvider* = ref object of ValueProvider[float]
  TimeRange* = ref object of ValueProvider[float]
    zeroPoint*: float
    endPoint*: float
    valueSource*: ValueProvider[float]
  SinEfect* = ref object of ValueProvider[float]
    valueSource*: ValueProvider[float]
  SinEfect2* = ref object of ValueProvider[float]
    valueSource*: ValueProvider[float]
    innerMult*:float
    outerMult*:float
    outerPlus*:float


  LinearProvider*[T] = ref object of ValueProvider[T]
    time*: ValueProvider[float]
    endPosition*: T
    start*: T

  ConstProvider*[T] = ref object of ValueProvider[T]

  MeshProvider* = ref object of AnimComp
    path*: seq[PathPoint]
    mesh*: Mesh
    rProvider*: ValueProvider[float]
    lProvider*: ValueProvider[float]
    textRatio*: float
macro SetType*(T:type):untyped=
  template createVar(ab:NimNode,T:untyped): untyped=
    type ab* = ref object of ValueProvider0
      value*: T
      time*: ValueProvider[float]
      endPosition*: T
      start*: T
  
  var tt="GetType__" & $$$(T)
  echo "create GetType " & tt
  var z= getAst(createVar(newIdentNode(tt),T))
  echo z.treeRepr
  #z.child
  return z

template SetType2(ab:untyped,T:type): untyped=
  type ab* = ref object of ValueProvider0
    time*: ValueProvider[float]
    value*: T
    endPosition*: T
    start*: T
  method update*(a: ab) =
    a.time.update()
    var tt = a.time.value;
    a.value = a.start * (1-tt) + a.endPosition * tt
    GetNumber(Vector3) = GetNumber(Vector3) + 1

macro GetType*(a:type):untyped=
  template getVar(ab:NimNode): untyped=
    ab 
  var tt="GetType__" & $$$(a)
  echo "get " , tt
  return getAst(getVar(newIdentNode(tt)))

SetType(Vector3)
SetType(float)
type
  SetTransformTo* = ref object of AnimComp
    scaleProvider*: GetType(Vector3)
    rotateProvider*: GetType(Vector3)



method update(a: ValueProvider0){.base.} =
  discard
  #echo "ValueProvider0.update"

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


method update*(a: SinEfect) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*3.14*2/50)



method update*(a: SinEfect2) =
  a.valueSource.update()
  var tt = a.valueSource.value
  a.value = sin(tt*PI*2*a.innerMult)*a.outerMult+a.outerPlus

proc setPostion*(a: GNode, value: Vector3){.inline.} =
  a.position = value




#AnimCompCreator(FastMoveTo, setPostion, LinearProvider)
#AnimCompCreator(FastRotateTo, setRotation, LinearProvider)
var logPrint* = false
#var logNumbers*[T]=0
template ForLoop22(time:NimNode,l:int,r:int,body:untyped)=
  block:
    for i in l..<r:
      body
    

SetNumber(Vector3)
SetNumber(float)
SetNumber(LinearProvider[LinearProvider[Vector3]])

SetType2(LinearProvider_Vector3,Vector3)
SetType2(LinearProvider_float,float)


var p:GetType(float)
var rtp:GetType(Vector3)
echo rtp.value

macro SetNumbers*(a:varargs[type]):seq[int]=
  echo "salam"
  
  


#SetNumbers(float,float)


method update*(a: LinearProvider[Vector3]) =
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
  GetNumber(float) = GetNumber(float) + 1

method update*(a: GetType(Vector3)) =
  a.time.update()
  var tt = a.time.value;
  a.value = a.start * (1-tt) + a.endPosition * tt
  GetNumber(Vector3) = GetNumber(Vector3) + 1

method update*(a: GetType(float)) =
  a.time.update()
  var tt = a.time.value;
  a.value = a.start * (1-tt)+a.endPosition * tt
  #if logPrint:
  #  echo a.start,a.endPosition,a.value
  GetNumber(float) = GetNumber(float) + 1



#[method update*[T](a: LinearProvider[T]) =
  a.time.update()
  var tt = a.time.value;
  a.value = a.start * (1-tt) + a.endPosition * tt
  GetNumber(type(T)) = GetNumber(type(T)) + 1]#


method update*(a: ConstProvider[Vector3]) =
  #doNothing
  static:
    echo "do nothing"


method update*(a: MeshProvider) =
  a.rProvider.update()
  var r = abs(a.rProvider.value)
  var l = abs(a.lProvider.value)
  updateMeshSpaceFromClosePath(a.mesh, a.path, l,r, a.textRatio)
  updateMeshBuffer(a.mesh, 0, a.mesh.vertices, a.mesh.vertexCount * 3*sizeof(cfloat), 0)
 
method update(a: MoveTo) =
  a.provider.update()
  a.target.setPostion(a.provider.value)


method update(a: CorutineHandler) =
  discard a.provider()
  #a.target.setPostion(a.provider.value)

method update(a: SetTransformTo) =
  a.scaleProvider.update()
  a.rotateProvider.update();
  a.target.transform = scale(a.scaleProvider.value.x, a.scaleProvider.value.y,
      a.scaleProvider.value.z)*rotateXYZ(a.rotateProvider.value)




proc myClone*[T](a: LinearProvider[T]): LinearProvider[T] =
  var res = new LinearProvider[T]
  res.time = a.time
  res.endPosition = a.endPosition
  res.start = a.start
  return res


var p_p : GetType(float)=GetType(float)(time: ConstProvider[float](value:0), endPosition: 0.0, 
      start:0.0)
var p_p2 : GetType(Vector3)= GetType(Vector3)(time: ConstProvider[float](value:0), endPosition: (0.0, 0.0, PI/2), 
      start: (0.0, 0.0, 0.0))

logPrint=true
p_p.update()
p_p2.update()


echo "===================="
echo "float ",GetNumber(float)
echo "vec3 ",GetNumber(Vector3)

echo "===================="