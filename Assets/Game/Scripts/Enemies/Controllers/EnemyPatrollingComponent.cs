using System;
using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class EnemyPatrollingComponent : MonoBehaviour
{
    [SerializeField] private Transform[] _patrolPoints;
    [SerializeField] private float _pointWaitTime = 2f;

    public event Action<Transform> OnWaypointReached;
    private AnimationActionComponent _AnimAction;
    private int _patrolDirection = 1; // 1 = forward, -1 = backward
    private EnemyStats _enemyStats;
    private NavMeshAgent _navAgent;
    private int _currentPatrolIndex = 0;
    private bool _isWaiting = false;
    private bool _isPatroling = false;
    private Coroutine _waitRoutine;

    [SerializeField] private float _turnSpeed = 720f; // degrees/sec

    private Coroutine _turnRoutine;

    private void Awake()
    {
        _navAgent = GetComponent<NavMeshAgent>();
        _enemyStats = GetComponent<EnemyStats>();
        _AnimAction = GetComponent<AnimationActionComponent>();
    }

    internal void Initialize()
    {
        // don't move yet — StartPatrolling() will kick it off via Enter()
    }

    public void Tick(float dt)
    {
        if (!_isPatroling)
            return;

       // _navAgent.speed = _enemyStats.MoveSpeed.Value;
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
        Debug.Log("stop patrol");
        _isPatroling = false;
        _navAgent.isStopped = true;

        if (_waitRoutine != null)
        {
            StopCoroutine(_waitRoutine);
            _waitRoutine = null;
        }
        if (_turnRoutine != null)
        {
            StopCoroutine(_turnRoutine);
            _turnRoutine = null;
            _navAgent.updateRotation = true;
        }
        _isWaiting = false;
    }

    private void Patrol()
    {
        if (_isWaiting) return;

        if (!_navAgent.pathPending && _navAgent.remainingDistance <= _navAgent.stoppingDistance)
        {
            Transform reached = _patrolPoints[ReachedIndex()];
            OnWaypointReached?.Invoke(reached);
            _AnimAction.SetWalking(false);
            // if it's an animation waypoint, PatrolState takes over (froze us via StopPatroling
            // by the time this returns) — don't start the normal timed wait on top of that
            if (!_isPatroling || reached.GetComponent<InteractionPoint>() != null)
                return;

            _waitRoutine = StartCoroutine(CoWaitAtPoint());
        }
    }

    private int ReachedIndex()
    {
        return (_currentPatrolIndex - 1 + _patrolPoints.Length) % _patrolPoints.Length;
    }

    internal void GoToLastPoint()
    {
        if (_turnRoutine != null)
            StopCoroutine(_turnRoutine);

        if (_waitRoutine != null)
        {
            StopCoroutine(_waitRoutine);
            _waitRoutine = null;
        }

        _turnRoutine = StartCoroutine(CoTurnBack());
    }
    private IEnumerator CoTurnBack()
    {
        _isWaiting = true;

        _navAgent.isStopped = true;
        _navAgent.updateRotation = false;
        _AnimAction.SetWalking(false);

        // This is the waypoint we came from.
        int previousIndex =
            (_currentPatrolIndex - 2 + _patrolPoints.Length) % _patrolPoints.Length;

        Vector3 dir = _patrolPoints[previousIndex].position - transform.position;
        dir.y = 0f;

        if (dir.sqrMagnitude > 0.001f)
        {
            Quaternion targetRotation = Quaternion.LookRotation(dir);

            while (Quaternion.Angle(transform.rotation, targetRotation) > 1f)
            {
                transform.rotation = Quaternion.RotateTowards(
                    transform.rotation,
                    targetRotation,
                    _turnSpeed * Time.deltaTime);

                yield return null;
            }

            transform.rotation = targetRotation;
        }

        _navAgent.updateRotation = true;
        _navAgent.isStopped = false;

        // Walk back.
        _AnimAction.SetWalking(true);
        _navAgent.SetDestination(_patrolPoints[previousIndex].position);

        // Continue patrolling from there in the opposite direction.
        _patrolDirection *= -1;
        _currentPatrolIndex = previousIndex;

        _currentPatrolIndex =
            (_currentPatrolIndex + _patrolDirection + _patrolPoints.Length)
            % _patrolPoints.Length;

        _isWaiting = false;
        _turnRoutine = null;
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
        _AnimAction.SetWalking(true);

        _navAgent.SetDestination(_patrolPoints[_currentPatrolIndex].position);

        _currentPatrolIndex =
            (_currentPatrolIndex + _patrolDirection + _patrolPoints.Length)
            % _patrolPoints.Length;
    }



    internal void SetSpeed(float speed)
    {
        _navAgent.speed = speed;
    }
}