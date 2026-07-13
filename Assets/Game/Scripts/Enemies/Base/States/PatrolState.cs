using UnityEngine;

public class PatrolState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly EnemyPatrollingComponent _patrolling;
    private readonly EnemyAwarenessComponent _enemyAwarenessComponent;
    private readonly AnimationActionComponent _sequencePlayer;

    private bool _playingSequence;

    public PatrolState(EnemyController enemy)
    {
        _enemyController = enemy;
        _patrolling = enemy.GetComponent<EnemyPatrollingComponent>();
        _enemyAwarenessComponent = enemy.GetComponent<EnemyAwarenessComponent>();
        _sequencePlayer = enemy.GetComponent<AnimationActionComponent>();
    }

    public void Enter()
    {
        _playingSequence = false;
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
            return; // don't run further logic on a state you just left
        }

        if (_playingSequence)
            return; // frozen at waypoint, sequence coroutine is driving things

        _patrolling.Tick(dt);
    }

    private void HandleWaypointReached(Transform waypoint)
    {
        if (_playingSequence) return;

        if (waypoint.TryGetComponent(out InteractionPoint animWaypoint))
        {
            _playingSequence = true;
            _patrolling.StopPatroling(); // freeze movement, keep patrol "active" for resume
                 _sequencePlayer.PlayAnimations(animWaypoint.animationSequence, OnSequenceComplete);
        }
    }

    private void OnSequenceComplete()
    {
        _playingSequence = false;
        _patrolling.StartPatrolling(); // resume toward next waypoint
    }
}