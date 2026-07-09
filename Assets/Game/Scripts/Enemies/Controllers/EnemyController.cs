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
        _enemyPatrollingComponent.StartPatrolling();


    }

    private void Update()
    {

        if(_stateBehavior != null) _stateBehavior.Tick(Time.deltaTime);

        switch (_enemyAwarenessComponent.CurrentState)
        {
            case EnemyAwarenessComponent.AwarenessState.Idle:
                _enemyPatrollingComponent.StartPatrolling();
                break;
            case EnemyAwarenessComponent.AwarenessState.Suspicious:
                _enemyPatrollingComponent.StopPatroling();
                break;
            case EnemyAwarenessComponent.AwarenessState.Alerted:
                _enemyPatrollingComponent.StopPatroling();
                break;
            default:
                _enemyPatrollingComponent.StopPatroling();
                break;
        }
    }

}
