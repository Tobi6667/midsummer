using UnityEngine;

public class ActorPatrolState : INPCStateBehavior
{
    private readonly EnemyBase _actor;
    private readonly EnemyPatrollingComponent _patrolling;
    private readonly AnimationActionComponent _sequencePlayer;

    private bool _playingSequence;

    public ActorPatrolState(EnemyBase actor)
    {
        _actor = actor;
        _patrolling = actor.GetComponent<EnemyPatrollingComponent>();
        _sequencePlayer = actor.GetComponent<AnimationActionComponent>();
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