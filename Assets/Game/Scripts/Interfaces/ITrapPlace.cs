using System;
using UnityEngine;

public interface ITrapPlace
{
    public void PlaceTrap(TrapItemBase trap);
    public void RemoveTrap();

    public void TriggerTrap(EnemyController enemy, Action<bool> onFinished);
}
