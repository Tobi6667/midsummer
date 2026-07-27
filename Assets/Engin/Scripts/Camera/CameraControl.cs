using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class CameraControl : MonoBehaviour
{
    // Start is called before the first frame update
   [System.Serializable]
   public class CameraSettings
    {
        [Header("Camera Move Settings")]
        public float zoomSpeed = 5;
        public float moveSpeed = 5;
        public float rotationSpeed = 5;
        public float zoomFieldOfView = 20;
        public float originalFieldOfView = 70;
        public float MouseX_Sensitivity =100; 
        public float MouseY_Sensitivity =100;
        public float MaxClampAngle = 90;
        public float MinClampAngle = -30;
        [Header("Camera Collision")]
        public Transform camPosition;
        public LayerMask camCollisionLayers;
    }
    [SerializeField]
    public CameraSettings cameraSettings;
    [System.Serializable]
    public class CameraInputSettings
    {
        public string MouseXAxis = "Mouse X";
        public string MouseYAxis = "Mouse Y";
        public string AimingInput = "Fire2";


    }
    [SerializeField]
    public CameraInputSettings inputSettings;
    Camera mainCam;
    Camera UICam;
    Transform center;
    Transform target;
    float cameraXRotation = 0;
    float cameraYRotation = 0;
    Vector3 initialCamPosition;
    RaycastHit hit;


    void Start()
    {
        mainCam = Camera.main;
        center = transform.GetChild(0);
        FindPlayer();
        initialCamPosition = mainCam.transform.localPosition;
        UICam = Camera.main.GetComponentInChildren<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!target)
            return;
        if (!Application.isPlaying)
            return; 
        RotateCamera();
        ZoomCamera();
        HandleCamCollision();
    }
    private void LateUpdate()
    {

        if (target)
            FollowPlayer();
        else
            FindPlayer();

    }
    void FindPlayer()
    {
        target = GameObject.FindGameObjectWithTag("Player").transform;  
    }
    void FollowPlayer()
    {
        Vector3 moveVector = Vector3.Lerp(transform.position, target.position, cameraSettings.moveSpeed * Time.deltaTime);
        transform.position = moveVector;

    }
    void RotateCamera()
    {
        cameraXRotation += Input.GetAxis(inputSettings.MouseYAxis)* cameraSettings.MouseY_Sensitivity;
        cameraYRotation += Input.GetAxis(inputSettings.MouseXAxis)* cameraSettings.MouseX_Sensitivity;
        cameraXRotation = Mathf.Clamp(cameraXRotation, cameraSettings.MinClampAngle, cameraSettings.MaxClampAngle);
        cameraYRotation = Mathf.Repeat(cameraYRotation, 360);
        Vector3 rotatingAngle = new Vector3(cameraXRotation, cameraYRotation,0);
        Quaternion rotation = Quaternion.Slerp(center.transform.localRotation, Quaternion.Euler(rotatingAngle), cameraSettings.rotationSpeed*Time.deltaTime);
        center.transform.localRotation = rotation;

    }
    void ZoomCamera()
    {
        if (Input.GetButton(inputSettings.AimingInput))
        {
            mainCam.fieldOfView = Mathf.Lerp(mainCam.fieldOfView, cameraSettings.zoomFieldOfView, cameraSettings.zoomSpeed * Time.deltaTime);
            UICam.fieldOfView = Mathf.Lerp(mainCam.fieldOfView, cameraSettings.zoomFieldOfView, cameraSettings.zoomSpeed * Time.deltaTime);
        }
        else
        {
            mainCam.fieldOfView = Mathf.Lerp(mainCam.fieldOfView, cameraSettings.originalFieldOfView, cameraSettings.zoomSpeed * Time.deltaTime);
            UICam.fieldOfView = Mathf.Lerp(mainCam.fieldOfView, cameraSettings.originalFieldOfView, cameraSettings.zoomSpeed * Time.deltaTime);
        }
    }
    void HandleCamCollision()
    {  if (!Application.isPlaying)
            return;
        if(Physics.Linecast(target.position+target.up, cameraSettings.camPosition.position, out hit, cameraSettings.camCollisionLayers))
        {
            Vector3 newCamPos = new Vector3(hit.point.x + hit.normal.x * .2f, hit.point.y + hit.normal.y * .8f, hit.point.z + hit.normal.z * .2f);
            mainCam.transform.position = Vector3.Lerp(mainCam.transform.position, newCamPos, Time.deltaTime * cameraSettings.moveSpeed);
        }
        else
        {
            mainCam.transform.localPosition = Vector3.Lerp(mainCam.transform.localPosition, initialCamPosition, Time.deltaTime * cameraSettings.moveSpeed);

        }
        Debug.DrawLine(target.position + target.up, cameraSettings.camPosition.position, Color.blue);
    }
}
