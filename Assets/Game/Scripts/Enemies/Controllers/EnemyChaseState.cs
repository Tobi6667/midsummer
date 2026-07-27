using UnityEngine;

public class EnemyChaseState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly EnemyAwarenessComponent _enemyAwarenessComponent;
    private readonly EnemyChasingComponent _chasing;
    private PlayerController _playerController;
    private readonly EnemyAttackComponent _attackComponent;

    public EnemyChaseState(EnemyController enemy)
    {
        _enemyController = enemy;
        _enemyAwarenessComponent = enemy.GetComponent<EnemyAwarenessComponent>();
        _chasing = enemy.GetComponent<EnemyChasingComponent>();
        _attackComponent = enemy.GetComponent<EnemyAttackComponent>();
    }

    public void Enter()
    {
        Debug.Log("chase state");
        _playerController = GameManager.Instance.PlayerController;
    _chasing.StartChasing(_enemyAwarenessComponent._lastKnownPosition);
    }

    public void Exit()
    {
        _chasing.StopChasing();
    }

    public void Tick(float dt)
    {
        PlayerController.Instance.UpdateStats(dt);

        if (_enemyAwarenessComponent.CurrentState == EnemyAwarenessComponent.AwarenessState.Idle)
        {
            _enemyController.ChangeState(new PatrolState(_enemyController));
            return;
        }

        if (_attackComponent.IsInRange(_playerController.transform))
        {
            _enemyController.ChangeState(new EnemyAttackState(_enemyController));
            return;
        }

        _chasing.UpdateTarget(_enemyAwarenessComponent._lastKnownPosition);
    }
}