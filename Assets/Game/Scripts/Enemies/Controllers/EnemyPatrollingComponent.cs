using System.Collections;
using UnityEngine;
using UnityEngine.AI;
public class EnemyPatrollingComponent : MonoBehaviour
{
    [SerializeField] private Transform[] _patrolPoints;
    [SerializeField] private float _pointWaitTime = 2f;

    private EnemyStats _enemyStats;
    private NavMeshAgent _navAgent;
    private int _currentPatrolIndex = 0;
    private bool _isWaiting = false;
    private bool _isPatroling = false;
    private Coroutine _waitRoutine;

    private void Awake()
    {
        _navAgent = GetComponent<NavMeshAgent>();
        _enemyStats = GetComponent<EnemyStats>();
    }

    internal void Initialize()
    {
        // don't move yet — StartPatrolling() will kick it off via Enter()
    }

    public void Tick(float dt)
    {
        if (!_isPatroling)
            return;

        _navAgent.speed = _enemyStats.MoveSpeed.Value;
        Patrol();
    }

    internal void StartPatrolling()
    {
        if (_isPatroling) return;
        _isPatroling = true;
        _navAgent.isStopped = false;

        // resume: if agent has no destination yet (first entry), pick one
        if (!_isWaiting && _navAgent.remainingDistance <= 0f)
            GoToNextPoint();
    }

    internal void StopPatroling()
    {
        _isPatroling = false;
        _navAgent.isStopped = true;

        if (_waitRoutine != null)
        {
            StopCoroutine(_waitRoutine);
            _waitRoutine = null;
        }
        _isWaiting = false;
    }

    private void Patrol()
    {
        if (_isWaiting) return;

        if (!_navAgent.pathPending && _navAgent.remainingDistance <= _navAgent.stoppingDistance)
        {
            _waitRoutine = StartCoroutine(CoWaitAtPoint());
        }
    }

    private IEnumerator CoWaitAtPoint()
    {
        _isWaiting = true;
        _navAgent.isStopped = true;
        yield return new WaitForSeconds(_pointWaitTime);

        _isWaiting = false;
        _navAgent.isStopped = false;
        GoToNextPoint();
        _waitRoutine = null;
    }

    private void GoToNextPoint()
    {
        _navAgent.SetDestination(_patrolPoints[_currentPatrolIndex].position);
        _currentPatrolIndex = (_currentPatrolIndex + 1) % _patrolPoints.Length;
    }

    internal void SetSpeed(float speed)
    {
        _navAgent.speed = speed;
    }
}

