using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerMovementController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private PlayerInputController input;
    [SerializeField] private PlayerCameraController cameraController;
    [SerializeField] private PlayerGravityController gravity;
    [SerializeField] private PlayerRotationController rotation;
    [SerializeField] private PlayerGroundDetector ground;

    [Header("Movement")]
    [SerializeField] private float moveSpeed = 6f;
    [SerializeField] private float sprintMultiplier = 1.5f;

    private CharacterController controller;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();

        if (input == null)
            input = GetComponent<PlayerInputController>();

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        ground.Tick();

        if (ground.IsGrounded)
        {
           // gravity.SetUp(ground.SurfaceNormal);
        }

        gravity.Tick(ground.IsGrounded);

        rotation.Tick();

        Move();
    }

    private void Move()
    {
       Vector3 forward = Vector3.ProjectOnPlane(
    cameraController.Forward,
    gravity.Up
).normalized;


Vector3 right = Vector3.ProjectOnPlane(
    cameraController.Right,
    gravity.Up
).normalized;


Vector3 move =
    forward * input.MoveInput.y +
    right * input.MoveInput.x;

        if (move.sqrMagnitude > 1f)
            move.Normalize();

        float speed = moveSpeed;

     /*   if (input.SprintHeld)
            speed *= sprintMultiplier;
     */
        Vector3 velocity =
            move * speed +
            gravity.Velocity;

        controller.Move(velocity * Time.deltaTime);

     /*   if (input.ConsumeJump())
        {
            gravity.Jump();
        }*/
    }
}