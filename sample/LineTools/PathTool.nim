
import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import std/sequtils
import std/sugar
import std/times
import std/strformat
from os import existsFile
import asyncdispatch
import std/tables
import RayNim/funcs/SpriteFunctions
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import RayNim/funcs/SpriteFunctions
import RayNim/Components/[Node, NodeP, Anim, MaskView, MeshElectirc]
import RayNim/CameraTool


type
    PathProvider* = ref object of RootObj
        discard

    RectPath* = ref object of PathProvider
        width*,hight*:ValueProvider[float]

    RoundPath* = ref object of PathProvider
        path* :PathProvider
        radius* :ValueProvider[float]

    PathSlicer* = ref object of PathProvider
        path* :PathProvider
        start*,finish*:ValueProvider[float]

    LineMesh* = ref object of RootObj
        path* :PathProvider
        radius* :seq[float]
    