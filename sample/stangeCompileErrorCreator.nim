import std/strutils
import std/strformat
when false:

    type
        A0 = object of RootObj  
            discard
        A=ref A0 
        B0 = object of A0  
            discard
        B=ref B0 

type
    A=ref object of RootObj  
        discard
    B=ref object of A  
        x:int

method f(a:var A){.base.}=
    echo "A.f"
method f(a:var B)=
    echo "B.f"

var
    h=B()

#var z0=h.addr
h.f()
echo h.x
#error: expected ‘)’ before ‘->’ token
#  857 |  f__stange67ompile69rror67reator_9(&&h__stange67ompile69rror67reator_12->Sup);

type 
  
  BaseType* = object of RootObj
    a*: string
    b*: int

  BaseTypeRef* = ref BaseType

  DerivedType* = object of BaseType
    c*: int
    d*: string
  DerivedRefType* = ref object of BaseType
    c*: int
    d*: string

    
  DerivedFromRefType* = ref object of DerivedRefType
    e*: int
    next*: DerivedRefType
    list: seq[DerivedRefType]


method funName(r:ptr RootObj){.base.}=
  echo fmt"RootObj nothing"

method funName(r:ptr BaseType)=
  echo fmt"BaseType {r.a}"

method funName(r:ptr BaseTypeRef)=
  echo fmt"BaseTypeRef {r.a}"

method funName(r:ptr DerivedType)=
  echo fmt"BaseTypeRef {r.a}"

method funName(r:ptr DerivedRefType)=
  echo fmt"DerivedRefType {r.a}"

method funName(r:ptr DerivedFromRefType)=
  echo fmt"DerivedFromRefType {r.a}"

var 
  a=BaseType(a:"BaseType")
  b=BaseTypeRef(a:"BaseTypeRef")
  c=DerivedType(a:"DerivedType")
  cd=DerivedRefType(a:"DerivedRefType")
  d:DerivedRefType=DerivedFromRefType(a:"DerivedFromRefType")

#a.addr.funName()
#b.addr.funName()
#d.addr.funName()
var z= @[cd.addr ,d.addr]
z[0].funName()
z[1].funName()
#for i in z:
#    i.funName()

echo "end"