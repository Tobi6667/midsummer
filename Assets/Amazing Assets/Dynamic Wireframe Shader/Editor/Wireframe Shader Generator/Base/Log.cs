// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using UnityEngine;


namespace AmazingAssets.DynamicWireframeShaderGenerator.Editor
{
    static internal class Log
    {
        static public void Message(string message)
        {
            Message(LogType.Log, message, null, null);
        }
        static public void Message(LogType logType, string message)
        {
            Message(logType, message, null, null);
        }
        static public void Message(LogType logType, string message, System.Exception exception, UnityEngine.Object context = null)
        {
            message = $"[{About.name}]\n" + message;

            StackTraceLogType save = Application.GetStackTraceLogType(logType);
            Application.SetStackTraceLogType(logType, StackTraceLogType.None);

            switch (logType)
            {
                case LogType.Assert:
                    {
                        if (context == null)
                            UnityEngine.Debug.LogAssertion(message);
                        else
                            UnityEngine.Debug.LogAssertion(message, context);

                    }
                    break;

                case LogType.Error:
                    {
                        if (context == null)
                            UnityEngine.Debug.LogError(message);
                        else
                            UnityEngine.Debug.LogError(message, context);
                    }
                    break;

                case LogType.Exception:
                    {
                        if (context == null)
                            UnityEngine.Debug.LogException(exception);
                        else
                            UnityEngine.Debug.LogException(exception, context);
                    }
                    break;

                case LogType.Log:
                    {
                        if (context == null)
                            UnityEngine.Debug.Log(message);
                        else
                            UnityEngine.Debug.Log(message, context);

                    }
                    break;

                case LogType.Warning:
                    {
                        if (context == null)
                            UnityEngine.Debug.LogWarning(message);
                        else
                            UnityEngine.Debug.LogWarning(message, context);

                    }
                    break;
            }

            Application.SetStackTraceLogType(logType, save);
        }
    }
}
