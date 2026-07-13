// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;


namespace AmazingAssets.DynamicWireframeShader.Examples
{
    [ExecuteAlways, ExecuteInEditMode]
    public class ToggleSceneViewEffects : MonoBehaviour
    {
        private void OnEnable()
        {
            SceneView.SceneViewState sceneViewState = new SceneView.SceneViewState();
            sceneViewState.SetAllEnabled(true);
            sceneViewState.showFog = false;

            foreach (SceneView sceneView in SceneView.sceneViews)
            {
                sceneView.sceneViewState = sceneViewState;
            }
             
            SceneView.RepaintAll();
        }
    }
}
#endif