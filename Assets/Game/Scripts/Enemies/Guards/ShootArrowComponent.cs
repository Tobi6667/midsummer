using UnityEngine;

public class ShootArrowComponent : MonoBehaviour
{
    [SerializeField] private GameObject _arrowPrefab;
    [SerializeField] private Transform _arrowSpawnPoint;
    private Transform _target;

    void Start()
    {
        _target = PlayerController.Instance.transform;
    }

    void Update()
    {

    }


    public void EnableArrow()
    {
        Debug.Log("ARROW");
        // enable arrow mesh/renderer, whatever the guard needs at draw time
    }

    public void Pull()
    {

    }

    public void Release()
    {
        

        var arrowObj = Instantiate(_arrowPrefab, _arrowSpawnPoint.position, _arrowSpawnPoint.rotation);
        arrowObj.GetComponent<ArrowProjectile>().Launch(_target.position);
    }

    public void DisableArrow()
    {

    }
}