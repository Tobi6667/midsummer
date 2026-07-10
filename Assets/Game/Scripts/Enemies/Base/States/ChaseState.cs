using UnityEngine;

public class ChaseState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly EnemyAwarenessComponent _enemyAwarenessComponent;
    // add EnemyChasingComponent here once it exists

    public ChaseState(EnemyController enemy)
    {
        _enemyController = enemy;
        _enemyAwarenessComponent = enemy.GetComponent<EnemyAwarenessComponent>();
    }

    public void Enter()
    {
        // e.g. _chasing.StartChasing(_enemyAwarenessComponent.LastKnownPosition);
    }

    public void Exit()
    {
        // e.g. _chasing.StopChasing();
    }

    public void Tick(float dt)
    {
        Debug.Log("ChaseState Tick");
        if (_enemyAwarenessComponent.CurrentState == EnemyAwarenessComponent.AwarenessState.Idle)
        {
            _enemyController.ChangeState(new PatrolState(_enemyController));
            return;
        }

        // chase movement logic
    }
}