import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros



method visit*(a: GNode, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =

    var newT = gtransform * a.transform
    var newP = pos+a.position.transform(gtransform)

    for c in a.drawComps:
        c.draw(newP, newT, camera)

    for c in a.childs:
        c.visit(newP, newT, camera)



method update*(a: GNode) {.inline.} =
    for c in a.onUpdate:
        c.update()

    for c in a.childs:
        c.update()



proc allocateMeshData*(mesh: var Mesh, triangleCount: int) =
  mesh.vertexCount = triangleCount * 3
  mesh.triangleCount = triangleCount

  mesh.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 3 * sizeof(cfloat)))
  mesh.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 2 * sizeof(cfloat)))
  mesh.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount * 3 * sizeof(cfloat)))



  

proc makeMesh*(): Mesh =
  allocateMeshData(result, 2)
  var verts=[-0.5,-0.5,0, -0.5,0.5,0,       0.5,-0.5,0,
              0.5.float, 0.5,0,  0.5,-0.5, 0,     -0.5, 0.5,0 
  ]
  for idx, val in verts:
    result.vertices[idx] = val
  for idx, val in [0.cfloat,0,1, 0,0,1, 0,0,1]:
    result.normals[idx] = val
  
  var txts=[0.cfloat,0, 0,1, 1,0,
            1.cfloat,1, 1,0, 0,1
  ]
  for idx, val in txts:
    result.texcoords[idx] = val

  uploadMesh(result.addr, false)


type 
  PathPoint* = object
    pos* : Vector2
    normal* : Vector2
  MyVec[T,N : static[int]] = array[N, int]


proc makeCirclePath*(r:float,n:int): seq[PathPoint] =
  var pi2=3.1415*2
  result= @[]
  for i in 0.. (n-1):
    var del=pi2*i/n
    result.add( PathPoint(
        pos:(cos(del)*r,sin(del)*r),
        normal:(cos(del),sin(del))
      )
    )
proc makeRectPath*(minn,maxx:array[2,float]): seq[PathPoint] =
  return @[
      PathPoint(pos:(minn[0],minn[1]),normal:(1.0,1.0)),
      PathPoint(pos:(minn[0],maxx[1]) ,normal:(1.0,-1.0)),
      PathPoint(pos:(maxx[0],maxx[1])  ,normal:(-1.0,-1.0)),
      PathPoint(pos:(maxx[0],minn[1]) ,normal:(-1.0,1.0)),
  ]  

proc makeRectMesh*(minn,maxx:array[2,float],minnText,maxxText:array[2,float]): Mesh =
  allocateMeshData(result, 2)
  var verts=[minn[0],minn[1],0, minn[0],maxx[1],0,       maxx[0],minn[1],0,
              maxx[0].float, maxx[1],0,  maxx[0],minn[1], 0,     minn[0], maxx[1],0 
  ]
  for idx, val in verts:
    result.vertices[idx] = val
  for idx, val in [0.cfloat,0,1, 0,0,1, 0,0,1]:
    result.normals[idx] = val
  
  var txts=[minnText[0],minnText[1], minnText[0],maxxText[1], maxxText[0],minnText[1],
            maxxText[0],maxxText[1], maxxText[0],minnText[1], minnText[0],maxxText[1]
  ]
  for idx, val in txts:
    result.texcoords[idx] = val

  uploadMesh(result.addr, false)


        
    




proc addT[N : static[int],T](a:ptr UncheckedArray[T],idx:cushort, v:array[N, T] )=
  a[idx * N + 0] = v[0]
  for i in 0..N-1:
    a[idx*N + i.cushort] = v[i]
  #[var ii:cushort
  StaticFor ii   , N :
    #a[idx+ii ] = v[ii]
    echo "copy "]#

    
  

proc addVec3*(a:ptr UncheckedArray[cfloat],idx:cushort,v:Vector3 )=
  a[idx*3] =v.x
  a[idx*3+1] =v.y
  a[idx*3+2] =v.z


proc makeMeshSpaceFromClosePath*(res: var Mesh, path : seq[PathPoint])=
  res.vertexCount = path.len * 2 
  res.triangleCount = path.len*2

  res.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount * 3 * sizeof(cfloat)))
  res.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount * 2 * sizeof(cfloat)))
  res.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount * 3 * sizeof(cfloat)))
  res.indices = cast[ptr UncheckedArray[cushort]](memAlloc(res.vertexCount * 2* 3 * sizeof(cushort)))

proc updateMeshSpaceFromClosePath*(result: var Mesh,path : seq[PathPoint] ,l,r:float,textRatio:float)=
  var vrtxH:cushort=0

  var vrtz=path.len*2;
  var d=0.float
  for i in 0.. (path.len-1):
    
    var p0=path[i].pos+path[i].normal*l
    var p1=path[i].pos-path[i].normal*r
    var 
      nxt0=vrtxH+2
      nxt1=vrtxH+3

    if i==path.len-1 :
      nxt0=0
      nxt1=1

    addT[3,cfloat](result.vertices,vrtxH,[p0.x,p0.y,0])
    addT[3,cfloat](result.normals,vrtxH,[cfloat(0),0,1])
    addT[2,cfloat](result.texcoords,vrtxH,[d.cfloat,0.cfloat])  
    addT[3,cushort](result.indices,vrtxH,[cushort(vrtxH),vrtxH+1,nxt0])
    
    

    

    vrtxH=vrtxH+1
    

    addT[3,cfloat](result.vertices,vrtxH,[p1.x,p1.y,0])
    addT[3,cfloat](result.normals,vrtxH,[cfloat(0),0,1])
     
    addT[2,cfloat](result.texcoords,vrtxH,[d.cfloat,1.cfloat])
    addT[3,cushort](result.indices,vrtxH,[vrtxH,nxt1,nxt0])

    d=d+(p1-p0).length*textRatio
    vrtxH=vrtxH+1
    
  
    
    
    
proc makeMeshFromClosePath*( path : seq[PathPoint] ,r:float,textRatio:float): Mesh =
  
  makeMeshSpaceFromClosePath(result,path);

  updateMeshSpaceFromClosePath(result,path,r,r,textRatio)
  
  uploadMesh(result.addr, false)

  
    
    
    
   
    

 
    
 
  