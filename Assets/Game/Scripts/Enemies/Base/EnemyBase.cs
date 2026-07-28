using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public abstract class EnemyBase : MonoBehaviour
{
    private EnemyEffectController _effectController;
    internal NavMeshAgent _agent;
    private AnimationActionComponent _actionComponent;
    private INPCStateBehavior _currentState;
    private Vector3 _startPosition;

    private void Awake()
    {
        _effectController = GetComponent<EnemyEffectController>();
        _agent = GetComponent<NavMeshAgent>();
        _actionComponent = GetComponent<AnimationActionComponent>();
        _startPosition = transform.position;
    }

    public abstract void Initialize();

    public virtual void ApplyTrapEffect(StatusEffectBase effect)
    {
        if (_effectController == null)
            _effectController = GetComponent<EnemyEffectController>();

        if (_effectController == null)
        {
            Debug.LogWarning($"{name}: missing EnemyEffectController, can't apply {effect}", this);
            return;
        }



        _effectController.AddEffect(effect);
    }

    internal void MoveTo(Vector3 destination)
    {
        _actionComponent.SetWalking(true);
        _agent.SetDestination(destination);
    }

    public void ChangeState(INPCStateBehavior newState)
    {
        _currentState?.Exit();
        _currentState = newState;
        _currentState?.Enter();
    }

    protected void TickState(float dt)
    {
        _currentState?.Tick(dt);


    }


    public abstract void StartActing();

    public void StopAct()
    {
        _currentState?.Exit();
        _currentState = null;

        var actingController = GetComponent<ActorActingController>();
        actingController?.StopActing();

        transform.position = _startPosition;
    }
}