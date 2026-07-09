using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputController : MonoBehaviour, Actions_MainInputClass.IPlayerActions
{
Actions_MainInputClass _mainInputClass;

    public Vector2 MoveInput { get; private set; }
    public Vector2 LookInput { get; private set; }

    public void OnAttack(InputAction.CallbackContext context)
    {

    }

    public void OnCrouch(InputAction.CallbackContext context)
    {
    }

    public void OnInteract(InputAction.CallbackContext context)
    {
    }

    public void OnJump(InputAction.CallbackContext context)
    {
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        LookInput = context.ReadValue<Vector2>();

    }

    public void OnMove(InputAction.CallbackContext context)
    {
        MoveInput = context.ReadValue<Vector2>();
    }

    public void OnNext(InputAction.CallbackContext context)
    {
    }

    public void OnPrevious(InputAction.CallbackContext context)
    {
    }

    public void OnSprint(InputAction.CallbackContext context)
    {
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void OnEnable()
    {
        if (_mainInputClass == null)
        {
            _mainInputClass  = new Actions_MainInputClass();
            _mainInputClass.Player.SetCallbacks(this);
        }
        _mainInputClass.Player.Enable();
    }

    void OnDisable()
    {
        _mainInputClass.Player.Disable();
        _mainInputClass?.Dispose();
    }

}
