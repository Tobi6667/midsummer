using UnityEngine;

public class AnimationPlayState : INPCStateBehavior
{

    private EnemyAnimationActionComponent _actionComponent;

    void INPCStateBehavior.Enter()
    {
        _actionComponent?.PlayAnimation();
    }

    void INPCStateBehavior.Exit()
    {
       // _actionComponent?.StopAnimation();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    void INPCStateBehavior.Tick(float dt)
    {
        throw new System.NotImplementedException();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
