using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class EnemyStatsModifiers
{
    public float BaseValue;

    private readonly List<float> multipliers = new();

    public float Value
    {
        get
        {
            float result = BaseValue;

            foreach (var m in multipliers)
                result *= m;

            return result;
        }
    }

    public void AddMultiplier(float m) => multipliers.Add(m);
    public void RemoveMultiplier(float m) => multipliers.Remove(m);
}
