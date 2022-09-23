import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros
import std/random


method visit*(a: GNode, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.base.} =
    if a.visible==false:
        return;
    var newT = gtransform * a.transform
    var newP = pos+a.position.transform(gtransform)

    for c in a.drawComps:
        if c.visible :
            c.draw(newP, newT, camera)

    for c in a.childs:
        c.visit(newP, newT, camera)

method visit*(a: Button, pos: Vector3, gtransform: Matrix,
        camera: Camera)  =
    procCall a.GNode.visit(pos,gtransform,camera);
    #a.btnRect
    
proc removeFinished*(a:var seq[AnimComp]){. inline .}=
    var k=0
    for i in 0..<a.len:
        if not a[i].finished:
            if k!=i:
                a[k]=a[i]
            k+=1
    a.setLen(k)
        
proc removeFirstIfFinished*(a:var seq[AnimComp]):bool{. inline .}=
    
    if not a[0].finished:
        return false;
    for i in 1..<a.len:
        a[i-1]=a[i]
    a.setLen(a.len-1)

method update*(a: GNode) {.base.} =
    if a.visible==false:
        return;
    for idx in 0..<a.onUpdate.len:
        a.onUpdate[idx].update()


    #[for idx in 0..<a.ccOnUpdate.len:
        a.ccOnUpdate[idx].update()]#

    a.onUpdate.removeFinished()
            
    var idx=0;
    while idx < a.childs.len :
        a.childs[idx].update()
        idx+=1



proc allocateMeshData*(mesh: var Mesh, triangleCount: int) =
    mesh.vertexCount = triangleCount * 3
    mesh.triangleCount = triangleCount

    mesh.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount *
            3 * sizeof(cfloat)))
    mesh.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(
            mesh.vertexCount * 2 * sizeof(cfloat)))
    mesh.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(mesh.vertexCount *
            3 * sizeof(cfloat)))





proc makeMesh*(): Mesh =
    allocateMeshData(result, 2)
    var verts = [-0.5, -0.5, 0, -0.5, 0.5, 0, 0.5, -0.5, 0,
                0.5.float, 0.5, 0, 0.5, -0.5, 0, -0.5, 0.5, 0
    ]
    for idx, val in verts:
        result.vertices[idx] = val
    for idx, val in [0.cfloat, 0, 1, 0, 0, 1, 0, 0, 1]:
        result.normals[idx] = val

    var txts = [0.cfloat, 0, 0, 1, 1, 0,
              1.cfloat, 1, 1, 0, 0, 1
    ]
    for idx, val in txts:
        result.texcoords[idx] = val

    uploadMesh(result.addr, false)




proc getAmud*(p:Vector2):Vector2=
    result = Vector2(x:p.y , y: -p.x)
    result=result.normalize()
    return result

proc getRAmud*(p:Vector2):Vector2=
    result = Vector2(x: -p.y , y: p.x)
    result=result.normalize()
    return result

proc updateCirclePath*(result:ptr seq[PathPoint],r: float, n: int) =
    var pi2 = 3.1415*2
    for i in 0 .. (n-1):
        var del = pi2*i/n
        result[i].pos= (cos(del)*r, sin(del)*r)
        result[i].normal= (cos(del), sin(del))

proc makeCirclePath*(r: float, n: int): seq[PathPoint] =
    result = @[]
    result.setLen n
    updateCirclePath(result.addr,r,n)


proc updateLinePath*(result:ptr seq[PathPoint],path:seq[Vector2], n: int) =
    var z=path[1]-path[0]
    for i in 0 .. (n-1):
        var del = i.float/(n-1)
        result[i].pos= path[0]+z*del
        result[i].normal= z.getAmud()

proc makeLinePath*(path:seq[Vector2], n: int): seq[PathPoint] =
    result = @[]
    result.setLen n
    updateLinePath(result.addr,path,n)
            
proc makeRectPath*(minn, maxx: array[2, float]): seq[PathPoint] =
    return @[
        PathPoint(pos: (minn[0], minn[1]), normal: (1.0, 1.0)),
        PathPoint(pos: (minn[0], maxx[1]), normal: (1.0, -1.0)),
        PathPoint(pos: (maxx[0], maxx[1]), normal: (-1.0, -1.0)),
        PathPoint(pos: (maxx[0], minn[1]), normal: (-1.0, 1.0)),
    ]

proc addRandomToPath*(t:var seq[PathPoint],r:float)=
    var n=t.len;
    for i in 0..<n:
        t[i].pos = t[i].pos + t[i].normal*((rand(2.0)-1)*r);




proc updateRectMesh*(mesh:Mesh,minn, maxx: array[2, float], minnText, maxxText: array[2,
        float]) =
    
    var verts = [minn[0], minn[1], 0, minn[0], maxx[1], 0, maxx[0], minn[1], 0,
                maxx[0].float, maxx[1], 0, maxx[0], minn[1], 0, minn[0], maxx[1], 0
    ]
    for idx, val in verts:
        mesh.vertices[idx] = val
    for idx, val in [0.cfloat, 0, 1, 0, 0, 1, 0, 0, 1]:
        mesh.normals[idx] = val

    var txts = [minnText[0], minnText[1], minnText[0], maxxText[1], maxxText[0], minnText[1],
              maxxText[0], maxxText[1], maxxText[0], minnText[1], minnText[0],
                      maxxText[1]
    ]
    for idx, val in txts:
        mesh.texcoords[idx] = val


proc makeRectMesh*(minn, maxx: array[2, float], minnText, maxxText: array[2,
        float]): Mesh =
    allocateMeshData(result, 2)
    updateRectMesh(result,minn,maxx,minnText,maxxText)
    uploadMesh(result.addr, false)





proc addT*[N: static[int], T](a: ptr UncheckedArray[T], idx: cushort, v: array[N, T]) =
    a[idx * N + 0] = v[0]
    for i in 0..N-1:
        a[idx*N + i.cushort] = v[i]
    #[var ii:cushort
    StaticFor ii   , N :
        #a[idx+ii ] = v[ii]
        echo "copy "]#




proc addVec3*(a: ptr UncheckedArray[cfloat], idx: cushort, v: Vector3) =
    a[idx*3] = v.x
    a[idx*3+1] = v.y
    a[idx*3+2] = v.z


proc makeMeshSpaceFromClosePath*(res: var Mesh, pathLen:int,rlengh:int=2,isClose:bool=true) =
    res.vertexCount = pathLen * rlengh
    if isClose:
        res.triangleCount = pathLen * (rlengh-1)*2
    else:
        res.triangleCount = (pathLen-1) * (rlengh-1)*2

    res.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            3 * sizeof(cfloat)))
    res.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            2 * sizeof(cfloat)))
    res.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            3 * sizeof(cfloat)))
    res.indices = cast[ptr UncheckedArray[cushort]](memAlloc(res.triangleCount *
             3 * sizeof(cushort)))



proc updateMeshPointFromPath*(result: var Mesh, path: seq[PathPoint], r:seq[float],textR:seq[float], textRatio: float) =


    var d = 0.float
    var prv=path[0].pos
    for i in 0..<path.len:

        var z=(prv-path[i].pos).length
        prv=path[i].pos
        var vrtxH = (i*r.len).cushort
        for j in 0..<r.len:
            var p = path[i].pos+path[i].normal*r[j]
            addT[3, cfloat](result.vertices, vrtxH+cushort(j), [p.x, p.y, 0])
            addT[3, cfloat](result.normals, vrtxH+cushort(j), [cfloat(0), 0, 1])
            addT[2, cfloat](result.texcoords, vrtxH+cushort(j), [d.cfloat, textR[j]])

       
        d = d+textRatio*z
        #vrtxH = vrtxH+cushort(r.len)*2



proc updateMeshFacesFromClosePath*(result: var Mesh, pathLen: int, rLen:int,isClose:bool=true) =



    for i in 0..<pathLen:
        var vrtxH = (i*rLen).cushort
      
        for j in 0..<rLen-1:
            var
                indicesCur = (i*(rLen-1)*2+j*2).cushort
                cur  = vrtxH+(j).cushort
                cur1  = cur+1
                nxt0 = cur+cushort(rLen)
                nxt1 = cur1+cushort(rLen)
            if i == pathLen-1:
                nxt0 = j.cushort
                nxt1 = j.cushort+1
            if i != pathLen-1 or isClose:    
                addT[3, cushort](result.indices, indicesCur, [cur, cur1, nxt0])
                addT[3, cushort](result.indices, indicesCur+1, [cur1, nxt1, nxt0])


        

        #vrtxH = vrtxH+cushort(r.len)*2






proc makeMeshFromClosePath*(path: seq[PathPoint],  r:seq[float],txt:seq[float],
        textRatio: float,isClose:bool=true): Mesh =

    
    makeMeshSpaceFromClosePath(result, path.len,r.len,isClose);

    updateMeshPointFromPath(result,path,r,txt,textRatio)

    updateMeshFacesFromClosePath(result, path.len, r.len,isClose)

    uploadMesh(result.addr, false)





method draw*(a: D3Renderer, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  a.model.transform = gtransform
  if not isNil(a.shaderSet):
    a.shaderSet();
  if a.disableDepth  :
    rl.disableDepthMask()   
    rl.disableDepthTest()
    beginBlendMode(BlendMode.ALPHA)
  drawModel(a.model, pos, 1.0, a.tint)
  if a.disableDepth  :
    rl.enableDepthMask()
    rl.enableDepthTest()   
    endBlendMode()



  


proc init*(self:LineRenderer0,path :seq[PathPoint],r,texR:seq[float],texture:Texture2D,isClose=true):bool{. discardable .}=
    self.path=path
    var mesh=makeMeshFromClosePath(self.path , r,texR,1,isClose)
    self.model= loadModelFromMesh(mesh)
    self.model.materials[0].maps[0].texture =  texture
    self.tint = White


    
    return true



proc setPath*(self:LineRenderer0,path:seq[PathPoint])=

    self.path=path
    #TODO  set dirty

proc setThicknessMesh*(self:LineRenderer0,r,texR:seq[float])=

    
    #updateMeshFacesFromClosePath(self.model.meshes[0], self.path.len, r.len,false)
  
    

    updateMeshPointFromPath(self.model.meshes[0],self.path,r,texR,1.0)

    

    #uploadMesh(result.addr, false)

    updateMeshBuffer(self.model.meshes[0], 0, self.model.meshes[0].vertices, self.model.meshes[0].vertexCount * 3*sizeof(
      cfloat), 0)

method draw*(a: LineRenderer0, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
  a.model.transform = gtransform
  drawModel(a.model, pos, 1.0, a.tint)

proc init*(self:LineRenderer,path :seq[PathPoint],r:float,texture:Texture2D):bool{. discardable .}=
   
    return procCall self.LineRenderer0.init(path,@[-0.5*r,0.5*r],@[0.0,1],texture)


    
    

proc setThickness*(self:LineRenderer,r:float)=

    procCall self.LineRenderer0.setThicknessMesh( @[-0.5*r,0.5*r],@[0.0,1])
    #updateMeshFacesFromClosePath(self.model.meshes[0], self.path, @[-0.5*r,0.5*r],@[0.0,1],1,true)
  
    #updateMeshBuffer(self.model.meshes[0], 0, self.model.meshes[0].vertices, self.model.meshes[0].vertexCount * 3*sizeof(
    #  cfloat), 0)


proc setColor*(self:RenderComp,c:Color)=
    self.tint=c
    




proc init*(self:IconRenderer,r:float,texture:Texture2D):bool{. discardable .}=
    
    
    var mint=[0.0,0.0]
    var maxt=[1.0,1.0]
    self.model = loadModelFromMesh(makeRectMesh([-r,-r],[r,r],mint,maxt))
    self.model.materials[0].maps[MaterialMapIndex.Albedo.int].texture = texture # MATERIAL_MAP_DIFFUSE is now ALBEDO
    
    self.tint=White

    return true



proc getPathPoints*(a:seq[Vector2]):seq[PathPoint]=
  
  for i in 0..<a.len:
    var left=Vector2()
    
    if i!=0 :
       left=a[i]-a[i-1]
    else:
       left=a[i+1]-a[i]

    var right=Vector2()

    if i != a.len-1:
       right=a[i+1]-a[i]
    else:
       right=a[i]-a[i-1]

    result.add PathPoint(
      pos: a[i] ,
      normal: left.normalize.getRAmud #(left.getAmud+right.getAmud).normalize  
    )
