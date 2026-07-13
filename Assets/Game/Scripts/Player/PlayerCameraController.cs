using UnityEngine;

public class PlayerCameraController : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private PlayerInputController input;

    [SerializeField] private float sensitivity = 0.15f;
    private bool _isActive = true;

    private float pitch;

    void Update()
    {
        if (!_isActive) return;
        Look();
    }

    internal void SetActiveMove(bool act)
    {
        _isActive = act;
    }


    void Look()
    {
        Vector2 look = input.LookInput * sensitivity;

        // Yaw (rotate player around its current Up)
        player.Rotate(player.up, look.x, Space.World);

        // Pitch
        pitch -= look.y;
        pitch = Mathf.Clamp(pitch, -80f, 80f);

        transform.localRotation = Quaternion.Euler(pitch, 0f, 0f);
    }

    public Vector3 Forward => transform.forward;

    public Vector3 Right => transform.right;
}