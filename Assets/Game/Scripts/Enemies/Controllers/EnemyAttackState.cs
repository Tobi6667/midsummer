using UnityEngine;

public class EnemyAttackState : INPCStateBehavior
{
    private readonly EnemyController _enemyController;
    private readonly EnemyAwarenessComponent _enemyAwarenessComponent;
    private readonly EnemyAttackComponent _attackComponent;
    private PlayerController _playerController;

    public EnemyAttackState(EnemyController enemy)
    {
        _enemyController = enemy;
        _enemyAwarenessComponent = enemy.GetComponent<EnemyAwarenessComponent>();
        _attackComponent = enemy.GetComponent<EnemyAttackComponent>();
    }

    public void Enter()
    {
        Debug.Log("attack state");
        _playerController = GameManager.Instance.PlayerController;
        _attackComponent.StartAttacking(_playerController.transform); // assumed accessor — adjust if named differently
    }

    public void Exit()
    {
        _attackComponent.StopAttacking();
    }

    public void Tick(float dt)
    {
        if (_enemyAwarenessComponent.CurrentState == EnemyAwarenessComponent.AwarenessState.Idle)
        {
            Debug.Log("goes to idle");
            _enemyController.ChangeState(new PatrolState(_enemyController));
            return;
        }

        if (!_attackComponent.IsInRange(_playerController.transform))
        {
            Debug.Log("goes out of range");
            _enemyController.ChangeState(new ChaseState(_enemyController));
            return;
        }

        _attackComponent.Tick(dt);
    }
}