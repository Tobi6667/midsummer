using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlayerInventoryComponent : MonoBehaviour {

    private PlayerInputController inputController;
    [SerializeField] private TrapItemBase bomb;
   [SerializeField] private LayerMask trapSpotMask;
[SerializeField] private Transform itemDropoff;


    private void Awake()
    {
        inputController = GetComponent<PlayerInputController>();
        inputController.OnItemSelected += OnItemSelect;
    }

    private void OnItemSelect(int itemIndex)
    {

            InventoryManagerNEW.Instance.DropItem(itemIndex,itemDropoff);



    }

    //private void HandleMovement(){
    //	float translation=speed*Time.deltaTime;
    //	transform.Translate(new Vector3(Input.GetAxis("Horizontal")*translation, 0, Input.GetAxis("Vertical")*translation));}
    private void OnTriggerEnter(Collider other)
	{
        if (other.tag == "Item")
        {
            Debug.Log("ITEM!!");
            //inventory.AddItem(other.GetComponent<ItemScript>());
            var it = other.GetComponent<PickUpBase>();

            InventoryManagerNEW.Instance.AddItem(it.GetItem());
            Destroy(other.gameObject);
        }

        
    }


    
  /*   private void OnTriggerExit(Collider other)
    {
        if(other.gameObject.tag=="Chest")
        {
            if(chest.IsOpen)
            { chest.Open(); }
            chest = null;
        }
    }
   void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Item")
        {
           
           if( inventory.AddItem(collision.gameObject.GetComponent<ItemScript>()))
            {
                Destroy(collision.gameObject);
            }

            
        }
        else if (collision.gameObject.tag == "Trap")
        {

            if (inventory.AddItem(collision.gameObject.GetComponent<ItemScript>()))
            {
                Destroy(collision.gameObject);
            }


        }
    }*/




    //public void SetStats(int agility, int strength, int stamina, int intellect)
    //{
    //    this.agility = agility + baseAgility;
    //    this.strength = strength + baseStrength;
    //    this.stamina = stamina + baseStamina;
    //    this.intellect = intellect + baseIntellect;
    //    statText.text = string.Format("Stamina: {0}\nStrength: {1}\nIntellect: {2}\nAgility: {3}" , this.stamina , this.strength , this.intellect ,this.agility);

    //}
}


