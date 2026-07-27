using UnityEngine;
using UnityEngine.AI;

public class EnemyChasingComponent : MonoBehaviour
{
    private NavMeshAgent _navAgent;
    private bool _isChasing = false;

    private void Awake()
    {
        _navAgent = GetComponent<NavMeshAgent>();
    }

    internal void StartChasing(Vector3 targetPosition)
    {
        _isChasing = true;
        _navAgent.isStopped = false;
        _navAgent.SetDestination(targetPosition);
    }

    internal void StopChasing()
    {
        Debug.Log("Stop Chase");
        _isChasing = false;
        _navAgent.isStopped = true;
    }

    internal void UpdateTarget(Vector3 targetPosition)
    {
        if (!_isChasing) return;
        _navAgent.SetDestination(targetPosition);
    }

    internal void SetSpeed(float speed)
    {
        _navAgent.speed = speed;
    }
}