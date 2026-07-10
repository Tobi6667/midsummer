using UnityEngine;


public class EnemyController : EnemyBase
{
    private EnemyAwarenessComponent _enemyAwarenessComponent;
    private EnemyPatrollingComponent _enemyPatrollingComponent;
    private EEnemyState _currentState = EEnemyState.Patrolling;
    private INPCStateBehavior _stateBehavior;

    private void Awake()
    {
        _enemyAwarenessComponent = GetComponent<EnemyAwarenessComponent>();
        _enemyPatrollingComponent = GetComponent<EnemyPatrollingComponent>();
    }

    private void Start()
    {
        _enemyPatrollingComponent.Initialize();
        _stateBehavior = new PatrolState(this);
        _stateBehavior.Enter(); // <-- you're missing this currently

    }

    private void Update()
    {

        if(_stateBehavior != null) _stateBehavior.Tick(Time.deltaTime);


    }

    internal void ChangeState(INPCStateBehavior newState)
    {
        _stateBehavior?.Exit();
        _stateBehavior = newState;
        _stateBehavior.Enter();
    }

}
