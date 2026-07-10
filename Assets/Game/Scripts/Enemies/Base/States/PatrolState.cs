using UnityEngine;

public class PatrolState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly EnemyPatrollingComponent _patrolling;
    private readonly EnemyAwarenessComponent _enemyAwarenessComponent;

    public PatrolState(EnemyController enemy)
    {
        _enemyController = enemy;
        _patrolling = enemy.GetComponent<EnemyPatrollingComponent>();
        _enemyAwarenessComponent = enemy.GetComponent<EnemyAwarenessComponent>();
    }

    public void Enter()
    {
        _patrolling.StartPatrolling();
    }

    public void Exit()
    {
        _patrolling.StopPatroling();
    }

    public void Tick(float dt)
    {
        _patrolling.Tick(dt);

        if (_enemyAwarenessComponent.CurrentState == EnemyAwarenessComponent.AwarenessState.Alerted)
        {
            _enemyController.ChangeState(new ChaseState(_enemyController));
            return; // don't run further logic on a state you just left
        }
    }
}