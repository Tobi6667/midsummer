
using System.Collections.Generic;
using UnityEngine;
public class PlayerOnTriggerEnter : MonoBehaviour
{
    [SerializeField] private List<GameObject> butterflies = new();

    private Transform player;
    private bool shouldFollow;
    float speed = .00001f;
    
    private void Start()
    {
        GameObject playerObject = GameObject.FindGameObjectWithTag("Player");

        if (playerObject == null)
        {
            Debug.LogError("No GameObject with the tag 'Player' was found.");
            enabled = false;
            return;
        }

        player = playerObject.transform;
    }

    private void Update()
    {
        if (!shouldFollow || player == null)
            return;

        foreach (GameObject butterfly in butterflies)
        {
            butterfly.transform.position = Vector3.MoveTowards(transform.position, player.position,
        speed * Time.deltaTime);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log($"Something entered the trigger: {other.name}");

        if (other.CompareTag("Player"))
        {
            Debug.Log("Player entered. Butterflies are now following.");
            shouldFollow = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            // Remove this line if they should continue following forever.
            shouldFollow = false;
        }
    }
}
