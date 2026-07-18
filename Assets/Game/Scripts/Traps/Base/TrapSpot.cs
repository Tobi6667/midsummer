using System;
using UnityEngine;

public class TrapSpot : MonoBehaviour, ITrapPlace
{
   [SerializeField] private TrapItemBase currentTrap;
   
    public void PlaceTrap(TrapItemBase trap)
    {
        currentTrap = trap;

        trap.transform.position = transform.position;
        trap.PlaceTrap();
    }

    public void RemoveTrap()
    {
        if (currentTrap == null)
            return;

        currentTrap.RemoveTrap();
        currentTrap = null;
    }

    public void TriggerTrap(EnemyController enemy, Action<bool> onFinished)
    {
        if (currentTrap != null)
        {
            currentTrap.TriggerTrap(enemy, onFinished);
            currentTrap = null;
        }
        else
        {
            onFinished?.Invoke(false);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        // Assuming you have a way to get the EnemyController from the collider
        EnemyController enemy = other.GetComponent<EnemyController>();
        if (enemy != null)
        {
            Debug.Log("Trigger Trap");
           TriggerTrap(enemy, (hasTrap) => { });
        }
    }

    

}
