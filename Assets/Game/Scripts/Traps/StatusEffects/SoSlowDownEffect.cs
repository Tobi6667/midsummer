using UnityEngine;

[CreateAssetMenu(menuName = "Effects/Slow Effect")]
public class SoSlowDownEffect : StatusEffectBase
{
    public float multiplier = 0.5f;
    public override void OnApply(EffectInstance instance)
    {
        Debug.Log("blaaa");
        instance.Stats.MoveSpeed.AddMultiplier(multiplier);
    }


}
