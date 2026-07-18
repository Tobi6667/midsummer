using System;
using System.Collections.Generic;
using UnityEngine;

public class GuardController : EnemyBase, IInteractable
{
    
    private NPCInteractionComponent _interactComponent;


    public override void Initialize()
    {
        
    }


    public override void StartActing()
    {
      
    }

    public void Interact(Action onFinished)
    {
        Debug.Log("selectooooor");



        _interactComponent.TriggerInteraction(onFinished);
    }


// Start is called once before the first execution of Update after the MonoBehaviour is created
void Start()
    {
        _interactComponent = GetComponent<NPCInteractionComponent>();
    }


}
