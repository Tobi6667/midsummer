using System.Diagnostics;
using UnityEngine;
public class EffectInstance
{
    public StatusEffectBase Effect;

    public EnemyController Target;

    public EnemyStats Stats;
    public EnemyPatrollingComponent PatrollingComponent;

    public float RemainingTime;

    public bool Finished;

    public EffectInstance(StatusEffectBase effect, EnemyController target)
    {
        Effect = effect;
        Target = target;

        Stats = target.GetComponent<EnemyStats>();
        PatrollingComponent = target.GetComponent<EnemyPatrollingComponent>();

        RemainingTime = effect.duration;
    }

    public void Update(float deltaTime)
    {
        Effect.OnTick(this, deltaTime);

        RemainingTime -= deltaTime;

        if (RemainingTime <= 0)
            Finished = true;
    }
}