using System.Collections.Generic;
using UnityEngine;

public class AnimationPlayState : INPCStateBehavior
{
    private readonly AnimationActionComponent _actionComponent;
    private readonly EnemyController _enemy;
    private readonly AnimationClip[] _clips;
    private readonly AnimationClip _loopClip;

    // kept for any existing callers that hand in a raw clip list directly
    public AnimationPlayState(EnemyController enemy, List<AnimationClip> clips)
    {
        _enemy = enemy;
        _actionComponent = enemy.GetComponent<AnimationActionComponent>();
        _clips = clips.ToArray();
    }

    // new — patrol hands off an InteractionPoint; this state decides what actually plays there
    public AnimationPlayState(EnemyController enemy, InteractionPoint point)
    {
        _enemy = enemy;
        _actionComponent = enemy.GetComponent<AnimationActionComponent>();

        var npcInteraction = enemy.GetComponent<NPCInteractionComponent>();
        var assignedAction = npcInteraction != null ? npcInteraction.AssignedAction : null;
        AnimationClip[] intro = point.animationSequence;

        if (assignedAction != null && assignedAction.animationClips.Length > 0)
        {
            _clips = new AnimationClip[intro.Length + assignedAction.animationClips.Length];
            intro.CopyTo(_clips, 0);
            assignedAction.animationClips.CopyTo(_clips, intro.Length);
            _loopClip = assignedAction.loopClip;
        }
        else
        {
            _clips = intro;
        }
    }

    public void Enter()
    {
        _actionComponent.PlayAnimations(_clips, () =>
        {
            _enemy.ChangeState(new PatrolState(_enemy));
        }, _loopClip);
    }

    public void Exit() { }
    public void Tick(float dt) { }
}