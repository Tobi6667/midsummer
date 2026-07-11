// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

namespace AmazingAssets.DynamicWireframeShader
{
    public static class Enum
    {
        public enum DynamicMaskType { Plane, Sphere, Cube, Capsule, Cone }
        public enum DrawGizmos { Off, Always, WhenSelected }
        public enum ScriptUpdateMode { EveryFrame, FixedUpdate, Custom }
        public enum ShaderPropertyScope { Local, Global }
    }
}