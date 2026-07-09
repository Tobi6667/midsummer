using UnityEngine;
using UnityEngine.AI;

public class PatrolState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    public void Enter()
    {
        _enemyController.GetComponent<NavMeshAgent>().isStopped = false;
        
    }

    public void Exit()
    {
        throw new System.NotImplementedException();
    }

    public void Tick(float dt)
    {
        throw new System.NotImplementedException();
    }

}
