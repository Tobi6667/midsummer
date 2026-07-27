using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraChase : MonoBehaviour
{
    //Third person shooter game usually camera rotates when the character rotates
    //Parent camtarget to base of your character
    //Adventure or RPG camera can be seperate from character 
    //Parent camtarget to blank object
    //Parent   rotator to main character

    Vector3 offset = new Vector3(0, 0f, 2);
    public Transform camTarget;
    public float pLerp = .01f;
    public float rLerp = .02f;

    void Update()
    {
        transform.position = Vector3.Lerp(transform.position, camTarget.position-offset, pLerp);
        transform.rotation = Quaternion.Lerp(transform.rotation, camTarget.rotation, rLerp);
    }
}

