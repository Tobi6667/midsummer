using System.Collections;
using UnityEngine;

public class EnemyDetectionController : MonoBehaviour
{

    [SerializeField] private EnemyAwarenessComponent _awarenessComponent;
    [SerializeField] private EnemyVisionComponent _visionComponent;
    [SerializeField] private Transform _targetPlayer;
    private float _scanInterval = 0.1f;

    private void OnEnable()
    {
        StartCoroutine(CoScanRoutine());
    }

    private IEnumerator CoScanRoutine()
    {
        var wait = new WaitForSeconds(_scanInterval);
        while (true)
        {
            // Perform detection logic here
            _awarenessComponent.Tick(_visionComponent.CanSeePlayer(_targetPlayer, out Vector3 lastKnownPosition), lastKnownPosition, _scanInterval);
            yield return wait;
        }
    }
}
