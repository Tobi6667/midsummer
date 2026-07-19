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
        _patrolling.OnWaypointReached += HandleWaypointReached;
    }

    public void Exit()
    {
        _patrolling.OnWaypointReached -= HandleWaypointReached;
        _patrolling.StopPatroling();
    }

    public void Tick(float dt)
    {
        if (_enemyAwarenessComponent.CurrentState == EnemyAwarenessComponent.AwarenessState.Alerted)
        {
            _enemyController.ChangeState(new ChaseState(_enemyController));
            Exit();
            return;
        }

        _patrolling.Tick(dt);
    }

    private void HandleWaypointReached(Transform waypoint)
    {
        if (waypoint.TryGetComponent(out InteractionPoint animWaypoint))
        {
            _patrolling.StopPatroling();
            _enemyController.ChangeState(new AnimationPlayState(_enemyController, animWaypoint));
        }
    }
}