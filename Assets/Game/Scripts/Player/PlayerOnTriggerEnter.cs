using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class PlayerOnTriggerEnter : MonoBehaviour
{
    [SerializeField] List<GameObject> butterflies = new List<GameObject>();
   
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
   void OnTriggerEnter(Collider other)
    {
        //if (other.tag=="Player")
        //{
        //    foreach (var item in butterflies)
        //    {
        //        item.
        //    }
        //}
    }
}
