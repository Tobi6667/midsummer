using UnityEngine;
using UnityEngine.AI;

public abstract class EnemyBase : MonoBehaviour
{
    private EnemyEffectController _effectController;
    private NavMeshAgent _agent;
    private INPCStateBehavior _currentState;

    private void Awake()
    {
        _effectController = GetComponent<EnemyEffectController>();
        _agent = GetComponent<NavMeshAgent>();
    }


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
}
