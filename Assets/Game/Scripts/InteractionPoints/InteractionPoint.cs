using UnityEngine;

public class InteractionPoint : MonoBehaviour
{
    public SoInteractionPoint _interactionData;
    public Transform _interactPosition;
    public bool _isOccupied {  get; private set; }

    public void SetOccupied(bool occupied)
    {
        _isOccupied = occupied;
    }

    public bool IsOccupied { get { return _isOccupied; } }
}
