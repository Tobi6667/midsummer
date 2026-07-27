using UnityEngine;

public class WingsPickUp : PickUpBase
{
    public void ShowWings()
    {
        PlayerController.Instance.ShowWings(true);
    }
}
