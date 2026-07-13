using System.Collections.Generic;
using UnityEngine;

// Rigidbody (kinematic) + CapsuleCollider instead of CharacterController.
// Unlike CharacterController, a CapsuleCollider's shape genuinely rotates
// with the transform, so this can actually tilt onto walls/ceilings without
// the capsule staying pinned to world/local-Y. Trade-off: we lose Unity's
// built-in slide-along-collisions behavior, so this implements a small
// manual collide-and-slide via CapsuleCast instead.
[RequireComponent(typeof(Rigidbody), typeof(CapsuleCollider))]
public class PlayerGravityReceiver : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 5f;
    public float sprintMultiplier = 1.6f;
    public float gravity = 25f;
    public float jumpHeight = 5f;


    private bool isActive = true;

    [Header("Look")]
    public Transform cameraPivot;
    public float mouseSensitivity = 3f;
    public float minPitch = -80f;
    public float maxPitch = 80f;

    [Header("Collision")]
    public LayerMask collisionMask;
    [Tooltip("Extra skin distance so the resolved position doesn't land exactly touching geometry.")]
    public float skinWidth = 0.02f;
    [Tooltip("Max collide-and-slide passes per physics step. 2-3 is usually enough for corners.")]
    public int maxSlideIterations = 3;

    [Header("References")]
    public PlayerInputController input;

    private Rigidbody rb;
    private CapsuleCollider capsule;

    private Vector3 currentUp = Vector3.up;
    private float verticalSpeed;
    private float pitch;
    private bool isSprinting;
    private bool isGrounded;

    // Input cached in Update, consumed in FixedUpdate.
    private Vector2 moveInput;
    private float pendingYaw;
    private bool jumpQueued;

    private readonly List<GravityZone> activeZones = new List<GravityZone>();

    private bool isTransitioning;
    private Quaternion transitionStartRot;
    private Quaternion transitionTargetRot;
    private float transitionElapsed;
    private float transitionDuration;


    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        capsule = GetComponent<CapsuleCollider>();

        // Kinematic: we move it ourselves via MovePosition/MoveRotation,
        // Unity's physics engine won't apply forces/gravity to it and
        // won't auto-resolve collisions for us — that's why we do our
        // own CapsuleCast sweep below.
        rb.isKinematic = true;
        rb.useGravity = false;
        rb.interpolation = RigidbodyInterpolation.Interpolate;

        if (input == null)
            input = GetComponent<PlayerInputController>();

        currentUp = transform.up;

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }


    void Update()
    {

        if (!isActive) return;

        if (input == null)
            return;

        moveInput = input.MoveInput;

        pitch -= input.LookInput.y * mouseSensitivity;
        pitch = Mathf.Clamp(pitch, minPitch, maxPitch);
        if (cameraPivot != null)
            cameraPivot.localRotation = Quaternion.Euler(pitch, 0, 0);

        //pendingYaw += input.LookInput.x * mouseSensitivity;

      //  if (input.JumpPressed) // rename to match your actual PlayerController field
        //    jumpQueued = true;
    }


    void FixedUpdate()
    {
        if (!isActive) return;
        UpdateTransition();
        ApplyYaw();
        UpdateGrounded();
        ApplyMove();
    }



    public void SetActiveMove(bool act)
    {
        isActive = act;
    }

    // ---- Gravity zones ----

    public void EnterZone(GravityZone zone)
    {
        activeZones.Remove(zone);
        activeZones.Add(zone);
        BeginTransitionTo(zone.Up, zone.transitionDuration);
    }

    public void ExitZone(GravityZone zone)
    {
       // activeZones.Remove(zone);

       // Vector3 targetUp = activeZones.Count > 0 ? activeZones[activeZones.Count - 1].Up : Vector3.up;
      //  float duration = activeZones.Count > 0 ? activeZones[activeZones.Count - 1].transitionDuration : 0.4f;

       // BeginTransitionTo(targetUp, duration);
    }

    void BeginTransitionTo(Vector3 targetUp, float duration)
    {
        if (Vector3.Dot(targetUp, currentUp) > 0.9999f)
            return;

        Vector3 forward = Vector3.ProjectOnPlane(transform.forward, targetUp);
        if (forward.sqrMagnitude < 0.001f)
            forward = Vector3.ProjectOnPlane(transform.up, targetUp);
        forward.Normalize();

        transitionStartRot = rb.rotation;
        transitionTargetRot = Quaternion.LookRotation(forward, targetUp);
        transitionElapsed = 0f;
        transitionDuration = Mathf.Max(duration, 0.0001f);
        isTransitioning = true;

        // Drop momentum from the old "down" across a gravity flip.
        verticalSpeed = 0f;
    }

    void UpdateTransition()
    {
        if (!isTransitioning) return;

        transitionElapsed += Time.fixedDeltaTime;
        float t = Mathf.Clamp01(transitionElapsed / transitionDuration);

        Quaternion rot = Quaternion.Slerp(transitionStartRot, transitionTargetRot, t);
        rb.MoveRotation(rot);
        currentUp = rot * Vector3.up;

        if (t >= 1f)
            isTransitioning = false;
    }


    // ---- Yaw (only applied when not mid gravity-transition) ----

    void ApplyYaw()
    {
        if (isTransitioning)
        {
            pendingYaw = 0f;
            return;
        }

        if (Mathf.Abs(pendingYaw) > 0f)
        {
            Quaternion yawRot = Quaternion.AngleAxis(pendingYaw, currentUp);
            rb.MoveRotation(yawRot * rb.rotation);
            pendingYaw = 0f;
        }
    }


    // ---- Ground check (separate from movement collision) ----

    void UpdateGrounded()
    {
        Vector3 center = rb.position + currentUp * (capsule.height * 0.5f - capsule.radius);

        isGrounded = Physics.SphereCast(
            center,
            capsule.radius * 0.9f,
            -currentUp,
            out _,
            capsule.height * 0.5f + 0.15f,
            collisionMask);
    }


    // ---- Movement + manual collide-and-slide ----

    void ApplyMove()
    {
        Vector3 forward = cameraPivot != null
            ? Vector3.ProjectOnPlane(cameraPivot.forward, currentUp).normalized
            : Vector3.ProjectOnPlane(transform.forward, currentUp).normalized;

        Vector3 right = Vector3.Cross(currentUp, forward);

        Vector3 planarMove = forward * moveInput.y + right * moveInput.x;
        float speed = moveSpeed * (isSprinting ? sprintMultiplier : 1f);

        if (isGrounded)
        {
            if (verticalSpeed <= 0f)
                verticalSpeed = 0f;

            if (jumpQueued)
                verticalSpeed = Mathf.Sqrt(2f * gravity * jumpHeight);
        }
        else
        {
            verticalSpeed -= gravity * Time.fixedDeltaTime;
        }

        jumpQueued = false;

        Vector3 wishDelta = (planarMove * speed + currentUp * verticalSpeed) * Time.fixedDeltaTime;

        Vector3 resolvedPos = SlideMove(rb.position, wishDelta);
        rb.MovePosition(resolvedPos);
    }

    Vector3 SlideMove(Vector3 startPos, Vector3 delta)
    {
        Vector3 pos = startPos;
        Vector3 remaining = delta;

        float halfHeight = capsule.height * 0.5f - capsule.radius;
        float castRadius = capsule.radius * 0.98f; // small skin to avoid false positives from touching contacts

        for (int i = 0; i < maxSlideIterations; i++)
        {
            float dist = remaining.magnitude;
            if (dist < 0.0001f)
                break;

            Vector3 dir = remaining / dist;
            Vector3 p1 = pos + currentUp * halfHeight;
            Vector3 p2 = pos - currentUp * halfHeight;

            if (Physics.CapsuleCast(p1, p2, castRadius, dir, out RaycastHit hit, dist + skinWidth, collisionMask))
            {
                float travel = Mathf.Max(hit.distance - skinWidth, 0f);
                pos += dir * travel;

                Vector3 leftoverDelta = dir * (dist - travel);
                remaining = Vector3.ProjectOnPlane(leftoverDelta, hit.normal);
            }
            else
            {
                pos += remaining;
                remaining = Vector3.zero;
                break;
            }
        }

        return pos;
    }


    public void SetSprint(bool sprint)
    {
        isSprinting = sprint;
    }
}