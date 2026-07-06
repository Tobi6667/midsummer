using UnityEngine;

public abstract class StatusEffectBase : ScriptableObject
{
    public string effectName;
    public float duration;

    public abstract void OnApply(EffectInstance instance);

    public virtual void OnTick(EffectInstance instance, float deltaTime)
    {
        Debug.Log($"Effect {effectName} ticking on {instance.Target.name} for {deltaTime} seconds.");
    }

    public virtual void OnRemove(EffectInstance instance)
    {
    }
}
