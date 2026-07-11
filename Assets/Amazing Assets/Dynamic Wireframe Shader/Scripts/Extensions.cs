// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System;
using System.Runtime.CompilerServices;


[assembly: InternalsVisibleTo("AmazingAssets.DynamicWireframeShader.Editor")]
[assembly: InternalsVisibleTo("AmazingAssets.DynamicWireframeShaderEditor")]
namespace AmazingAssets.DynamicWireframeShader
{
    static internal class ExtensionForString
    {
        public static string RemoveWhiteSpace(this string str)
        {
            return string.Join("", str.Split(default(string[]), StringSplitOptions.RemoveEmptyEntries));
        }
    }
}