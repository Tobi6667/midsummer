using System.Collections;
using UnityEngine;

public class EnemyVisionComponent : MonoBehaviour
{

    [SerializeField] private float _visionRange = 10f;
    [SerializeField] private float _fieldOfView = 60f;
    [SerializeField] private Transform _eyePoint;
    [SerializeField] private LayerMask _playerLayer;
    [SerializeField] private LayerMask _obstacleLayer;

    //bool _playerInRange, _playerInSight, _playerNotHidden;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    internal bool CanSeePlayer(Transform player, out Vector3 lastKnownPosition)
    {
        Debug.Log($"[{name}] Scanning for player...");

        lastKnownPosition = default;

        Vector3 eyePosition = _eyePoint.position;
        Vector3 directionToPlayer = player.position - eyePosition;
        float dist = directionToPlayer.magnitude;

        Debug.Log($"Distance to player: {dist:F2} / Vision Range: {_visionRange}");

        if (dist > _visionRange)
        {
            Debug.Log("❌ Player is out of vision range.");
            return false;
        }

        directionToPlayer.Normalize();

        float angle = Vector3.Angle(_eyePoint.forward, directionToPlayer);
        Debug.Log($"View Angle: {angle:F2}° / FOV Limit: {_fieldOfView * 0.5f:F2}°");

        if (angle > _fieldOfView * 0.5f)
        {
            Debug.Log("❌ Player is outside field of view.");
            return false;
        }

        Debug.DrawRay(eyePosition, directionToPlayer * dist, Color.yellow, 0.1f);

        if (Physics.Raycast(eyePosition, directionToPlayer, out RaycastHit hit, dist, _obstacleLayer))
        {
            Debug.DrawRay(eyePosition, directionToPlayer * hit.distance, Color.red, 0.5f);
            Debug.Log($"❌ Vision blocked by '{hit.collider.name}' at {hit.distance:F2}m.");
            return false;
        }

        Debug.DrawRay(eyePosition, directionToPlayer * dist, Color.green, 0.5f);

        lastKnownPosition = player.position;
        Debug.Log($"✅ Player spotted at {lastKnownPosition}");

        return true;
    }
}
