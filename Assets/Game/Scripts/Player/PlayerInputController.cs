using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputController : MonoBehaviour, Actions_MainInputClass.IPlayerActions
{
Actions_MainInputClass _mainInputClass;
    public static PlayerInputController Instance;

    public Vector2 MoveInput { get; private set; }
    public Vector2 LookInput { get; private set; }

    public bool OnInteracted { get; private set; }

    private bool _isActive = true;

    private void Awake()
    {
        Instance = this;
    }

    public void OnAttack(InputAction.CallbackContext context)
    {

    }

    public void OnCrouch(InputAction.CallbackContext context)
    {
    }

    public void OnInteract(InputAction.CallbackContext context)
    {
        OnInteracted = true;
    }

    public void OnJump(InputAction.CallbackContext context)
    {
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        if (!_isActive) return;

        LookInput = context.ReadValue<Vector2>();

    }

    public void OnMove(InputAction.CallbackContext context)
    {
        if (!_isActive) return;
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

    public void OnMouseClick(InputAction.CallbackContext context)
    {
    }


    public void Activate()
    {
        _isActive = true;
    }

    public void Deactivate()
    {
        _isActive = false;
    }   
}
