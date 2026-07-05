using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(CharacterController))]
public class PlayerMovementController : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 5f;
    public float sprintMultiplier = 1.6f;
    public float gravity = -9.81f;
    public float jumpHeight = 1.2f;

    [Header("Look")]
    public Transform cameraPivot;
    public float mouseSensitivity = 0.1f;
    public float minPitch = -40f;
    public float maxPitch = 75f;

    [Header("References")]
    public PlayerController input; // drag the same GameObject's PlayerController here, or GetComponent in Awake

    CharacterController controller;
    Vector3 velocity;
    float pitch;
    bool isSprinting;
    bool isCrouching;

    void Awake()
    {
        controller = GetComponent<CharacterController>();
        if (input == null) input = GetComponent<PlayerController>();
    }

    void OnEnable()
    {
      /*  input.OnJumpPressed += HandleJump;
        input.OnSprintChanged += HandleSprintChanged;
        input.OnCrouchChanged += HandleCrouchChanged;
      */
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void OnDisable()
    {
      /*  input.OnJumpPressed -= HandleJump;
        input.OnSprintChanged -= HandleSprintChanged;
        input.OnCrouchChanged -= HandleCrouchChanged;
      */
    }

    void Update()
    {
        Look();
        Move();
    }

    void Look()
    {
        float yaw = input.LookInput.x * mouseSensitivity;
        pitch -= input.LookInput.y * mouseSensitivity;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);

        transform.Rotate(Vector3.up * yaw);
        if (cameraPivot != null)
            cameraPivot.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    void Move()
    {
        Vector3 move = transform.right * input.MoveInput.x + transform.forward * input.MoveInput.y;
        float speed = moveSpeed * (isSprinting ? sprintMultiplier : 1f);
        move *= speed;

        if (controller.isGrounded && velocity.y < 0) velocity.y = -2f;
        velocity.y += gravity * Time.deltaTime;

        controller.Move((move + velocity) * Time.deltaTime);
    }

    void HandleJump()
    {
        if (controller.isGrounded)
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
    }

    void HandleSprintChanged(bool sprinting) => isSprinting = sprinting;
    void HandleCrouchChanged(bool crouching) => isCrouching = crouching; // hook up controller.height/center change if you want actual crouch
}