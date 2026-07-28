using UnityEngine;

public class EnemyInTrapState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly AnimationClip[] _clips;

    public EnemyInTrapState(EnemyController enemy, AnimationClip[] clips)
    {
        _enemyController = enemy;
        _clips = clips;
    }

    public void Enter()
    {
        var animationAction = _enemyController.GetComponent<AnimationActionComponent>();
        animationAction.PlayAnimations(_clips, () =>
        {
           // _enemyController.ChangeState(new PatrolState(_enemyController));
        });
    }

    public void Exit() { }

    // deliberately ignores awareness — no Patrol/Chase/Attack transitions can
    // happen while trapped, regardless of what the player does nearby.
    public void Tick(float dt) { }
}