using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public abstract class TrapItemBase : PickUpBase
{
    [SerializeField] protected List<StatusEffectBase> statusEffects;
    [SerializeField] protected ParticleSystem triggerEffect;
    private ParticleSystem partObj;
    private bool isTriggered = false;

    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log("collided");
        if(collision.gameObject.CompareTag("Enemy"))
        {
            Debug.Log("enemy hit trap");
        }
    }

    private void OnTriggerEnter(Collider collider)
    {     

        if(collider.gameObject.CompareTag("Enemy") && !isTriggered)
        {
            Debug.Log("enemy hit trap");
            isTriggered = true;
            EnemyController enemy = collider.gameObject.GetComponent<EnemyController>();
            foreach (var effect in statusEffects)
            {
                enemy.ApplyTrapEffect(effect);

            }

           partObj = Instantiate(triggerEffect,this.transform.position,Quaternion.identity);
           partObj.Play();
            StartCoroutine(CoDestroySelf());


Destroy(partObj.gameObject, partObj.main.duration);
        }
    }

private IEnumerator CoDestroySelf()
{
    yield return new WaitForSeconds(3f);
    Destroy(gameObject);

}


}