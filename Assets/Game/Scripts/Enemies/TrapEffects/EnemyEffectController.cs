using System.Collections.Generic;
using UnityEngine;

public class EnemyEffectController : MonoBehaviour
{

    private List<EffectInstance> _activeEffects = new();
    
    public void AddEffect(StatusEffectBase effect)
    {
        var instance = new EffectInstance(effect, GetComponent<EnemyController>());
        _activeEffects.Add(instance);
        Debug.Log($"Added effect: {effect.effectName} to {gameObject.name}");
        instance.Effect.OnApply(instance);

    }

    private void Update()
    {
        for (int i = _activeEffects.Count - 1; i >= 0; i--)
        {
            var effect = _activeEffects[i];

            effect.Update(Time.deltaTime);

            if (effect.Finished)
            {
                effect.Effect.OnRemove(effect);
                _activeEffects.RemoveAt(i);
            }
        }
    }
}
