using UnityEngine;

public class EnemyAttackComponent : MonoBehaviour
{
    [SerializeField] private float _attackRange = 2f;
    [SerializeField] private float _attackCooldown = 1.5f;
    private AnimationActionComponent _animationActionComponent;
    [SerializeField] private AnimationClip _attackClip;

    private Transform _target;
    private float _cooldownRemaining;


    private void Start()
    {
        _animationActionComponent = GetComponent<AnimationActionComponent>();
    }

    internal void StartAttacking(Transform target)
    {
        _target = target;
        _cooldownRemaining = 0f;
        _animationActionComponent.TriggerAttack(_attackClip);
    }

    internal void StopAttacking()
    {
        _target = null;
    }

    internal bool IsInRange(Transform target)
    {
        if (target == null) return false;
        return Vector3.Distance(transform.position, target.position) <= _attackRange;
    }

    internal void Tick(float dt)
    {

        PlayerController.Instance.UpdateStats(1f);
        if (_target == null) return;

        _cooldownRemaining -= dt;
        if (_cooldownRemaining > 0f) return;

        // TODO: hook up actual attack effect (damage, game-over, animation trigger, etc.)
        // — deliberately not wired to PlayerController.Instance.UpdateStats here,
        // that call in ChaseState looked like a separate "being chased" mechanic.
        Debug.Log("Enemy attacks player!");

        _cooldownRemaining = _attackCooldown;
        StartAttacking(PlayerController.Instance.transform);
    }
}