using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlayerInventoryComponent : MonoBehaviour {
    static PlayerInventoryComponent Instance;
	//public float speed;
	  public Inventory inventory;
    public Inventory charPanel;
     Inventory chest;
    private PlayerInputController inputController;
    [SerializeField] private TrapItemBase bomb;

   [SerializeField] private LayerMask trapSpotMask;
    //public Text statText;
    //public ItemScript[] items = new ItemScript[10];
    //int intellect;
    //int agility;
    //int strength;
    //int stamina;
    //public int baseIntellect;
    //public int baseAgility;
    //public int baseStrength;
    //public int baseStamina;


    //private void Start()
    //{
    //    SetStats(0, 0, 0, 0);

    //}
    //   void Update()
    //{

    //	HandleMovement();
    //       if(Input.GetKeyDown(KeyCode.B))
    //       {
    //           inventory.Open();
    //       }
    //       if (Input.GetKeyDown(KeyCode.E))
    //       {
    //           if (chest != null)
    //               chest.Open();
    //       }
    //       if (Input.GetKeyDown(KeyCode.C))
    //       {
    //           if (charPanel != null)
    //               charPanel.Open();
    //       }
    //   }


    private void Awake()
    {
        Instance = this;
        inputController = GetComponent<PlayerInputController>();
        inputController.OnItem1Clicked += OnItem1;
    }

    private void OnItem1()
    {
        var collid = Physics.OverlapSphere(transform.position,5f,trapSpotMask);

        if (collid!=null)
        {
           var spot = collid[0].GetComponent<TrapSpot>();
            if (spot!=null)
            {
                var pref = Instantiate(bomb, PlayerController.Instance.transform.position, Quaternion.identity);
                spot.PlaceTrap(pref);
            }


        }
    }

    //private void HandleMovement(){
    //	float translation=speed*Time.deltaTime;
    //	transform.Translate(new Vector3(Input.GetAxis("Horizontal")*translation, 0, Input.GetAxis("Vertical")*translation));}
    private void OnTriggerEnter(Collider other)
	{
        if (other.tag == "Item")
        {
            Debug.Log("ITEM!!");
            inventory.AddItem(other.GetComponent<ItemScript>());
            Destroy(other.gameObject);
        }

        if (other.gameObject.tag=="Equipment")
        {//pick 0,1 or 2
            int randomType = Random.Range(0, 3);
            GameObject tmp = Instantiate(InventoryManager.Instance.itemObject);
            int randomItem;
            tmp.AddComponent<ItemScript>();
          
            ItemScript newItem = tmp.GetComponent<ItemScript>();
            switch (randomType)
            {
                case 0:
                    
                  
                    randomItem = Random.Range(0, InventoryManager.Instance.ItemContainer.
                        Consumables.Count);
                    newItem.Item = InventoryManager.Instance.ItemContainer.Consumables[randomItem];
                  
                  
                    break;
                case 1:
                   
                   
                    randomItem = Random.Range(0, InventoryManager.Instance.ItemContainer.
                        Weapons.Count);
                    newItem.Item = InventoryManager.Instance.ItemContainer.Weapons[randomItem];

                    
                    
                    break;
                case 2:
                  
                    
                    randomItem = Random.Range(0, InventoryManager.Instance.ItemContainer.
                        Equipment.Count);
                    newItem.Item = InventoryManager.Instance.ItemContainer.Equipment[randomItem];
                    break;
                default:
                    break;
            }
            
            inventory.AddItem(newItem);
            
            Destroy(tmp);
        }
        if (other.tag == "Chest")
            chest = other.GetComponent<ChestScript>().chestInventory;
        
    }
    private void OnTriggerExit(Collider other)
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
    }




    //public void SetStats(int agility, int strength, int stamina, int intellect)
    //{
    //    this.agility = agility + baseAgility;
    //    this.strength = strength + baseStrength;
    //    this.stamina = stamina + baseStamina;
    //    this.intellect = intellect + baseIntellect;
    //    statText.text = string.Format("Stamina: {0}\nStrength: {1}\nIntellect: {2}\nAgility: {3}" , this.stamina , this.strength , this.intellect ,this.agility);

    //}
}


