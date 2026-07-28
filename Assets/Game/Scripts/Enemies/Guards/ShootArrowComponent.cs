using UnityEngine;

public class ShootArrowComponent : MonoBehaviour
{
    [SerializeField] private GameObject _arrowPrefab;
    [SerializeField] private Transform _arrowSpawnPoint;
    [SerializeField] private AudioSource _shootAudio;
    [SerializeField] private Transform _targetObject;

    [SerializeField] private bool _shootPlayer;
    private Transform _targetPlayer;

    void Start()
    {
        
        _targetPlayer = PlayerController.Instance.transform;
       

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


        if (_shootPlayer)
        {
            arrowObj.GetComponent<ArrowProjectile>().Launch(_targetPlayer.position);

        }
        else
        {
            arrowObj.GetComponent<ArrowProjectile>().Launch(_targetObject.position);

        }

        _shootAudio.Play();
    }

    public void DisableArrow()
    {

    }
}