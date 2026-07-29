using UnityEngine;

public class ConstantRotation : MonoBehaviour
{
    [Header("Rotation")]
    [SerializeField] private Vector3 rotationAxis = Vector3.forward;

    [SerializeField, Min(0f)]
    private float rotationSpeed = 60f;

    private void Update()
    {
        transform.Rotate(
            rotationAxis.normalized,
            rotationSpeed * Time.deltaTime,
            Space.Self
        );
    }
}