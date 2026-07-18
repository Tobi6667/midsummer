using System;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
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
        _movementController = GetComponent<PlayerMovementController>();
        _inputController = GetComponent<PlayerInputController>();
        _actionComponent = GetComponent<AnimationActionComponent>();
        _gravityReceiver = GetComponent<PlayerGravityReceiver>();

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
            var hits = Physics.OverlapSphere(transform.position, 5f, _interactMask);

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
                    interAct.Interact();
                    break;
                }

                if (hit.TryGetComponent<ActorController>(out var interActor) && !_isTransitioning)
                {
                    Debug.Log("wtf guard");
                    interActor.Interact();
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
}
