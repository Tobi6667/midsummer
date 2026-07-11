// Dynamic Wireframe Shader <https://u3d.as/3WyY>
// Copyright (c) Amazing Assets <https://amazingassets.world>

using System.Collections.Generic;

using UnityEngine;


namespace AmazingAssets.DynamicWireframeShader
{
    [HelpURL(About.documentationURL)]
    [AddComponentMenu("Amazing Assets/Dynamic Wireframe Shader/Dynamic Mask Controller")]
    [ExecuteAlways]
    public class DynamicMaskController : MonoBehaviour
    {
        static public List<DynamicMaskController> allControllers = null;


        public Enum.DynamicMaskType maskType;

        [HideInInspector] public Transform maskPlaneTransform;
        [HideInInspector] public Vector3 maskPlanePosition = Vector3.zero;
        [HideInInspector] public Vector3 maskPlaneNormal = Vector3.up;

        [HideInInspector] public Transform maskSphereTransform;
        [HideInInspector] public Vector3 maskSpherePosition = Vector3.zero;
        [HideInInspector] public float maskSphereRadius = 2;
        [HideInInspector] public bool maskSphereUsePointLight = false;
        [HideInInspector] public Light maskSpherePointLight = null;

        [HideInInspector] public Transform maskCubeTransform;
        [HideInInspector] public Vector3 maskCubePosition = Vector3.zero;
        [HideInInspector] public Vector3 maskCubeRotation = Vector3.zero;
        [HideInInspector] public Vector3 maskCubeScale = Vector3.one;

        [HideInInspector] public Transform maskCapsuleStartTransform;
        [HideInInspector] public Transform maskCapsuleEndTransform;
        [HideInInspector] public Vector3 maskCapsuleStartPosition = Vector3.zero;
        [HideInInspector] public Vector3 maskCapsuleEndPosition = new Vector3(10, 0, 0);
        [HideInInspector] public float maskCapsuleRadius = 2;

        [HideInInspector] public Transform maskConeStartTransform;
        [HideInInspector] public Transform maskConeEndTransform;
        [HideInInspector] public Vector3 maskConeStartPosition = Vector3.zero;
        [HideInInspector] public Vector3 maskConeEndPosition = new Vector3(10, 0, 0);
        [HideInInspector] public float maskConeRadius = 2;
        [HideInInspector] public bool maskConeUseSpotLight = false;
        [HideInInspector] public Light maskConeSpotLight = null;

        [HideInInspector] public float edgeFalloff = 0;

        [HideInInspector] public string shaderVariableReferenceName = string.Empty;
        [HideInInspector] public Enum.ShaderPropertyScope shaderVariableScope = Enum.ShaderPropertyScope.Local;


        [HideInInspector] public Enum.ScriptUpdateMode updateMode = Enum.ScriptUpdateMode.FixedUpdate;
        [HideInInspector] public Enum.DrawGizmos drawGizmos = Enum.DrawGizmos.WhenSelected;
        

        [HideInInspector] public List<Material> listMaterials;

        bool isActive;


        void OnValidate()
        {
            maskSphereRadius = Mathf.Max(0f, maskSphereRadius);
            maskCapsuleRadius = Mathf.Max(0f, maskCapsuleRadius);
            maskConeRadius = Mathf.Max(0f, maskConeRadius);
            edgeFalloff = Mathf.Max(0f, edgeFalloff);
        }
        private void OnEnable()
        {
            isActive = true;
        }
        private void OnDisable()
        {
            isActive = false;

            UpdateShaderData();

            if (allControllers != null && allControllers.Contains(this))
                allControllers.Remove(this);
        }
        void Start()
        {
            isActive = true;

            Initialize();
        }
        private void Update()
        {
            //Force update in editor
            if ((Application.isEditor && Application.isPlaying == false) || updateMode == Enum.ScriptUpdateMode.EveryFrame)
                UpdateShaderData();
        }
        private void FixedUpdate()
        {
            if (updateMode == Enum.ScriptUpdateMode.FixedUpdate)
                UpdateShaderData();
        }

        private void OnDrawGizmosSelected()
        {
            if (drawGizmos == Enum.DrawGizmos.WhenSelected)
                DrawGizmos();
        }
        public void OnDrawGizmos()
        {
            if (drawGizmos == Enum.DrawGizmos.Always)
                DrawGizmos();
        }
        private void Reset()
        {
            maskSpherePosition = Vector3.zero;
            maskSphereRadius = 1;

            maskCubePosition = Vector3.zero;
            maskCubeRotation = Vector3.zero;
            maskCubeScale = Vector3.one;

            maskCapsuleStartPosition = Vector3.zero;
            maskCapsuleEndPosition = new Vector3(10, 0, 0);
            maskCapsuleRadius = 1;

            maskConeStartPosition = Vector3.zero;
            maskConeEndPosition = new Vector3(10, 0, 0);
            maskConeRadius = 1;

            edgeFalloff = 0;

            shaderVariableReferenceName = string.Empty;
        }

        void Initialize()
        {
            if (allControllers == null)
                allControllers = new List<DynamicMaskController>();

            if (allControllers.Contains(this) == false)
                allControllers.Add(this);
        }
        public void UpdateShaderData()
        {
            if (allControllers == null || allControllers.Contains(this) == false)
                Initialize();


            if (string.IsNullOrWhiteSpace(shaderVariableReferenceName))
            {
                if (Application.isPlaying)
                    Log.Message(LogType.Error, "WireframeShaderMaskController 'shaderPropertyName' is empty", null, this.gameObject);
            }
            else
            {
                float falloff = Mathf.Max(0.001f, edgeFalloff);
                float active = isActive ? 1 : 0;

                Matrix4x4 matrix = new Matrix4x4();
                switch (maskType)
                {
                    case Enum.DynamicMaskType.Plane:
                        {
                            GetPlaneData(out Vector3 position, out Vector3 normal);

                            matrix.SetRow(0, position);
                            matrix.SetRow(1, normal);
                            matrix.SetRow(2, Vector4.zero);
                            matrix.SetRow(3, new Vector4(falloff, active, 0, 0));
                        }
                        break;

                    case Enum.DynamicMaskType.Sphere:
                        {
                            GetSphereData(out Vector3 position, out float radius, out float intensity);

                            matrix.SetRow(0, Combine(position, radius));
                            matrix.SetRow(1, Vector4.zero);
                            matrix.SetRow(2, Vector4.zero);
                            matrix.SetRow(3, new Vector4(falloff, active * intensity, 0, 0));
                        }
                        break;

                    case Enum.DynamicMaskType.Cube:
                        {
                            GetCubeData(out Vector3 position, out Quaternion rotation, out Vector3 size);

                            matrix.SetRow(0, position);
                            matrix.SetRow(1, QuaternionToVector4(rotation));
                            matrix.SetRow(2, size);
                            matrix.SetRow(3, new Vector4(falloff, active, 0, 0));
                        }
                        break;

                    case Enum.DynamicMaskType.Capsule:
                        {
                            GetCapsuleData(out Vector3 position, out Vector3 normal, out float height);

                            matrix.SetRow(0, Combine(position, height));
                            matrix.SetRow(1, Combine(normal, maskCapsuleRadius));
                            matrix.SetRow(2, Vector4.zero);
                            matrix.SetRow(3, new Vector4(falloff, active, 0, 0));
                        }
                        break;

                    case Enum.DynamicMaskType.Cone:
                        {
                            GetConeData(out Vector3 position, out Vector3 normal, out float height, out float radius, out float intensity);

                            matrix.SetRow(0, Combine(position, height));
                            matrix.SetRow(1, Combine(normal, radius));
                            matrix.SetRow(2, Vector4.zero);
                            matrix.SetRow(3, new Vector4(falloff, active * intensity, 0, 0));
                        }
                        break;

                    default:
                        break;
                }



                if (shaderVariableScope == Enum.ShaderPropertyScope.Local)
                {
                    if (listMaterials == null || listMaterials.Count == 0)
                        return;


                    for (int i = 0; i < listMaterials.Count; i++)
                    {
                        if (listMaterials[i] == null)
                            continue;

                        listMaterials[i].SetMatrix(shaderVariableReferenceName, matrix);
                    }
                }
                else
                {
                    Shader.SetGlobalMatrix(shaderVariableReferenceName, matrix);
                }
            }
        }

        void GetPlaneData(out Vector3 position, out Vector3 normal)
        {
            if (maskPlaneTransform != null)
            {
                maskPlanePosition = maskPlaneTransform.position;
                maskPlaneNormal = maskPlaneTransform.up;
            }

            position = maskPlanePosition;
            normal = maskPlaneNormal;
        }
        void GetSphereData(out Vector3 position, out float radius, out float intensity)
        {
            if (maskSphereUsePointLight)
            {
                position = Vector3.zero;
                radius = 0;
                intensity = 1;

                if (maskSpherePointLight != null)
                {
                    position = maskSpherePointLight.transform.position;
                    radius = maskSpherePointLight.range;


                    intensity *= Mathf.Clamp01(maskSpherePointLight.intensity);
                    intensity *= Mathf.Clamp01(maskSpherePointLight.range);
                }
            }
            else
            {
                if (maskSphereTransform != null)
                {
                    maskSpherePosition = maskSphereTransform.position;
                }

                position = maskSpherePosition;
                radius = maskSphereRadius;
                intensity = 1;
            }
        }
        void GetCubeData(out Vector3 position, out Quaternion rotation, out Vector3 size)
        {
            if (maskCubeTransform != null)
            {
                maskCubePosition = maskCubeTransform.position;
                maskCubeRotation = maskCubeTransform.rotation.eulerAngles;
                maskCubeScale = maskCubeTransform.localScale;
            }

            position = maskCubePosition;
            rotation = Quaternion.Euler(maskCubeRotation);
            size = maskCubeScale;

            size.x = Mathf.Abs(size.x);
            size.y = Mathf.Abs(size.y);
            size.z = Mathf.Abs(size.z);
        }
        void GetCapsuleData(out Vector3 position, out Vector3 normal, out float height)
        {
            //Start
            if (maskCapsuleStartTransform != null)
                maskCapsuleStartPosition = maskCapsuleStartTransform.position;

            position = maskCapsuleStartPosition;


            //End
            if (maskCapsuleEndTransform != null)
                maskCapsuleEndPosition = maskCapsuleEndTransform.position;

            Vector3 positionEnd = maskCapsuleEndPosition;


            normal = (positionEnd - position).normalized;

            height = Vector3.Distance(position, positionEnd);
        }
        void GetConeData(out Vector3 position, out Vector3 normal, out float height, out float radius, out float intensity)
        {
            if (maskConeUseSpotLight)
            {
                position = Vector3.zero;
                normal = Vector3.up;
                height = 0;
                radius = 0;
                intensity = 1;

                if (maskConeSpotLight != null)
                {
                    maskConeStartPosition = maskConeSpotLight.transform.position;

                    position = maskConeStartPosition;

                    maskConeEndPosition = maskConeSpotLight.transform.position + maskConeSpotLight.transform.forward * maskConeSpotLight.range;

                    normal = maskConeSpotLight.transform.forward;

                    height = maskConeSpotLight.range;

                    radius = maskConeSpotLight.range * Mathf.Tan(maskConeSpotLight.spotAngle * 0.5f * Mathf.Deg2Rad);


                    intensity *= Mathf.Clamp01(maskConeSpotLight.intensity);
                    intensity *= Mathf.Clamp01(maskConeSpotLight.spotAngle - 1f);
                }
            }
            else
            {
                //Start
                if (maskConeStartTransform != null)
                    maskConeStartPosition = maskConeStartTransform.position;

                position = maskConeStartPosition;


                //End
                if (maskConeEndTransform != null)
                    maskConeEndPosition = maskConeEndTransform.position;

                Vector3 positionEnd = maskConeEndPosition;


                normal = (positionEnd - position).normalized;

                height = Vector3.Distance(position, positionEnd);

                radius = maskConeRadius;

                intensity = 1;
            }
        }

        static Vector4 Combine(Vector3 vector, float w)
        {
            return new Vector4(vector.x, vector.y, vector.z, w);
        }
        static Vector4 QuaternionToVector4(Quaternion q)
        {
            return new Vector4(q.x, q.y, q.z, q.w);
        }

        void DrawGizmos()
        {
            Gizmos.color = Color.magenta * 0.5f;

            switch (maskType)
            {
                case Enum.DynamicMaskType.Plane:
                    {
                        GetPlaneData(out Vector3 position, out Vector3 normal);
                        if (normal.magnitude != 0)
                        {
                            Quaternion rotation = Quaternion.LookRotation(normal, Vector3.up);

                            GizmoDrawArrow(position, position + normal, 0.3f, 15);
                            GizmoDrawCube(position, rotation, new Vector3(1, 1, 0));
                        }
                    }
                    break;

                case Enum.DynamicMaskType.Sphere:
                    {
                        GetSphereData(out Vector3 position, out float radius, out float maskIntensity);
                        Gizmos.DrawWireSphere(position, radius);
                    }
                    break;

                case Enum.DynamicMaskType.Cube:
                    {
                        GetCubeData(out Vector3 position, out Quaternion rotation, out Vector3 size);
                        GizmoDrawCube(position, rotation, size);
                    }
                    break;

                case Enum.DynamicMaskType.Capsule:
                    {
                        GetCapsuleData(out Vector3 position, out Vector3 normal, out float height);
                        GizmoDrawCapsule(position, position + normal * height, maskCapsuleRadius);
                    }
                    break;

                case Enum.DynamicMaskType.Cone:
                    {
                        GetConeData(out Vector3 position, out Vector3 normal, out float height, out float radius, out float maskIntensity);
                        GizmoDrawCone(position, position + normal * height, radius);
                    }
                    break;

                default:
                    break;
            }
        }
        static void GizmoDrawCube(Vector3 position, Quaternion rotation, Vector3 scale)
        {
            Matrix4x4 save = Gizmos.matrix;

            Gizmos.matrix = Matrix4x4.TRS(position, rotation, scale);
            Gizmos.DrawWireCube(Vector3.zero, Vector3.one);

            Gizmos.matrix = save;
        }
        static void GizmoDrawCapsule(Vector3 start, Vector3 end, float radius)
        {
            Vector3 up = (end - start).normalized * radius;
            Vector3 forward = Vector3.Slerp(up, -up, 0.5f);
            Vector3 right = Vector3.Cross(up, forward).normalized * radius;

            float height = (start - end).magnitude;
            float sideLength = Mathf.Max(0, (height * 0.5f + radius) - radius);
            Vector3 middle = (end + start) * 0.5f;

            start = middle + ((start - middle).normalized * sideLength);
            end = middle + ((end - middle).normalized * sideLength);

            //Radial circles
            GizmoDrawCircle(start, up, radius);
            GizmoDrawCircle(end, -up, radius);

            //Side lines
            Gizmos.DrawLine(start + right, end + right);
            Gizmos.DrawLine(start - right, end - right);

            Gizmos.DrawLine(start + forward, end + forward);
            Gizmos.DrawLine(start - forward, end - forward);

            for (int i = 1; i < 26; i++)
            {

                //Start endcap
                Gizmos.DrawLine(Vector3.Slerp(right, -up, i / 25.0f) + start, Vector3.Slerp(right, -up, (i - 1) / 25.0f) + start);
                Gizmos.DrawLine(Vector3.Slerp(-right, -up, i / 25.0f) + start, Vector3.Slerp(-right, -up, (i - 1) / 25.0f) + start);
                Gizmos.DrawLine(Vector3.Slerp(forward, -up, i / 25.0f) + start, Vector3.Slerp(forward, -up, (i - 1) / 25.0f) + start);
                Gizmos.DrawLine(Vector3.Slerp(-forward, -up, i / 25.0f) + start, Vector3.Slerp(-forward, -up, (i - 1) / 25.0f) + start);

                //End endcap
                Gizmos.DrawLine(Vector3.Slerp(right, up, i / 25.0f) + end, Vector3.Slerp(right, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(-right, up, i / 25.0f) + end, Vector3.Slerp(-right, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(forward, up, i / 25.0f) + end, Vector3.Slerp(forward, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(-forward, up, i / 25.0f) + end, Vector3.Slerp(-forward, up, (i - 1) / 25.0f) + end);
            }
        }
        static void GizmoDrawCone(Vector3 start, Vector3 end, float radius)
        {
            Vector3 up = (end - start).normalized * radius;
            Vector3 forward = Vector3.Slerp(up, -up, 0.5f);
            Vector3 right = Vector3.Cross(up, forward).normalized * radius;


            //Radial circles
            GizmoDrawCircle(end, -up, radius);

            //Side lines
            Gizmos.DrawLine(start, end + right);
            Gizmos.DrawLine(start, end - right);

            Gizmos.DrawLine(start, end + forward);
            Gizmos.DrawLine(start, end - forward);

            for (int i = 1; i < 26; i++)
            {
                //End endcap
                Gizmos.DrawLine(Vector3.Slerp(right, up, i / 25.0f) + end, Vector3.Slerp(right, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(-right, up, i / 25.0f) + end, Vector3.Slerp(-right, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(forward, up, i / 25.0f) + end, Vector3.Slerp(forward, up, (i - 1) / 25.0f) + end);
                Gizmos.DrawLine(Vector3.Slerp(-forward, up, i / 25.0f) + end, Vector3.Slerp(-forward, up, (i - 1) / 25.0f) + end);
            }
        }
        static void GizmoDrawCircle(Vector3 position, Vector3 up, float radius)
        {
            up = ((up == Vector3.zero) ? Vector3.up : up).normalized * radius;
            Vector3 _forward = Vector3.Slerp(up, -up, 0.5f);
            Vector3 _right = Vector3.Cross(up, _forward).normalized * radius;

            Matrix4x4 matrix = new Matrix4x4();

            matrix[0] = _right.x;
            matrix[1] = _right.y;
            matrix[2] = _right.z;

            matrix[4] = up.x;
            matrix[5] = up.y;
            matrix[6] = up.z;

            matrix[8] = _forward.x;
            matrix[9] = _forward.y;
            matrix[10] = _forward.z;

            Vector3 _lastPoint = position + matrix.MultiplyPoint3x4(new Vector3(Mathf.Cos(0), 0, Mathf.Sin(0)));
            Vector3 _nextPoint = Vector3.zero;

            for (var i = 0; i < 91; i++)
            {
                _nextPoint.x = Mathf.Cos((i * 4) * Mathf.Deg2Rad);
                _nextPoint.z = Mathf.Sin((i * 4) * Mathf.Deg2Rad);
                _nextPoint.y = 0;

                _nextPoint = position + matrix.MultiplyPoint3x4(_nextPoint);

                Gizmos.DrawLine(_lastPoint, _nextPoint);
                _lastPoint = _nextPoint;
            }
        }
        static void GizmoDrawArrow(Vector3 from, Vector3 to, float arrowHeadLength, float arrowHeadAngle)
        {
            Gizmos.DrawLine(from, to);
            var direction = to - from;
            var right = Quaternion.LookRotation(direction) * Quaternion.Euler(0, 180 + arrowHeadAngle, 0) * new Vector3(0, 0, 1);
            var left = Quaternion.LookRotation(direction) * Quaternion.Euler(0, 180 - arrowHeadAngle, 0) * new Vector3(0, 0, 1);
            Gizmos.DrawLine(to, to + right * arrowHeadLength);
            Gizmos.DrawLine(to, to + left * arrowHeadLength);
        }
    }
}