using UnityEngine;

public class EnemyController : EnemyBase
{
    private EnemyAwarenessComponent _enemyAwarenessComponent;
    private EnemyPatrollingComponent _enemyPatrollingComponent;

    public override void Initialize()
    {
        throw new System.NotImplementedException();
    }

    public override void StartActing() { }

    private void Awake()
    {
        _enemyAwarenessComponent = GetComponent<EnemyAwarenessComponent>();
        _enemyPatrollingComponent = GetComponent<EnemyPatrollingComponent>();
    }

    private void Start()
    {
        _enemyPatrollingComponent.Initialize();
        ChangeState(new PatrolState(this)); // goes through EnemyBase, calls Enter()
    }

    private void Update()
    {
        TickState(Time.deltaTime); // ticks EnemyBase._currentState
    }
}