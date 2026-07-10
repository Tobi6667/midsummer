using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private PlayerInputController _inputController;
    private PlayerMovementController _movementController;
    // Start is called once before the first execution of Update after the MonoBehaviour is created

    public PlayerInputController InputController => _inputController;

    private void Awake()
    {
        _movementController = GetComponent<PlayerMovementController>();
        _inputController = GetComponent<PlayerInputController>();
    }


    internal void StopMovement()
    {
        _movementController.StopMovement();
    }
}
