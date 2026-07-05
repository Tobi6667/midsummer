using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class EnemyPatroullingComponent : MonoBehaviour
{

    [SerializeField] private Transform[] _patrolPoints;
    [SerializeField] private float _pointWaitTime = 2f;

    private NavMeshAgent _navAgent;
    private int _currentPatrolIndex = 0;
    private bool _isWaiting = false;
    private bool _isPatroling = false;

    private void Awake()
    {
        _navAgent = GetComponent<NavMeshAgent>();
    }


    internal void Initialize()
    {
        GoToNextPoint();
    }

    private void Update()
    {
        if (!_isPatroling) return;
        Patrol();
    }

    internal void StartPatrolling()
    {
        _isPatroling = true;
        _navAgent.isStopped = false;
        
    }

    internal void StopPatroling()
    {
        _isPatroling = false;
        _navAgent.isStopped = true;
    }


    private void Patrol()
    {
        if (_isWaiting) return;

        if(!_navAgent.pathPending && _navAgent.remainingDistance <= _navAgent.stoppingDistance)
        {
             StartCoroutine(CoWaitAtPoint());
        }
    }


    private IEnumerator CoWaitAtPoint()
    {
        Debug.Log("WAIT");
        _isWaiting = true;
        _navAgent.isStopped = true;
        yield return new WaitForSeconds(_pointWaitTime);

        _isWaiting = false;
        _navAgent.isStopped = false;
        GoToNextPoint();


    }

    private void GoToNextPoint()
    {
        _navAgent.SetDestination(_patrolPoints[_currentPatrolIndex].position);
        _currentPatrolIndex = (_currentPatrolIndex + 1) % _patrolPoints.Length;
    }
}
