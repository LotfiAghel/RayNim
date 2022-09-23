import lenientops, math, times, strformat, atomics, system/ansi_c
import nimraylib_now
from nimraylib_now/rlgl as rl import nil
import Node
import NodeP
import NimUseFullMacros/macroTool
import NimUseFullMacros/ConstructorCreator/Basic
import NimUseFullMacros/ConstructorCreator/ConstructorCreator
import std/random
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
import Anim as anim

type

    MoveTo0* = ref object of CCAnim
        start*,finish*:Vector3


    MoveTo* = ref object of MoveTo0
        discard
    

    ScaleTo* = ref object of CCAnim
        start*,finish*:Vector3


    TimeNodeBinder* = ref object of AnimComp
      anim*:CCAnim
    
    TimeNodeBinderRange* =ref object of TimeNodeBinder
      timer* {.dfv(startFromNow()).}:ValueProvider[float]
      start*,finish*:float # finish-start is span  see setTargetCode

    #[Sequance* =ref object of TimeNodeBinder
      animations*:seq[TimeNodeBinderRange]]#
      
      



method setTarget(self: TimeNodeBinder,target:GNode) =
  #procCall self.AnimComp.setTarget(target)
  self.target=target
  self.anim.setTarget(target)

proc addAction*(self:GNode,time:float,action:CCAnim)=
  var z=TimeNodeBinderRange.Create(anim=action,finish=time)
  z.setTarget(self)
  self.addOnUpdate z




method update(self: CCAnim,target:GNode,time:float){.base.} =
  discard





method update(self: TimeNodeBinder) =
  discard

method setTarget(self: TimeNodeBinderRange,target:GNode) =
  self.target = target
  var span=self.finish-self.start
  self.start = self.timer.value
  self.finish = self.start+span
  self.anim.setTarget(target)


method update(self: TimeNodeBinderRange) =
  self.timer.update();
  if self.timer.value > self.finish :
    self.finished=true;
  self.anim.update(self.target,self.timer.value/self.finish)




method update(self: MoveTo,target:GNode,time:float) =
  target.position = self.start*(1-time) + self.finish*(time);

method setTarget(self: MoveTo,target:GNode) =
  self.target=target;
  self.start=target.position

method update(self: ScaleTo,target:GNode,time:float) =
  var sc = self.start*(1-time) + self.finish*(time);
  target.transform=scale(sc.x,sc.y,sc.z);






