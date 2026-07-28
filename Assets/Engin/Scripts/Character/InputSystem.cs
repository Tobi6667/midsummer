using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputSystem : MonoBehaviour
{
 /*   Move moveScript;
    [System.Serializable]
    public class InputSettings

    {
        public string forwardInput = "Vertical";
        public string strafeInput = "Horizontal";
        public string sprintInput = "Sprint";
        public string aimInput = "Fire2";
        public string fire = "Fire1";
    }
    public InputSettings input;
    Transform camCenter;
    Transform mainCam;
    public Bow bowScript;
    public bool testAim;
    bool hitdetected;
    bool isAiming;
    [Header("Camera and Character Synching")]
    public float lookDistance = 5;
    public float lookSpeed = 5;

    [Header("Aiming Settings")]
    RaycastHit hit;
    Ray ray;
    public LayerMask aimLayer;

    [Header("Spine Settings")]
    public Transform spine;
    public Vector3 spineOffset;
    [Header("Head Rotation Settings")]
    public float lookAtPoint = 2.8f;

    void Start()
    {
        moveScript = GetComponent<Move>();
        camCenter = Camera.main.transform.parent;
        mainCam = Camera.main.transform;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetAxis(input.forwardInput) != 0 || Input.GetAxis(input.strafeInput) != 0)
            RotateToCamView();
        isAiming = Input.GetButton(input.aimInput);
        if (testAim)
            isAiming = true;
        moveScript.AnimateCharacter(Input.GetAxis(input.forwardInput), Input.GetAxis(input.strafeInput));
        moveScript.SprintCharacter(Input.GetButton(input.sprintInput));
        moveScript.CharacterAim(isAiming);
        if (isAiming)
        {
            Aim();
            moveScript.CharacterPullString(Input.GetButton(input.fire));
            if (Input.GetButtonUp(input.fire))
            {
                moveScript.CharacterFireArrow();
                if(hitdetected)
                {
                    bowScript.Fire(hit.point);
                }
                else
                {
                    bowScript.Fire(ray.GetPoint(300));
                }
            }

        }
        else
        {
            bowScript.RemoveCrossHair();
            bowScript.DisableArrow();
            Release();
        }

        //if (Input.GetButtonUp(input.fire))
        //    moveScript.CharacterFireArrow();
    }
    private void LateUpdate()
    {
        if (isAiming)
            RotateCharacterSpine();
    }
    void RotateToCamView()
    {
        Vector3 camCenterPos = camCenter.position;
        Vector3 lookPoint = camCenterPos + (camCenter.forward * lookDistance);
        Vector3 direction = lookPoint - transform.position;
        Quaternion lookRotation = Quaternion.LookRotation(direction);
        lookRotation.x = 0;
        lookRotation.z = 0;
        Quaternion finalRotation = Quaternion.Lerp(transform.rotation, lookRotation, Time.deltaTime * lookSpeed);
        transform.rotation = finalRotation;
    }
    void Aim()
    {
        Vector3 camPosition = mainCam.position;
        Vector3 direction = mainCam.forward;
        ray = new Ray(camPosition, direction);
        if (Physics.Raycast(ray, out hit, 500, aimLayer))
        {
            hitdetected = true;
            Debug.DrawLine(ray.origin, hit.point, Color.green);
            bowScript.ShowCrossHair(hit.point);
        }
        else
        {
            hitdetected = false;
            bowScript.RemoveCrossHair();
           bowScript.DisableArrow();
            
        }
    }
    void RotateCharacterSpine()
    {
        spine.LookAt(ray.GetPoint(50));
        spine.Rotate(spineOffset);
    }
    //public void OnApplicationPause(bool pause)
    //{
    //    bowScript.PullString();

    //}
    public void Pull()
    {
        bowScript.PullString();
    }
    public void EnableArrow()
    {
        bowScript.PickArrow();
    }
    public void DisableArrow()
    {
        bowScript.DisableArrow();
    }
    public void Release()
    {
        bowScript.ReleaseString();
    } */
}
