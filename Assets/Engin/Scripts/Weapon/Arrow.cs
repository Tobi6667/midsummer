using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{
    Rigidbody rb;
    BoxCollider bx;
    bool DisableRotation;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        bx = GetComponent<BoxCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        if(!DisableRotation)
        transform.rotation = Quaternion.LookRotation(rb.linearVelocity);
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag != "Player")
        {
            DisableRotation = true;
            rb.isKinematic = true;
            bx.isTrigger = true;
        }
    }
}
