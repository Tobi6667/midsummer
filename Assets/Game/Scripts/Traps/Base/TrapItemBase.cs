using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public abstract class TrapItemBase : PickUpBase
{
    [SerializeField] protected List<StatusEffectBase> statusEffects;
    [SerializeField] protected ParticleSystem triggerEffect;
    [SerializeField] protected bool onlyPickup;
    private ParticleSystem partObj;


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

        if(collider.gameObject.CompareTag("Enemy") && !isTriggered && !onlyPickup)
        {
            Debug.Log("enemy hit trap");
           base.isTriggered = true;
            EnemyController enemy = collider.gameObject.GetComponent<EnemyController>();
            foreach (var effect in statusEffects)
            {
                enemy.ApplyTrapEffect(effect);

            }

           partObj = Instantiate(triggerEffect,this.transform.position,Quaternion.identity);
           partObj.Play();
            StartCoroutine(CoDestroySelf(statusEffects[0].duration));


Destroy(partObj.gameObject, partObj.main.duration);
            OnTrapTriggered(enemy); // <-- this line is missing in your version

        }
    }

private IEnumerator CoDestroySelf(float _duration)
{
    yield return new WaitForSeconds(_duration);
    Destroy(gameObject);

}

    protected virtual void OnTrapTriggered(EnemyController enemy)
    {
    }


}