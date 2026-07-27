using System;
using UnityEngine;

public class ActorController : EnemyBase, IInteractable
{

    private NPCInteractionComponent _interactComponent;
    private ActorPatrolState _state;
    private ActorActingController _actingController;


    private void Start()
    {
        _interactComponent = GetComponent<NPCInteractionComponent>();
        _actingController = GetComponent<ActorActingController>();

    }

    private void Update()
    {
        TickState(Time.deltaTime);
    }

    public void Interact(Action onFinished)
    {
        _interactComponent.SelectInterAction(onFinished);
    }

    public override void StartActing()
    {
        Debug.Log("dfdfdf STTTT");
        _state = new ActorPatrolState(this);
        _actingController.StartActing();
        //ChangeState(_state);
    }



    

    public override void Initialize()
    {
    }
}