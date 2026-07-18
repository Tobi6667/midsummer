using System;
using UnityEngine;

public class PlayerController : PlayerBase
{
    public static PlayerController Instance;
    private PlayerInputController _inputController;
    private PlayerMovementController _movementController;
    private AnimationActionComponent _actionComponent;
    private PlayerGravityReceiver _gravityReceiver;
    
    



    [SerializeField] private LayerMask _interactMask;
    [SerializeField] private PlayerCameraController _cameraController;

    private bool _isTransitioning = false;
    private bool _isActive = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created

    public PlayerInputController InputController => _inputController;

    private void Awake()
    {
        Instance = this;
        _movementController = GetComponent<PlayerMovementController>();
        _inputController = GetComponent<PlayerInputController>();
        _actionComponent = GetComponent<AnimationActionComponent>();
        _gravityReceiver = GetComponent<PlayerGravityReceiver>();
        DetectionValue = 50;

    }


    private void Start()
    {
        _inputController.OnInteracted += OnInteract;
    }

    private void OnInteract()
    {
        Debug.Log("interacttttt "+_isActive);
        if (!_isActive)
        {
            var hits = Physics.OverlapSphere(transform.position, 2f, _interactMask);

            foreach (var hit in hits)
            {

                if (hit.TryGetComponent<InteractActionBase>(out var interaction) && !_isTransitioning)
                {
                    StopMovement();
                    
                    _movementController.MoveTo(interaction.InteractionPoint, 1f, () =>
                    {
                        if (_isTransitioning) return;
                        Debug.Log("angekommen");
                        _isTransitioning = true;
                        _isActive = true;
                        ActManager.Instance.PlayAct();
                        _actionComponent.PlayAnimations(interaction.TransitionClip, () => {
                            _isTransitioning = false;

                            _movementController.MoveTo(interaction.InteractionPoint, 1f, null);



                            StartMovement();
                        }, interaction.LoopClip);
                    });
                    break;
                }


                if (hit.TryGetComponent<GuardController>(out var interAct) && !_isTransitioning)
                {
                    Debug.Log("wtf guard");
                    StopMovement();
                    interAct.Interact(() =>
                    {
                        StartMovement();
                    });
                    break;
                }

                if (hit.TryGetComponent<ActorController>(out var interActor) && !_isTransitioning)
                {
                    Debug.Log("wtf actor");
                    StopMovement();
                    interActor.Interact(() =>
                    {
                        StartMovement();
                    });
                    break;
                }

                /*if (hit.TryGetComponent<IInteractable>(out var interactable))
                {
                    interactable.Interact();
                }*/
            }
        }
        else
        {
            ActManager.Instance.StopAct();
            Debug.Log("stop loop");
            _actionComponent.StopLooping();
            _isTransitioning = false;
            _isActive = false;
        }

    }

    internal void StopMovement()
    {
        _gravityReceiver.SetActiveMove(false);
        _cameraController.SetActiveMove(false);
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;

    }

    private void StartMovement()
    {
        _gravityReceiver.SetActiveMove(true);
        _cameraController.SetActiveMove(true);

    }

    private void OnDisable()
    {
        _inputController.OnInteracted -= OnInteract;
    }


    public void ResetDetectValue()
    {
        DetectionValue = 90;
    }
}
