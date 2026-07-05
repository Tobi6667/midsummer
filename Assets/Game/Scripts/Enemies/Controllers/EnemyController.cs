using UnityEngine;


public class EnemyController : MonoBehaviour
{
    private EnemyAwarenessComponent _enemyAwarenessComponent;
    private EnemyPatroullingComponent _enemyPatroullingComponent;

    private void Awake()
    {
        _enemyAwarenessComponent = GetComponent<EnemyAwarenessComponent>();
        _enemyPatroullingComponent = GetComponent<EnemyPatroullingComponent>();
    }

    private void Start()
    {
        _enemyPatroullingComponent.Initialize();
        _enemyPatroullingComponent.StartPatrolling();


    }

    private void Update()
    {
        switch (_enemyAwarenessComponent.CurrentState)
        {
            case EnemyAwarenessComponent.AwarenessState.Idle:
                _enemyPatroullingComponent.StartPatrolling();
                break;
            case EnemyAwarenessComponent.AwarenessState.Suspicious:
                _enemyPatroullingComponent.StopPatroling();
                break;
            case EnemyAwarenessComponent.AwarenessState.Alerted:
                _enemyPatroullingComponent.StopPatroling();
                break;
            default:
                _enemyPatroullingComponent.StopPatroling();
                break;
        }
    }

}
