using System;
using UnityEngine;

public class Chair : InteractActionBase, IInteractable
{
  

    public void Interact(Action onFinished)
    {
        ActManager.Instance.PlayAct();

    }

    public void StopInteracting()
    {
        ActManager.Instance.StopAct();
    }



    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
