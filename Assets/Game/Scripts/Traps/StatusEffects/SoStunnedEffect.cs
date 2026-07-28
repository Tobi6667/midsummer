using UnityEngine;

[CreateAssetMenu(menuName = "Effects/Stun Effect")]
public class SoStunnedEffect : StatusEffectBase
{
    public AnimationClip[] clip;

    public override void OnApply(EffectInstance instance)
    {
        instance.Target.ChangeState(new EnemyInTrapState(instance.Target, clip));
    }
}