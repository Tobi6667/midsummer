using UnityEngine;

public class PlayerGroundDetector : MonoBehaviour
{
    [SerializeField] private CharacterController controller;
    [SerializeField] private PlayerGravityController gravity;

    [SerializeField] private float checkDistance = 0.4f;
    [SerializeField] private float sphereRadius = 0.3f;

    public bool IsGrounded { get; private set; }
    public RaycastHit GroundHit { get; private set; }

    public void Tick()
    {
        //Debug.Log("Checking for ground...");
        IsGrounded = Physics.SphereCast(
            transform.position,
            sphereRadius,
            -gravity.Up,
            out RaycastHit hit,
            checkDistance
        );

        Debug.DrawRay(
            transform.position,
            -gravity.Up * checkDistance,
            Color.red
        );

        if (IsGrounded)
        {
           // Debug.Log("Ground detected: " + hit.normal);

            GroundHit = hit;
            gravity.SetUp(hit.normal);
        }
    }
}