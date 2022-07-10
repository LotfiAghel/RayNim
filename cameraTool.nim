static:
    echo "start compile 2"

import nimraylib_now
import nimraylib_now/rlgl as rl
import math
#import nimraylib_now/rlight
#[void BeginMode3D(Camera3D camera)
{
    rlDrawRenderBatchActive();      // Update and draw internal render batch

    rlMatrixMode(RL_PROJECTION);    // Switch to projection matrix
    rlPushMatrix();                 // Save previous matrix, which contains the settings for the 2d ortho projection
    rlLoadIdentity();               // Reset current matrix (projection)

    float aspect = (float)CORE.Window.currentFbo.width/(float)CORE.Window.currentFbo.height;

    // NOTE: zNear and zFar values are important when computing depth buffer values
    if (camera.projection == CAMERA_PERSPECTIVE)
    {
        // Setup perspective projection
        double top = CULL_DISTANCE_NEAR*tan(camera.fovy*0.5*MY_DEG2RAD);
        double right = top*aspect;

        rlFrustum(-right, right, -top, top, CULL_DISTANCE_NEAR, CULL_DISTANCE_FAR);
    }
    else if (camera.projection == CAMERA_ORTHOGRAPHIC)
    {
        // Setup orthographic projection
        double top = camera.fovy/2.0;
        double right = top*aspect;

        rlOrtho(-right, right, -top,top, CULL_DISTANCE_NEAR, CULL_DISTANCE_FAR);
    }

    rlMatrixMode(RL_MODELVIEW);     // Switch back to modelview matrix
    rlLoadIdentity();               // Reset current matrix (modelview)

    // Setup Camera view
    Matrix matView = MatrixLookAt(camera.position, camera.target, camera.up);
    rlMultMatrixf(MatrixToFloat(matView));      // Multiply modelview matrix by view matrix (camera)

    rlEnableDepthTest();            // Enable DEPTH_TEST for 3D
}]#


proc myBeginMode3D( camera:Camera3D,aspect:float=2.0,CULL_DISTANCE_NEAR:float=0.01,CULL_DISTANCE_FAR:float=100000.0)=
    rl.drawRenderBatchActive()     

    rl.matrixMode(rl.PROJECTION)
    rl.pushMatrix();                
    rl.loadIdentity();              

    
    var 
        MY_DEG2RAD=3.1415/180

    
    if (camera.projection == Perspective):
    
        
        var top = CULL_DISTANCE_NEAR*tan(camera.fovy*0.5*MY_DEG2RAD);
        var right = top*aspect;

        rl.frustum(-right, right, -top, top, CULL_DISTANCE_NEAR, CULL_DISTANCE_FAR);
    
    elif (camera.projection == ORTHOGRAPHIC):
    
        
        var top = camera.fovy/2.0;
        var right = top*aspect;

        rl.ortho(-right, right, -top,top, CULL_DISTANCE_NEAR, CULL_DISTANCE_FAR);
    

    rl.matrixMode(0x1700);     
    rl.loadIdentity();          

    
    var matView = lookAt(camera.position, camera.target, camera.up);
    var z=toFloatV(matView)
    rl.multMatrixf(z.v[0].addr);

    rl.enableDepthTest();       


template myBeginMode3D*(camera: Camera3D,aspect:float=2.0,CULL_DISTANCE_NEAR:float=0.01,CULL_DISTANCE_FAR:float=100000.0; body: untyped) =
  myBeginMode3D(camera,aspect,CULL_DISTANCE_NEAR,CULL_DISTANCE_FAR)
  block:
    body
  endMode3D()