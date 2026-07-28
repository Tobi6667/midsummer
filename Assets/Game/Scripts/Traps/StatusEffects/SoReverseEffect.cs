using UnityEngine;

[CreateAssetMenu(menuName = "Effects/Reverse Effect")]
public class SoReverseEffect : StatusEffectBase
{

    public override void OnApply(EffectInstance instance)
    {
        instance.PatrollingComponent.GoToLastPoint();
    }
}
