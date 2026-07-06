using UnityEngine;

public class EnemyAwarenessComponent : MonoBehaviour
{

    public enum AwarenessState
    {
        Idle,
        Alerted,
        Suspicious,
        Attacking
    }
    public AwarenessState CurrentState { get; private set; }
    [SerializeField] private float _gainRate = 1f;
    [SerializeField] private float _decayRate = 0.5f;
    [SerializeField] private float _suspicionThreshold = 0.5f;
    [SerializeField] private float _alertThreshold = 1f;
    private float _awarenessLevel = 0f;
    public Vector3 _lastKnownPosition { get; private set; }


    internal void Tick(bool targetVisible, Vector3 targetPos, float dt)
    {
        if (targetVisible)
        {
            _awarenessLevel += _gainRate * dt;
            _lastKnownPosition = targetPos;
        }
        else
        {
            _awarenessLevel -= _decayRate * dt;
        }

        _awarenessLevel = Mathf.Clamp01(_awarenessLevel);

        // Update the awareness state based on the awareness level
        if (_awarenessLevel >= _alertThreshold)
        {
            CurrentState = AwarenessState.Alerted;
        }
        else if (_awarenessLevel >= _suspicionThreshold)
        {
            CurrentState = AwarenessState.Suspicious;
        }
        else
        {
            CurrentState = AwarenessState.Idle;
        }
        //Debug.Log(CurrentState);
    }
}
