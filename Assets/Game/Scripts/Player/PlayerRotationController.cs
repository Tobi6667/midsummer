using UnityEngine;

public class PlayerRotationController : MonoBehaviour
{
    [SerializeField] private PlayerGravityController gravity;
    [SerializeField] private float rotationSpeed = 10f;

    public void Tick()
    {
        Quaternion targetRotation =
            Quaternion.FromToRotation(
                transform.up,
                gravity.Up) * transform.rotation;

        transform.rotation = Quaternion.Slerp(
            transform.rotation,
            targetRotation,
            rotationSpeed * Time.deltaTime);
    }
}