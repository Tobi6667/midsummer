using UnityEngine;

public class ActorController : EnemyBase, IInteractable
{

    private NPCInteractionComponent _interactComponent;
    private void Start()
    {
        _interactComponent = GetComponent<NPCInteractionComponent>();
    }

    private void Update()
    {
        TickState(Time.deltaTime);
    }


    internal void StartActing()
    {
        ChangeState(new ActorPatrolState(this));
    }

    public void Interact()
    {
        _interactComponent.SelectInterAction();
    }
}