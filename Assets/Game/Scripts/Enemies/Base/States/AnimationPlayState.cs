using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;

public class AnimationPlayState : INPCStateBehavior
{

    private AnimationActionComponent _actionComponent;
    private AnimationClip[] _clips;
    private EnemyController _enemy;

    public AnimationPlayState(EnemyController enemy, List<AnimationClip> clips)
    {
        _enemy = enemy;
        _actionComponent = enemy.GetComponent<AnimationActionComponent>();
        _clips = clips.ToArray();
    }

    public void Enter()
    {
        _actionComponent.PlayAnimations(_clips, () => { 
            
            _enemy.ChangeState(new PatrolState(_enemy));
        });
    }

    public void Exit()
    {
       // _actionComponent?.StopAnimation();
    }


    public void Tick(float dt)
    {
    }


}
