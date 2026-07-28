using UnityEngine;

[CreateAssetMenu(menuName = "Effects/Trap Effect")]
public class TrapEffect : StatusEffectBase
{
   public override void OnApply(EffectInstance instance)
    {
      //  instance.Target.ChangeState(new EnemyInTrapState(instance.Target,));
    }

    public override void OnRemove(EffectInstance instance)
    {
     //   instance.Target.ChangeState(new PatrolState(instance.Target));
    }
}