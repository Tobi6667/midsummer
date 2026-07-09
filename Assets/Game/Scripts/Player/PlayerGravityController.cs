using UnityEngine;

public class PlayerGravityController : MonoBehaviour
{
    [Header("Gravity")]
    [SerializeField] private float gravity = 25f;
    [SerializeField] private float jumpHeight = 2f;

    public Vector3 Up { get; private set; } = Vector3.up;
    public Vector3 Down => -Up;

    public Vector3 Velocity { get; private set; }


    public void SetUp(Vector3 up)
    {
        Up = up.normalized;
    }


    public void Tick(bool grounded)
    {
        if (!grounded)
        {
            Velocity += Down * gravity * Time.deltaTime;
        }
        else
        {
            RemoveGroundVelocity();
        }
    }


    private void RemoveGroundVelocity()
    {
        float velocityIntoSurface = Vector3.Dot(Velocity, Down);

        if (velocityIntoSurface > 0f)
        {
            Velocity -= Down * velocityIntoSurface;
        }
    }


    public void Jump()
    {
        float jumpSpeed = Mathf.Sqrt(2f * gravity * jumpHeight);

        Velocity = Up * jumpSpeed;
    }
}