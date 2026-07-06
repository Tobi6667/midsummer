using System;
using System.Collections.Generic;
using UnityEngine;

public abstract class TrapItemBase : MonoBehaviour
{
    [SerializeField] protected ParticleSystem particles;
    [SerializeField] protected Transform trapPosition;
    [SerializeField] protected List<StatusEffectBase> statusEffects;


    public bool IsPlaced { get; protected set; }
    public bool IsArmed { get; protected set; }


    public virtual void TriggerTrap(EnemyController enemy, Action<bool> onFinished)
    {
        foreach (var effect in statusEffects)
        {
            enemy.ApplyTrapEffect(effect);
        }
    }

    public virtual void PlaceTrap()
    {
        IsPlaced = true;
        IsArmed = true;
    }

    public virtual void RemoveTrap()
    {
        IsPlaced = false;
        IsArmed = false;
    }

}