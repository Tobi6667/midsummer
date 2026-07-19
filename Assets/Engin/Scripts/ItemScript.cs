using UnityEngine;
using System.Collections;

public enum ItemType{Consumable, MainHand, TwoHanded, OffHand,Head,Neck,Chest,Ring, Legs,Braces, Boots, Trinket, Shoulders, Belt, Generic, GenericWeapon, Trap, TNT};
public enum Quality { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT };

public class ItemScript : MonoBehaviour {

  
    //public Mesh cubeMesh;
    public Sprite spriteNeutral;
	public Sprite spriteHighlighted;
     Item item;
    //Mesh oldMesh;
    //Mesh newMesh;
    //Mesh newMesh = Resources.Load<Mesh>("Meshes/House");
    //obj.GetComponent<MeshFilter>().mesh = newMesh;
    

    public Item Item
    {
        get
        {
            return item;
        }

        set
        {
            item = value;
            //spriteHighlighted = Resources.Load<Sprite>(value.SpriteHighlighted);
            //spriteNeutral = Resources.Load<Sprite>(value.SpriteNeutral);
           // cubeMesh = Resources.Load<Mesh>("Meshes/Barrel");
            
        }
    }

    public void Use(Slot slot)
    {
        item.Use(slot,this);
		}
	public string GetTooltip()
	{
        return "false";// item.GetToolTip();
	}
    void Start()
    {
       // gameObject.GetComponent<MeshFilter>().mesh = cubeMesh;
       // transform.localScale = new Vector3(20, 20, 20);
    }

}

