using UnityEngine;

public abstract class EnemyBase : MonoBehaviour
{
    private EnemyEffectController _effectController;


    private void Awake()
    {
        _effectController = GetComponent<EnemyEffectController>();
    }


    public virtual void ApplyTrapEffect(StatusEffectBase effect)
    {
        if (_effectController == null)
            _effectController = GetComponent<EnemyEffectController>();

        if (_effectController == null)
        {
            Debug.LogWarning($"{name}: missing EnemyEffectController, can't apply {effect}", this);
            return;
        }

        _effectController.AddEffect(effect);
    }
}
