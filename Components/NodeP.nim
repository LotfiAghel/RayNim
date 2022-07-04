import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import std/math
import macros



method visit*(a: GNode, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
    if a.visible==false:
        return;
    var newT = gtransform * a.transform
    var newP = pos+a.position.transform(gtransform)

    for c in a.drawComps:
        c.draw(newP, newT, camera)

    for c in a.childs:
        c.visit(newP, newT, camera)

method visit*(a: Button, pos: Vector3, gtransform: Matrix,
        camera: Camera) {.inline.} =
    procCall a.GNode.visit(pos,gtransform,camera);
    #a.btnRect
    
    
method update*(a: GNode) {.inline.} =
    if a.visible==false:
        return;
    for c in a.onUpdate:
        c.update()

    for c in a.childs:
        c.update()



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


type
    PathPoint* = object
        pos*: Vector2
        normal*: Vector2
    MyVec[T, N: static[int]] = array[N, int]


proc makeCirclePath*(r: float, n: int): seq[PathPoint] =
    var pi2 = 3.1415*2
    result = @[]
    for i in 0 .. (n-1):
        var del = pi2*i/n
        result.add(PathPoint(
            pos: (cos(del)*r, sin(del)*r),
            normal: (cos(del), sin(del))
            )
        )
proc makeRectPath*(minn, maxx: array[2, float]): seq[PathPoint] =
    return @[
        PathPoint(pos: (minn[0], minn[1]), normal: (1.0, 1.0)),
        PathPoint(pos: (minn[0], maxx[1]), normal: (1.0, -1.0)),
        PathPoint(pos: (maxx[0], maxx[1]), normal: (-1.0, -1.0)),
        PathPoint(pos: (maxx[0], minn[1]), normal: (-1.0, 1.0)),
    ]

proc makeRectMesh*(minn, maxx: array[2, float], minnText, maxxText: array[2,
        float]): Mesh =
    allocateMeshData(result, 2)
    var verts = [minn[0], minn[1], 0, minn[0], maxx[1], 0, maxx[0], minn[1], 0,
                maxx[0].float, maxx[1], 0, maxx[0], minn[1], 0, minn[0], maxx[1], 0
    ]
    for idx, val in verts:
        result.vertices[idx] = val
    for idx, val in [0.cfloat, 0, 1, 0, 0, 1, 0, 0, 1]:
        result.normals[idx] = val

    var txts = [minnText[0], minnText[1], minnText[0], maxxText[1], maxxText[0], minnText[1],
              maxxText[0], maxxText[1], maxxText[0], minnText[1], minnText[0],
                      maxxText[1]
    ]
    for idx, val in txts:
        result.texcoords[idx] = val

    uploadMesh(result.addr, false)








proc addT[N: static[int], T](a: ptr UncheckedArray[T], idx: cushort, v: array[N, T]) =
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


proc makeMeshSpaceFromClosePath*(res: var Mesh, path: seq[PathPoint],rlengh:int=2) =
    res.vertexCount = path.len * rlengh
    res.triangleCount = path.len* (rlengh-1)*2

    res.vertices = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            3 * sizeof(cfloat)))
    res.texcoords = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            2 * sizeof(cfloat)))
    res.normals = cast[ptr UncheckedArray[cfloat]](memAlloc(res.vertexCount *
            3 * sizeof(cfloat)))
    res.indices = cast[ptr UncheckedArray[cushort]](memAlloc(res.triangleCount *
             3 * sizeof(cushort)))

proc updateMeshSpaceFromClosePath*(result: var Mesh, path: seq[PathPoint], r:seq[float],textR:seq[float], textRatio: float) =


    var d = 0.float
    for i in 0..<path.len:


        var vrtxH = (i*r.len).cushort
        for j in 0..<r.len:
            var p = path[i].pos-path[i].normal*r[j]
            addT[3, cfloat](result.vertices, vrtxH+cushort(j), [p.x, p.y, 0])
            addT[3, cfloat](result.normals, vrtxH+cushort(j), [cfloat(0), 0, 1])
            addT[2, cfloat](result.texcoords, vrtxH+cushort(j), [d.cfloat, textR[j]])

        for j in 0..<r.len-1:
            var
                indicesCur = vrtxH+(j*2).cushort
                cur  = vrtxH+(j).cushort
                nxt0 = vrtxH+cushort(j+r.len)
                nxt1 = vrtxH+cushort(j+r.len+1)
            if i == path.len-1:
                nxt0 = j.cushort
                nxt1 = j.cushort+1
            addT[3, cushort](result.indices, indicesCur, [cur, cur+1, nxt0])
            addT[3, cushort](result.indices, indicesCur+1, [cur+1, nxt1, nxt0])


        
        d = 0#d+(p1-p0).length*textRatio
        #vrtxH = vrtxH+cushort(r.len)*2





proc makeMeshFromClosePath*(path: seq[PathPoint],  r:seq[float],
        textRatio: float): Mesh =

    var txt:seq[float]
    for i in 0..<r.len:
        txt.add 1.0*i/(r.len-1)
    makeMeshSpaceFromClosePath(result, path,r.len);

    updateMeshSpaceFromClosePath(result, path, r,txt, textRatio)

    uploadMesh(result.addr, false)











